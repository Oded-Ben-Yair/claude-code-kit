# T2: Integration Dev — Tool-Call Loop in _base.py

## Context
You are Terminal 2 in a 4-terminal parallel implementation of R106. T1 (another session) is creating `src/agent/casino_tools.py` and `src/agent/agents/tool_binding.py`. Your job is to integrate the tool-call loop into `src/agent/agents/_base.py`.

**Read `.claude/teams/r106-multi-terminal/status.md` for file ownership rules. You ONLY modify files assigned to T2.**

## Your Files (EXCLUSIVE — only you touch these)
- `src/agent/agents/_base.py` — MODIFY (add tool-call loop)
- `tests/test_tool_call_loop.py` — CREATE (integration tests)

## DO NOT TOUCH (owned by other terminals)
- `src/agent/casino_tools.py` (T1)
- `src/agent/agents/tool_binding.py` (T1)
- `src/casino/feature_flags.py` (T1)
- `src/casino/config.py` (T1)
- `tests/evaluation/*` (T3)
- `scripts/*`, `data/training/*` (T4)

## Interface Spec (T1 is building these — use this interface)

### casino_tools.py exports:
```python
from langchain_core.tools import tool

@tool
def check_comp_eligibility(guest_tier: str, occasion: str = "") -> str:
    """Check what comps/rewards a guest may be eligible for based on their tier and occasion."""
    # Returns formatted string with eligible comps, talking points

@tool
def check_tier_status(tier_name: str, query: str = "") -> str:
    """Look up benefits and perks for a specific loyalty/rewards tier."""
    # Returns formatted string with tier benefits from momentum-tiers.md

@tool
def lookup_upcoming_events(venue_type: str = "all", interest: str = "") -> str:
    """Find upcoming entertainment, shows, and events at the property."""
    # Returns formatted string with matching events from entertainment-guide.md

@tool
def check_incentive_eligibility(occasion: str = "", profile_completeness: float = 0.0, guest_tier: str = "new") -> str:
    """Check if a guest qualifies for any incentive offers based on their profile."""
    # Returns formatted string with applicable incentives
```

### tool_binding.py exports:
```python
from langchain_core.tools import BaseTool

def get_tools_for_agent(agent_name: str) -> list[BaseTool]:
    """Return the tools available for a specific specialist agent."""
    # comp agent: all 4 tools
    # dining/entertainment/hotel: lookup_upcoming_events, check_tier_status
    # host: all 4 tools
    # Returns empty list for unknown agents

def bind_tools_to_llm(llm, agent_name: str, tool_use_enabled: bool = False) -> tuple:
    """Bind appropriate tools to an LLM instance.
    Returns (llm_with_tools_or_original, tools_list, is_bound).
    If tool_use_enabled=False or no tools for this agent, returns (original_llm, [], False).
    Uses llm.bind_tools(tools) — returns new RunnableBinding, doesn't mutate."""
```

## Implementation Steps

### Step 1: Read _base.py thoroughly
Read the ENTIRE `src/agent/agents/_base.py` file. Understand:
- The `execute_specialist()` function structure
- Where LLM model selection happens (~line 1317-1327)
- Where `llm.ainvoke()` is called (~line 1357)
- The semaphore acquisition pattern (~line 1339)
- The error handling around LLM calls

### Step 2: Write test file first (test_tool_call_loop.py)
Create `tests/test_tool_call_loop.py` with ~15 tests:

```python
"""Tests for tool-call loop integration in _base.py execute_specialist().

Tests verify:
1. Tool binding happens when feature flag is on
2. Tool calls are executed and results appended
3. LLM re-invoked after tool results
4. Max 1 tool-call round (no infinite loops)
5. Tool errors are caught gracefully (fallback to no-tool response)
6. Feature flag off = no tool binding (zero behavioral change)
7. Agent without tools = no binding attempted
"""
```

Use the mock LLM pattern from `tests/test_concurrent_execution.py` (read it for the pattern). Key mock behaviors:
- Mock LLM that returns AIMessage with `tool_calls` on first invoke, normal content on second
- Mock LLM that returns normal content (no tool calls) — should work as before
- Mock tool functions that return known strings

### Step 3: Integrate tool-call loop into _base.py

**Location 1: Tool binding (between model selection and semaphore, around line 1327)**
```python
# R106: Bind tools to LLM when tool_use_enabled
_tools_bound = False
_bound_tools = []
if settings_obj.get("tool_use_enabled", False):  # Read from feature flags
    from src.agent.agents.tool_binding import bind_tools_to_llm
    llm, _bound_tools, _tools_bound = bind_tools_to_llm(
        llm, agent_name, tool_use_enabled=True
    )
    if _tools_bound:
        logger.info("R106: Tools bound for %s agent (%d tools)", agent_name, len(_bound_tools))
```

IMPORTANT: `bind_tools_to_llm` returns a NEW LLM instance (RunnableBinding). It does NOT mutate the singleton. This is safe.

The `settings_obj` should come from the feature flags. Read how `_DEFAULT_FEATURES` is accessed in the existing code around line 1100 — it's imported synchronously: `from src.casino.feature_flags import DEFAULT_FEATURES as _DEFAULT_FEATURES`. Use the same pattern to check `tool_use_enabled`.

**Location 2: Tool-call loop (after llm.ainvoke at line 1357)**
```python
response = await llm.ainvoke(llm_messages)

# R106: Tool-call loop — execute tool calls and re-invoke LLM (max 1 round)
if _tools_bound and hasattr(response, 'tool_calls') and response.tool_calls:
    from langchain_core.messages import ToolMessage
    tool_results = []
    _tool_map = {t.name: t for t in _bound_tools}
    for tc in response.tool_calls:
        tool_fn = _tool_map.get(tc["name"])
        if tool_fn:
            try:
                result = tool_fn.invoke(tc["args"])
                tool_results.append(ToolMessage(
                    content=str(result),
                    tool_call_id=tc["id"],
                ))
            except Exception as tool_err:
                logger.warning("R106: Tool %s failed: %s", tc["name"], tool_err)
                tool_results.append(ToolMessage(
                    content=f"Tool error: {tool_err}",
                    tool_call_id=tc["id"],
                ))
        else:
            logger.warning("R106: Unknown tool requested: %s", tc["name"])
            tool_results.append(ToolMessage(
                content="Tool not available",
                tool_call_id=tc.get("id", "unknown"),
            ))

    if tool_results:
        # Append AI response with tool_calls + tool results, then re-invoke
        llm_messages.append(response)
        llm_messages.extend(tool_results)
        logger.info("R106: Executing %d tool calls, re-invoking LLM", len(tool_results))
        response = await llm.ainvoke(llm_messages)  # Second LLM call with tool results
```

CRITICAL CONSTRAINTS:
- This block goes INSIDE the existing try/except around line 1357-1405
- Max 1 round of tool calls (no loop — the second invoke should produce content, not more tool calls)
- Tool execution is synchronous (the @tool functions are pure business logic, no I/O)
- The semaphore is already held — both LLM calls happen within the semaphore
- If ANY tool fails, append error ToolMessage — don't crash

**Location 3: Skip redundant prompt sections when tools are bound (around line 1162)**
When `_tools_bound` is True AND the agent is `comp`, the comp prompt section injection (lines 1162-1168) becomes redundant because the LLM will call the tool instead. Add a gate:

```python
# R98: CompStrategy — only inject prompt section if tools NOT bound
if agent_name == "comp" and not _tools_bound:
    from src.agent.behavior_tools.comp_strategy import get_comp_prompt_section
    comp_section = get_comp_prompt_section(state, casino_id=settings.CASINO_ID)
    ...
```

Wait — `_tools_bound` is not available at line 1162 because it's set later (~1327). Instead, check the feature flag directly:

```python
_tool_use_flag = _DEFAULT_FEATURES.get("tool_use_enabled", False)
if agent_name == "comp" and not _tool_use_flag:
    # existing comp prompt injection
```

### Step 4: Run tests
```bash
pytest tests/test_tool_call_loop.py -v --timeout 30
pytest tests/ -x --timeout 30 -q  # Full suite
```

### Step 5: Write completion status
When done, update `.claude/teams/r106-multi-terminal/status.md` — change T2 status to COMPLETED and list files modified.

## Success Criteria
- [ ] `tests/test_tool_call_loop.py` has 15+ tests, all passing
- [ ] `_base.py` modifications: tool-bind block, tool-call loop, prompt skip gate
- [ ] Feature flag gate: `tool_use_enabled=False` → zero behavioral change
- [ ] Full test suite: `pytest tests/ -x --timeout 30` → 3800+ pass, 0 fail
- [ ] No changes to files outside T2 ownership
