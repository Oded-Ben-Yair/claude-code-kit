# LangGraph Production Patterns (Core)

Origin: Production LLM agent — 73 review rounds, 8 model families, 500+ findings, 2800+ tests, score 67 to 92.4 (external consensus).

**On-demand docs** (loaded by trigger words, see CLAUDE.md):
- `{CLAUDE_HOME}/docs/langgraph-safety.md` — validation, fail-closed/open, degraded-pass, crisis, compliance
- `{CLAUDE_HOME}/docs/langgraph-scalability.md` — circuit breaker, Redis, TTL, SSE streaming, locks, backpressure
- `{CLAUDE_HOME}/docs/langgraph-testing.md` — conftest, E2E, env var isolation, mock vs live, behavioral scenarios
- `{CLAUDE_HOME}/docs/langgraph-domain.md` — multi-tenant, sentiment, sarcasm, slang, extraction, guardrail wiring

## Custom StateGraph over create_react_agent (MANDATORY for validation loops)

Use custom `StateGraph` when you need: validation loops, conditional routing, multiple terminal nodes, or non-tool-calling branches. `create_react_agent` is only for simple tool-calling agents.

```python
graph = StateGraph(MyState)
graph.add_node("router", router_node)
graph.add_node("generate", generate_node)
graph.add_node("validate", validate_node)
graph.add_conditional_edges("validate", route_after_validate, {
    "respond": "respond",
    "generate": "generate",  # RETRY loop
    "fallback": "fallback",
})
compiled = graph.compile(checkpointer=checkpointer, interrupt_before=interrupt_before)
compiled.recursion_limit = GRAPH_RECURSION_LIMIT
```

Origin: Production LLM agent — review rounds 1-2. All 5 review models praised the validation loop as the standout architectural pattern.

## State Design: Persistent vs Per-Turn Fields

Use `Annotated[list, add_messages]` reducer ONLY for `messages` (persisted by checkpointer). All other fields are per-turn ephemeral — reset via `_initial_state()` helper.

```python
class AgentState(TypedDict):
    messages: Annotated[list, add_messages]  # Cross-turn persistence
    query_type: str | None                   # Per-turn, reset each call
    validation_result: str | None            # Per-turn
    retry_count: int                         # Per-turn

def _initial_state(message: str) -> dict:
    return {
        "messages": [HumanMessage(content=message)],
        "query_type": None,
        "validation_result": None,
        "retry_count": 0,
    }
```

Origin: Production LLM agent — review round 8. Stale `retry_feedback` from one turn leaked into the next.

## Structured Output Routing with Pydantic + Literal Types

```python
class RouterOutput(BaseModel):
    query_type: Literal["property_qa", "greeting", "off_topic", "ambiguous"]
    confidence: float = Field(ge=0.0, le=1.0)

router_llm = llm.with_structured_output(RouterOutput)
result: RouterOutput = await router_llm.ainvoke(prompt_text)
```

**NEVER** parse LLM routing decisions via substring matching. Always use `with_structured_output(PydanticModel)` with `Literal` type constraints.

Origin: Production LLM agent — review round 1. "This is NOT NON-COMPLIANT" triggered false block via substring matching.

## Validation Loop Pattern: generate -> validate -> retry(max 1) -> fallback

```python
async def validate_node(state) -> dict:
    if state.get("skip_validation", False):
        return {"validation_result": "PASS"}
    retry_count = state.get("retry_count", 0)
    result = await validator_llm.ainvoke(prompt)
    if result.status == "PASS":
        return {"validation_result": "PASS"}
    if retry_count < 1:
        return {"validation_result": "RETRY", "retry_count": retry_count + 1,
                "retry_feedback": result.reason}
    return {"validation_result": "FAIL", "retry_feedback": result.reason}
```

- Use `skip_validation: bool` state field — NEVER magic sentinels like `retry_count=99`
- Separate validator LLM with `temperature=0.0` for deterministic classification
- Max 1 retry to prevent infinite loops (bounded by `recursion_limit` as backup)

## Pre-LLM Deterministic Guardrails (MANDATORY for regulated domains)

Run regex-based guardrails BEFORE any LLM call. Never rely solely on prompt instructions for safety-critical classification.

```python
if detect_prompt_injection(user_input):
    return {"query_type": "injection", "confidence": 1.0}
if detect_compliance_violation(user_input):
    return {"query_type": "compliance_violation", "confidence": 1.0}
```

- Deterministic, cost-free, side-effect-free (logging only)
- Domain-aware exclusions (e.g., "act as a guide" may be OK in certain contexts)

Origin: Production LLM agent — review rounds 7-12. 5 guardrail layers praised by all reviewers as standout.

## Pin LangGraph Version Exactly

```
langgraph==0.2.60   # GOOD
langgraph>=0.2      # BAD — API parameters change between minor versions
```

Origin: Production LLM agent — review round 2. `create_react_agent(prompt=...)` caused TypeError because pinned version used `state_modifier`.

## Always async in Async Apps

```python
# GOOD: Non-blocking
async def generate_node(state) -> dict:
    result = await llm.ainvoke(messages)

# BAD: Blocks event loop
def generate_node(state) -> dict:
    result = llm.invoke(messages)  # Blocks all concurrent requests
```

## string.Template.safe_substitute() for User Content

```python
# GOOD: Won't crash on {curly braces} in user text
from string import Template
prompt = Template("You are a concierge for $property_name")
result = prompt.safe_substitute(property_name="Example Corp")

# BAD: Crashes on user text with {}
prompt = "You are a concierge for {property_name}".format(property_name=name)
```

Origin: Production LLM agent — review round 8. `.format()` caused KeyError DoS when users sent `{anything}`.

## Node Name Constants

```python
NODE_ROUTER = "router"
NODE_GENERATE = "generate"
NODE_VALIDATE = "validate"
_KNOWN_NODES = frozenset({NODE_ROUTER, NODE_GENERATE, NODE_VALIDATE})
graph.add_node(NODE_ROUTER, router_node)
```

## LangGraph State Serialization Safety

LangGraph state MUST be JSON-serializable:
- TypedDict fields with `Annotated` reducers must use serializable types
- Test: `json.loads(json.dumps(state))` catches property/method bugs
- NEVER use `@property` on state classes crossing checkpointer boundaries
- Use `list` not `set` for accumulated state (set is not JSON serializable)

## Specialist Agent DRY Extraction (MANDATORY for 3+ agents)

Extract shared base function with dependency injection when 3+ agents share execution patterns:

```python
# _base.py — shared execution logic (~80% of each agent)
async def execute_specialist(
    state: AgentState,
    agent_config: AgentConfig,
    get_llm_fn: Callable,       # DI: preserves test mock paths
    get_cb_fn: Callable,        # DI: circuit breaker per agent
) -> dict:
    cb = get_cb_fn()
    if cb.is_open:
        return {"messages": [AIMessage(content=FALLBACK)], "skip_validation": True}
    llm = await get_llm_fn()
    # ... shared prompt assembly, context formatting, error handling

# specific_agent.py — thin wrapper (~30 lines)
async def specific_agent(state: AgentState) -> dict:
    return await execute_specialist(state, AGENT_CONFIG, _get_llm, _get_cb)
```

Origin: Production LLM agent — review rounds 1-2. Unanimously praised across all 20 rounds as "the single best change."

## State Field Reducers for Accumulated Data (MANDATORY)

When a LangGraph state field accumulates data across turns, it MUST have a custom reducer. Without a reducer, each node return OVERWRITES the previous value.

```python
def _merge_dicts(existing: dict | None, new: dict | None) -> dict:
    if not new:
        return existing or {}
    merged = dict(existing or {})
    merged.update(new)
    return merged

class AgentState(TypedDict):
    extracted_fields: Annotated[dict, _merge_dicts]  # Accumulates across turns
```

Origin: Production LLM agent — review round 19. CRITICAL: extracted_fields had no reducer; multi-turn profiling silently broken.

## Feature Flag Defaults Must Enable Wired Code (MANDATORY)

When code is fully wired (imports exist, graph nodes call it, tests cover it), the feature flag MUST default to `True`. Flag defaulting to `False` on wired code = dead code that passes all reviews.

```python
# BAD: 425 LOC wired but never executes
guest_profile_enabled: bool = False  # "Safe default" = dead code

# GOOD: Wired code runs by default
guest_profile_enabled: bool = True
```

Origin: Production LLM agent — review round 19. Feature was fully wired but never executed. All review rounds 11-18 scored it as "implemented."
