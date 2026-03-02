# LangGraph Production Patterns (Core)

Origin: Hey Seven 2026-02-15 — 73 review rounds, 8 model families, 500+ findings, 2822 tests, score 67→92.4 (external consensus).

**On-demand docs** (loaded by trigger words, see CLAUDE.md):
- `~/.claude/docs/langgraph-safety.md` — validation, fail-closed/open, degraded-pass, crisis, compliance
- `~/.claude/docs/langgraph-scalability.md` — circuit breaker, Redis, TTL, SSE streaming, locks, backpressure
- `~/.claude/docs/langgraph-testing.md` — conftest, E2E, env var isolation, mock vs live, behavioral scenarios
- `~/.claude/docs/langgraph-domain.md` — multi-tenant, sentiment, sarcasm, slang, extraction, guardrail wiring

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

Origin: Hey Seven R1-R2 — all 5 review models praised the validation loop as the standout architectural pattern.

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

Origin: Hey Seven R8 — stale `retry_feedback` from dining turn leaked into spa turn.

## Structured Output Routing with Pydantic + Literal Types

```python
class RouterOutput(BaseModel):
    query_type: Literal["property_qa", "greeting", "off_topic", "ambiguous"]
    confidence: float = Field(ge=0.0, le=1.0)

router_llm = llm.with_structured_output(RouterOutput)
result: RouterOutput = await router_llm.ainvoke(prompt_text)
```

**NEVER** parse LLM routing decisions via substring matching. Always use `with_structured_output(PydanticModel)` with `Literal` type constraints.

Origin: Hey Seven R1 — "This is NOT NON-COMPLIANT" triggered false block via substring matching.

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
if detect_responsible_gaming(user_input):
    return {"query_type": "responsible_gaming", "confidence": 1.0}
```

- Deterministic, cost-free, side-effect-free (logging only)
- Domain-aware exclusions (e.g., "act as a guide" is OK in casino context)

Origin: Hey Seven R7-R12 — 5 guardrail layers praised by all reviewers as standout.

## Pin LangGraph Version Exactly

```
langgraph==0.2.60   # GOOD
langgraph>=0.2      # BAD — API parameters change between minor versions
```

Origin: Hey Seven R2 — `create_react_agent(prompt=...)` caused TypeError because pinned version used `state_modifier`.

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
result = prompt.safe_substitute(property_name="Mohegan Sun")

# BAD: Crashes on user text with {}
prompt = "You are a concierge for {property_name}".format(property_name=name)
```

Origin: Hey Seven R8 — `.format()` caused KeyError DoS when users sent `{anything}`.

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

# dining_agent.py — thin wrapper (~30 lines)
async def dining_agent(state: AgentState) -> dict:
    return await execute_specialist(state, DINING_CONFIG, _get_llm, _get_cb)
```

Origin: Hey Seven R1-R2 — Gemini called it "the single best change." Unanimously praised across all 20 rounds.

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

Origin: Hey Seven R19 — CRITICAL. extracted_fields had no reducer; multi-turn profiling silently broken.

## Feature Flag Defaults Must Enable Wired Code (MANDATORY)

When code is fully wired (imports exist, graph nodes call it, tests cover it), the feature flag MUST default to `True`. Flag defaulting to `False` on wired code = dead code that passes all reviews.

```python
# BAD: 425 LOC wired but never executes
guest_profile_enabled: bool = False  # "Safe default" = dead code

# GOOD: Wired code runs by default
guest_profile_enabled: bool = True
```

Origin: Hey Seven R19 — guest_profile.py was fully wired but never executed. All R11-R18 reviews scored it as "implemented."

## Guardrail Priority Ordering for Cross-Cutting Concerns (MANDATORY)

When two guardrail categories can match the same user input, the one with higher safety impact MUST run first. Position-based short-circuiting means the first match wins — if a lower-priority guardrail fires first, the higher-priority response is suppressed.

```python
# BAD: Patron privacy (position 7) runs before crisis_active (7.4)
# "Is there someone I can talk to here?" matches patron privacy's
# \bis\s+[\w\s]+\s+...here pattern. Guest in crisis gets rebuffed.

# GOOD: Crisis_active (position 7) runs before patron privacy (7.5)
if state.get("crisis_active"):
    return {"query_type": "self_harm"}  # Crisis takes priority
if detect_patron_privacy(user_message):
    return {"query_type": "patron_privacy"}  # Only fires outside crisis
```

When adding a new guardrail category, test it against ALL existing categories' test phrases to detect cross-matching. Regex patterns like `\bis\s+[\w\s]+\s+...here` are especially prone to false cross-matches.

Origin: Hey Seven R75 (2026-03-01) — "Is there someone I can talk to here?" during crisis triggered patron privacy instead of maintaining crisis response. 3/3 live behavioral judges flagged as CRITICAL.

## Emotional Context Detection in Compliance Gate (Pattern)

For emotional states that need tone guidance but should NOT block the message (grief, celebration, nostalgia), detect in the compliance gate and set `guest_sentiment` as a pass-through annotation. This ensures emotional context reaches specialist agents through the normal state flow.

```python
# compliance_gate.py — detect but don't block
_GRIEF_KEYWORDS = ("passed away", "passed on", "died", "funeral", ...)
if any(kw in msg_lower for kw in _GRIEF_KEYWORDS):
    return {"query_type": None, "guest_sentiment": "grief"}  # Pass through

# prompts.py — tone guidance for the detected emotion
SENTIMENT_TONE_GUIDES["grief"] = "Respond with compassion. No promotions..."
```

Why compliance_gate (not router): Router runs after compliance_gate. If grief detection is in the router, it arrives too late — the LLM router may misclassify grief as property_qa, and the specialist dispatch sends it to comp with a generic "explore rewards" prompt.

Origin: Hey Seven R75 (2026-03-01) — "My dad passed two weeks ago" → "I'd love to help you explore our rewards!" for 2 turns. 3/3 judges CRITICAL. Fixed by adding grief detection at compliance_gate position 7.6.

## Gemini Flash Structured Output Schema Limits (MANDATORY)

Gemini Flash rejects `with_structured_output()` schemas that have >5 constrained fields (Literal types + bounded floats with ge/le). Returns 400 INVALID_ARGUMENT "schema produces a constraint that has too many states."

```python
# BAD: 19 nested ConfidenceField objects — 100% failure
class ProfileExtractionOutput(BaseModel):
    guest_name: ConfidenceField | None  # ConfidenceField has float[0,1] + Literal
    # ... 18 more fields = too many states

# GOOD: Flat str|None fields — 100% success
class ProfileExtractionOutput(BaseModel):
    guest_name: str | None = Field(default=None)
    party_size: str | None = Field(default=None)
    # ... flat fields, no constraints
```

**Rule**: Keep Gemini Flash structured output schemas flat with <5 constrained fields. Move confidence gating to the prompt text instead of the schema.

Working schemas (<=5 constrained): RouterOutput (3 fields), DispatchOutput (3 fields), ValidationResult (2 fields).
Failed schemas (before fix): ProfileExtractionOutput (19 nested), WhisperPlan (10 fields with 7 constraints).

Origin: Hey Seven R76 (2026-03-02) — ProfileExtractionOutput and WhisperPlan both 100% dead in live eval. 3236 tests passed because mocks don't validate schema complexity. Flattening immediately fixed both.

## Priority Sentiment Guard for Cross-Node State (MANDATORY)

When multiple graph nodes set the same state field, later nodes overwrite earlier ones. Use a priority guard when an upstream node (compliance_gate) detects a specific emotional context that a downstream node (router VADER) would overwrite.

```python
# In router_node:
_PRIORITY_SENTIMENTS = ("grief", "celebration")
_existing = state.get("guest_sentiment")
if _existing not in _PRIORITY_SENTIMENTS:
    # Only run VADER if compliance_gate didn't already set a priority sentiment
    sentiment = detect_sentiment(user_message)
    sentiment_update["guest_sentiment"] = sentiment
```

Without this guard: compliance_gate sets grief → router runs VADER → overwrites with "neutral" → specialist agent responds with generic enthusiasm to grieving guest.

Origin: Hey Seven R76 (2026-03-02) — grief sentiment detected at compliance_gate position 7.6 but overwritten by VADER in router_node. "My dad passed" → "explore our rewards!" 3-model judges CRITICAL. Fixed with `_PRIORITY_SENTIMENTS` guard.

## Tests Pass ≠ LLM API Compatibility (MANDATORY for structured output)

Mock LLMs in tests don't validate Pydantic schema complexity against the actual LLM API. A schema that works perfectly in tests can fail 100% of the time in production because:
- Mocks return pre-constructed Pydantic objects (bypass schema validation)
- Mocks don't enforce field constraints (Literal, ge/le bounds)
- Mocks don't have the "too many schema states" limit

**Rule**: For every `with_structured_output(PydanticModel)` call, add at least ONE live integration test that calls the actual LLM API. Use `@pytest.mark.live` to separate from unit tests.

```python
@pytest.mark.live
@pytest.mark.asyncio
async def test_profile_extraction_schema_gemini():
    """Verify ProfileExtractionOutput schema is accepted by Gemini Flash."""
    llm = ChatGoogleGenerativeAI(model="gemini-2.5-flash")
    extraction_llm = llm.with_structured_output(ProfileExtractionOutput)
    result = await extraction_llm.ainvoke("Guest says: I'm Mike, party of 4")
    assert isinstance(result, ProfileExtractionOutput)
```

Origin: Hey Seven R76 (2026-03-02) — 3236 tests passed while 3 structured output schemas were 100% broken in production. Schema complexity invisible to mock-based tests.

## Validation Grounding vs Proactive Suggestions (Pattern)

When the validation loop checks response grounding ("only facts from retrieved context"), strict enforcement blocks proactive cross-domain suggestions that improve user experience. The validation prompt must explicitly allow category-level suggestions without specific facts.

```
# In validation prompt:
1. **Grounded**: Specific facts (venue names, hours, prices) must come from
   retrieved context. However, brief proactive suggestions of OTHER property
   categories are acceptable ("After dinner, you might enjoy a show") as long
   as no specific facts are fabricated.
```

Without this: "After dinner, try the Wolf Den show" triggers FAIL because Wolf Den wasn't in the dining RAG context → fallback response → 40% of turns become generic redirects.

Origin: Hey Seven R76 (2026-03-02) — 37/236 behavioral turns hit fallback because validator rejected cross-domain suggestions. Relaxing grounding for category-level mentions reduced fallback rate.
