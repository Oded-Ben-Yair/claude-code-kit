# LangGraph Production Patterns

Origin: Hey Seven 2026-02-15 — 12 review rounds + 11-round hostile sprint (R35-R45) + 5 external multi-model hostile reviews (R47-R57), 8 model families, 500+ findings, 30+ CRITICALs + 120+ MAJORs fixed, 2462 tests, score 77→95 (internal) → 67→92.4 (external consensus).

## Custom StateGraph over create_react_agent (MANDATORY for validation loops)

Use custom `StateGraph` when you need: validation loops, conditional routing, multiple terminal nodes, or non-tool-calling branches. `create_react_agent` is only for simple tool-calling agents.

```python
# GOOD: Full control over execution flow
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

# BAD: No validation loop possible
agent = create_react_agent(model, tools)
```

Origin: Hey Seven R1-R2 — started with `create_react_agent`, switched to custom StateGraph for adversarial validation. All 5 review models praised the validation loop as the standout architectural pattern.

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

Origin: Hey Seven R8 — stale `retry_feedback` from dining turn leaked into spa turn. Fix: explicit reset of all non-message fields per invocation.

## Structured Output Routing with Pydantic + Literal Types

```python
class RouterOutput(BaseModel):
    query_type: Literal["property_qa", "greeting", "off_topic", "ambiguous"]
    confidence: float = Field(ge=0.0, le=1.0)

router_llm = llm.with_structured_output(RouterOutput)
result: RouterOutput = await router_llm.ainvoke(prompt_text)
```

**NEVER** parse LLM routing decisions via substring matching (`"NON-COMPLIANT" in text`). Always use `with_structured_output(PydanticModel)` with `Literal` type constraints.

Origin: Hey Seven R1 — compliance check used substring matching; "This is NOT NON-COMPLIANT" triggered false block.

## Validation Loop Pattern: generate -> validate -> retry(max 1) -> fallback

```python
async def validate_node(state) -> dict:
    if state.get("skip_validation", False):
        return {"validation_result": "PASS"}  # Bypass for safe fallbacks
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
- Inject validation feedback as `SystemMessage` into next generate call

Origin: Hey Seven R1-R12 — all 5 models unanimously agreed `retry_count=99` magic sentinel should be `skip_validation: bool`.

## Pre-LLM Deterministic Guardrails (MANDATORY for regulated domains)

Run regex-based guardrails BEFORE any LLM call. Never rely solely on prompt instructions for safety-critical classification.

```python
# Layer order matters: injection first, then domain-specific
if detect_prompt_injection(user_input):
    return {"query_type": "injection", "confidence": 1.0}
if detect_responsible_gaming(user_input):
    return {"query_type": "responsible_gaming", "confidence": 1.0}
# ... then LLM classification for non-safety queries
```

- Deterministic, cost-free, side-effect-free (logging only)
- Domain-aware exclusions (e.g., "act as a guide" is OK in casino context)
- Each guardrail returns immediately with specific `query_type` and `confidence=1.0`

Origin: Hey Seven R7-R12 — 5 guardrail layers (prompt injection, responsible gaming, age verification, BSA/AML, patron privacy) praised by all reviewers as standout.

## Pin LangGraph Version Exactly

```
# GOOD
langgraph==0.2.60

# BAD
langgraph>=0.2
```

API parameters change between minor versions (e.g., `prompt=` vs `state_modifier=` for `create_react_agent`). Pinning prevents silent breakage.

Origin: Hey Seven R2 — `create_react_agent(prompt=...)` caused TypeError because pinned version 0.2.60 used `state_modifier` parameter. Cost: full agent restructuring.

## Always async in Async Apps

```python
# GOOD: Non-blocking
async def generate_node(state) -> dict:
    result = await llm.ainvoke(messages)

# BAD: Blocks event loop
def generate_node(state) -> dict:
    result = llm.invoke(messages)  # Blocks all concurrent requests
```

Every multi-model review (5/5 models) flagged synchronous `.invoke()` in async apps as the #1 performance concern.

## string.Template.safe_substitute() for User Content

```python
# GOOD: Won't crash on {curly braces} in user text
from string import Template
prompt = Template("You are a concierge for $property_name")
result = prompt.safe_substitute(property_name="Mohegan Sun")

# BAD: Crashes on user text with {}
prompt = "You are a concierge for {property_name}".format(property_name=name)
```

Origin: Hey Seven R8 — `.format()` on user-facing templates caused KeyError DoS when users sent `{anything}`.

## Node Name Constants

```python
# Define as module-level frozenset
NODE_ROUTER = "router"
NODE_GENERATE = "generate"
NODE_VALIDATE = "validate"
_KNOWN_NODES = frozenset({NODE_ROUTER, NODE_GENERATE, NODE_VALIDATE})

# Use constants everywhere — prevents silent rename breakage
graph.add_node(NODE_ROUTER, router_node)
```

## SSE Streaming with astream_events v2

```python
async for event in graph.astream_events(initial_state, config=config, version="v2"):
    kind = event.get("event")
    node = event.get("metadata", {}).get("langgraph_node", "")
    if kind == "on_chat_model_stream" and node == NODE_GENERATE:
        # Stream tokens from generate node ONLY
        chunk = event.get("data", {}).get("chunk")
        if isinstance(chunk, AIMessageChunk) and chunk.content:
            yield {"event": "token", "data": chunk.content}
```

- Filter by `langgraph_node` metadata to isolate specific node outputs
- Track `on_chain_start`/`on_chain_end` for observability (duration_ms per node)
- Use `version="v2"` — v1 has different event structure

## Circuit Breaker for LLM Calls

```python
class CircuitBreaker:
    # States: closed (normal) -> open (blocking) -> half_open (probe)
    # Use asyncio.Lock for coroutine safety, @lru_cache(maxsize=1) for singleton
    async def call(self, func, *args):
        if self._state == "open" and not self._cooldown_expired():
            return SAFE_FALLBACK  # Fail open, not crash
```

- Check at start of generate_node before building prompts
- Fail OPEN with safe fallback (not crash) — same principle as ML gates

## Message Windowing

Limit conversation history to prevent unbounded growth:
```python
MAX_MESSAGES = 40
if len(state["messages"]) > MAX_MESSAGES:
    state["messages"] = state["messages"][-MAX_MESSAGES:]
```

## HITL Interrupt for Regulated Environments

```python
interrupt_before = [NODE_GENERATE] if settings.ENABLE_HITL_INTERRUPT else None
compiled = graph.compile(checkpointer=checkpointer, interrupt_before=interrupt_before)
```

Configurable via environment variable — clean on/off toggle without code changes.

## LangGraph State Serialization Safety

LangGraph state MUST be JSON-serializable (same principle as Azure Durable Functions `@property` rule):
- TypedDict fields with `Annotated` reducers must use serializable types
- Test serialization: `json.loads(json.dumps(state))` catches property/method bugs
- NEVER use `@property` on state classes crossing checkpointer boundaries

## Specialist Agent DRY Extraction (MANDATORY for 3+ agents)

When a LangGraph project has 3+ specialist agents sharing execution patterns (circuit breaker, prompt assembly, retry handling, error handling), extract a shared base function with dependency injection:

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

- Each specialist becomes a thin wrapper (30-50 lines) instead of 150+ lines of duplicated code
- DI parameters (`get_llm_fn`, `get_cb_fn`) preserve test mock paths without monkey-patching
- Error handling centralized: `ValueError`/`TypeError` (may produce malformed content, `skip_validation=False`) vs network errors (`skip_validation=True`)
- Parametrized contract tests verify all specialists follow the same interface

Origin: Hey Seven R1-R2 — 4/5 models flagged 600 lines of duplication as MAJOR. After extraction, Gemini called it "the single best change" and scored Graph Architecture +3. Unanimously praised across all 20 rounds.

## Degraded-Pass Validation Strategy

When an adversarial validator LLM fails (timeout, API error, parsing error), behavior should differ by attempt number:

```python
async def validate_node(state) -> dict:
    retry_count = state.get("retry_count", 0)
    try:
        result = await validator_llm.ainvoke(prompt)
        return {"validation_result": result.status}
    except Exception:
        if retry_count == 0:
            # First attempt: deterministic guardrails already passed.
            # Validator might be temporarily down. Serve unvalidated.
            return {"validation_result": "PASS"}  # Degraded-pass
        else:
            # Retry attempt: prior validation issues exist + validator failure.
            # Suspect content. Fail closed, route to safe fallback.
            return {"validation_result": "FAIL"}
```

- **First attempt + validator failure = PASS** (availability over safety — deterministic guardrails already ran, validator might just be down)
- **Retry attempt + validator failure = FAIL** (safety over availability — prior issue + validator failure = suspect content)
- This balances availability and safety in a principled way that all 4 review models praised
- Do NOT fail-closed on all validator errors — that blocks ALL responses during LLM outages

Origin: Hey Seven R8-R12 — R8 changed to fail-closed (GPT recommendation). R11 unanimously flagged doc-code mismatch. R12 implemented degraded-pass as documented. All 4 R20 models praised this as "nuanced" and "production-grade."

## Fail-Closed for Safety-Critical Paths (MANDATORY for PII/injection/compliance)

PII redaction, injection detection, and compliance checks MUST fail CLOSED on any error — return safe placeholder, block message, or return fallback. NEVER return original/pass-through on error in safety paths.

```python
# GOOD: Fail closed
except Exception:
    logger.error("PII redaction failed", exc_info=True)
    return "[PII_REDACTION_ERROR]"  # Safe placeholder

# BAD: Fail open (data leaks to LLM)
except Exception:
    return original_text  # PII passes through!
```

Note: This is OPPOSITE to the ML gate rule (fail OPEN for availability). Safety systems protect data; ML gates protect availability. Different failure modes for different risk profiles.

Origin: Hey Seven R20 — PII redaction fail-open would send SSN/credit card to LLM on regex error. All 4 models flagged as CRITICAL.

## Conftest Singleton Cleanup (MANDATORY for async test suites)

Create `autouse=True, scope='function'` fixture clearing ALL singleton caches between tests: LLM cache, circuit breaker, retriever, settings, embeddings, memory store, config cache.

```python
@pytest.fixture(autouse=True, scope="function")
def _clear_singletons():
    yield
    for cache_fn in [_get_llm, _get_circuit_breaker, _get_retriever, get_settings]:
        try:
            cache_fn.cache_clear()  # lru_cache
        except AttributeError:
            pass
    # Also clear TTLCache instances and module-level dicts
```

Singleton leakage is the #1 cause of flaky async tests. Circuit breaker state, stale LLM clients, and cached settings leak across tests.

Origin: Hey Seven R20 — 13 singleton caches identified. Without cleanup, test order determined pass/fail.

## TTL-Cached LLM Singletons (MANDATORY for cloud credential rotation)

Replace `@lru_cache(maxsize=1)` with `cachetools.TTLCache(maxsize=1, ttl=3600)` for LLM client singletons when using GCP Workload Identity, Azure MSI, or any rotating credential provider.

```python
from cachetools import TTLCache
_llm_cache = TTLCache(maxsize=1, ttl=3600)
_llm_lock = asyncio.Lock()

async def _get_llm():
    async with _llm_lock:
        if "llm" not in _llm_cache:
            _llm_cache["llm"] = ChatVertexAI(...)
        return _llm_cache["llm"]
```

`@lru_cache` never expires — credential rotation requires process restart. TTLCache gives 1-hour refresh window.

Origin: Hey Seven R20 — GCP Workload Identity credentials rotate, requiring periodic LLM client recreation.

## E2E Integration Test Through Full Pipeline (MANDATORY for 5+ nodes)

Write at least one integration test that sends a query through the FULL graph pipeline (all nodes) with mocked LLMs, verifying lifecycle events for every node start/complete.

```python
async def test_full_pipeline_lifecycle():
    result = await graph.chat("test query", config=test_config)
    events = collect_lifecycle_events(result)
    assert "router:start" in events
    assert "generate:complete" in events
    assert "validate:complete" in events
    # Verify WIRING, not just individual node logic
```

Unit tests verify nodes work individually. E2E tests verify WIRING works. Specialist dispatch bugs are invisible to unit tests.

Origin: Hey Seven R9-R20 — flagged as #1 testing gap across 4 consecutive review rounds.

## New query_type Wiring Checklist (MANDATORY when adding guardrail categories)

When adding a new `query_type` to `compliance_gate_node`:

1. **Detection**: Add `detect_*()` function in `guardrails.py` with pattern list
2. **Routing**: Add `detect_*()` call in `compliance_gate_node` at correct priority position
3. **Response**: Add `elif query_type == "new_type":` case in `off_topic_node` with appropriate response
4. **Export**: Add to `guardrails.__all__`
5. **Import**: Add to `compliance_gate.py` imports
6. **Test count**: Update `test_doc_accuracy.py` pattern count assertion
7. **Test response**: Add test that the new query_type produces the correct response (not generic fallback)

Missing ANY step = the guardrail detects but doesn't respond correctly.

Origin: Hey Seven R49-R50 (2026-02-24) — Added `detect_self_harm()` with 14 patterns and wired into compliance_gate, but forgot to add response handler in off_topic_node. 3/4 external models (Grok, Gemini, DeepSeek) found suicidal guests receiving "I'm your concierge" instead of 988 Lifeline. Fixed in R50.

## Scaffolded-to-Wired Checklist (MANDATORY before claiming "implemented")

When connecting scaffolded code (exists but never called) to production paths:

1. **Trace the call chain**: entry point → graph node → helper → scaffolded code
2. **Feature flag the wiring**: new feature flag with default=False or True depending on risk
3. **Accumulate state across turns**: for extracted fields, merge with existing (don't overwrite)
4. **Fail-silent at every new connection point**: try/except returning empty/neutral defaults
5. **Verify parity checks**: if the project uses schema parity (e.g., TypedDict ↔ defaults ↔ config), update ALL parity locations

```python
# Pattern: Accumulating extracted fields across conversation turns
extracted = extract_fields(user_message)
if extracted:
    existing = dict(state.get("extracted_fields", {}) or {})
    existing.update(extracted)  # New fields merge, don't overwrite
    state["extracted_fields"] = existing
```

Origin: Hey Seven Phase 3 (2026-02-22) — guest_profile.py (425 LOC) scaffolded with zero imports. Wiring required: state fields + graph initial_state + feature flags + parity checks across 3 locations.

## Regex Extraction False Positive Prevention

When building regex extractors for natural language (names, dates, quantities):

1. **Maintain exclusion wordlists**: common words, domain-specific terms that regex would misclassify
2. **Anchor after trigger phrases**: `(?:my name is|I'm)\s+([A-Z][a-z]+)` not just `([A-Z][a-z]+)`
3. **Use word boundaries and non-greedy capture**: `([A-Z][a-z]+)(?:\s|,|\.|$)` to prevent multi-word capture
4. **Pattern ordering matters**: put specific patterns before generic ones (e.g., "next Friday" before "visiting on...")
5. **Test with adversarial input**: "I'm vegetarian", "I'm here", "Sure thing" — common false positives

Origin: Hey Seven Phase 4 (2026-02-22) — "I'm vegetarian" matched name regex (capital V after "I'm"). "I'm Sarah and" captured "Sarah and" (greedy). "visiting next" captured "next" instead of "next Friday" (wrong pattern order).

## Environment Variable Isolation in Test Suites (MANDATORY)

`os.environ.setdefault()` at module import time does NOT work reliably in test suites — other tests may set the variable first, and setdefault is a no-op when the key exists.

```python
# BAD: Unreliable when run in full suite
os.environ.setdefault("API_KEY", "")  # No-op if another test set it

# GOOD: Per-test isolation via monkeypatch fixture
@pytest.fixture(autouse=True)
def _disable_api_key_auth(monkeypatch):
    monkeypatch.setenv("API_KEY", "")
    try:
        from src.config import get_settings
        get_settings.cache_clear()  # Settings cache must also be cleared
    except (ImportError, AttributeError):
        pass
    yield
```

Always clear cached settings after environment variable changes — `@lru_cache` settings won't see the new value.

Origin: Hey Seven Phase 5 (2026-02-22) — 9 SSE E2E tests passed in isolation, failed in full suite. `os.environ.setdefault("API_KEY", "")` was no-op because test_rag.py set it first.

## State Field Reducers for Accumulated Data (MANDATORY)

When a LangGraph state field accumulates data across turns (extracted fields, preferences, profile data), it MUST have a custom reducer. Without a reducer, each node return OVERWRITES the previous value instead of merging.

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

Without this, extracted guest name on turn 1 is lost when turn 2 extracts party size. The `_initial_state()` reset pattern only works for per-turn fields, NOT accumulated fields.

Origin: Hey Seven R19 (2026-02-22) — CRITICAL finding. extracted_fields had no reducer; multi-turn guest profiling was silently broken. Single highest-impact fix across R18-R20.

## Feature Flag Defaults Must Enable Wired Code (MANDATORY)

When code is fully wired (imports exist, graph nodes call it, tests cover it), the corresponding feature flag MUST default to `True`. A feature flag defaulting to `False` on wired code creates dead code that passes all reviews until someone traces the runtime path.

```python
# BAD: 425 LOC wired but never executes
guest_profile_enabled: bool = False  # "Safe default" = dead code

# GOOD: Wired code runs by default
guest_profile_enabled: bool = True  # Disable via config for specific environments
```

Origin: Hey Seven R19 (2026-02-22) — guest_profile.py (425 LOC) was fully wired but guest_profile_enabled=False meant it never executed. All R11-R18 reviews scored it as "implemented" when it was scaffolded.

## Proactive Suggestion Sentiment Gate: Positive-Only (MANDATORY)

When injecting unsolicited suggestions (proactive recommendations, cross-sell offers), the sentiment gate MUST require `"positive"` sentiment — never `"neutral"`:

```python
# GOOD: Positive evidence required
if state.get("guest_sentiment") == "positive":
    inject_suggestion()

# BAD: Neutral is absence of evidence, not positive evidence
if state.get("guest_sentiment") in ("positive", "neutral"):
    inject_suggestion()  # Mildly annoyed guests get upsold
```

"Neutral" on VADER means the classifier found no strong signal. Many frustrated-but-polite messages ("I've been waiting. What restaurants are open?") score neutral. Allowing suggestions on neutral means the system upsells guests who may be annoyed but aren't using strong negative language.

Origin: Hey Seven R23-R27 (2026-02-22) — R23 initially allowed neutral, R27 hostile review caught the contradiction with R23's own documentation ("require positive evidence"). Tightened to positive-only.

## Frustration Escalation from Message History (Pattern)

Count consecutive frustrated messages from conversation history instead of adding a state field with a custom reducer. The messages are already persisted across turns by the checkpointer.

```python
def _count_consecutive_frustrated(messages: list) -> int:
    count = 0
    for msg in reversed(messages):
        if isinstance(msg, HumanMessage):
            sentiment = detect_sentiment(msg.content)
            if sentiment in ("frustrated", "negative"):
                count += 1
            else:
                break
    return count
```

Advantages:
- No reducer complexity (no _keep_max, _replace_or_keep, or sentinel values needed)
- No state parity check updates (no new field in _initial_state)
- Deterministic: VADER is sub-1ms, re-running on 10 messages costs <10ms
- Correct by construction: always reflects the actual conversation, not a potentially stale counter

Use graduated response based on count: 2 = hear+empathize, 3+ = full HEART framework.

Origin: Hey Seven R21 (2026-02-22) — chose message history scan over state field to avoid reducer complexity. All reviewers approved the approach.

## Multi-Property Config: Always Use get_casino_profile(), Never DEFAULT_CONFIG (MANDATORY)

When injecting property-specific data (branding, helplines, persona name, regulations), ALWAYS use `get_casino_profile(settings.CASINO_ID)` — NEVER read `DEFAULT_CONFIG` directly:

```python
# GOOD: Property-specific
from src.casino.config import get_casino_profile
profile = get_casino_profile(settings.CASINO_ID)
branding = profile.get("branding", {})

# BAD: Hardcoded to default property
from src.casino.config import DEFAULT_CONFIG
branding = DEFAULT_CONFIG.get("branding", {})  # Always returns Mohegan Sun
```

Every import of `DEFAULT_CONFIG` for runtime data is a multi-tenant bug. Grep for `DEFAULT_CONFIG.get("branding` and `DEFAULT_CONFIG.get("regulations` — all should be replaced with `get_casino_profile()`.

Origin: Hey Seven R25-R31 (2026-02-22) — persona name hardcoded in 3 locations, responsible gaming helplines hardcoded to CT. R25 found it, R29 fixed 3 locations, but R31 found TWO MORE: (1) `get_responsible_gaming_helplines()` called without `casino_id` in `_base.py` — always returned CT helplines for NJ properties, (2) `persona.py` fallback `except` block still imported `DEFAULT_CONFIG`. Both fixed in R31. Lesson: grep for ALL imports of DEFAULT_CONFIG after every fix — the except/fallback paths are easy to miss.

## Also Grep Function Arguments for Missing Parameters (MANDATORY)

After fixing a function to accept per-tenant parameters (e.g., `casino_id`), grep ALL callers to verify they pass the parameter. Missing parameters silently fall back to defaults — the function works, but returns wrong-tenant data.

```bash
# After adding casino_id parameter to get_responsible_gaming_helplines():
grep -rn "get_responsible_gaming_helplines" --include="*.py" | grep -v "casino_id"
# Any results WITHOUT casino_id = bug
```

Origin: Hey Seven R31 (2026-02-22) — `get_responsible_gaming_helplines(casino_id=)` was added in R25 but `_base.py` still called it without the parameter. NJ properties received CT helplines for 6 review rounds until R31 caught it.

## Research Agent Output Contract: Use code-worker for File-Writing Tasks (MANDATORY)

`research-specialist` and `realtime-specialist` agents do NOT have Write/Edit tools. If research output must be written to a file, either:

1. Use `code-worker` subagent type (has Write tool) with research instructions
2. Use `general-purpose` subagent type (has all tools)
3. Accept that the parent must write the file from the agent's returned content

Never assume a research agent can write its own output file.

Origin: Hey Seven R21 (2026-02-22) — all 4 research agents completed research but couldn't write files. Parent had to write each file manually, wasting ~15 minutes total.

## NEVER asyncio.to_thread() for Redis in Async LangGraph Apps (MANDATORY)

`asyncio.to_thread()` spawns OS threads from the default `ThreadPoolExecutor`. Cloud Run instances have ~8-10 threads (min(32, cpu_count+4)). Under 50 concurrent requests, each Redis call via `to_thread()` competes for those threads, causing thread starvation and event loop blocking.

```python
# BAD: Exhausts thread pool under load
await asyncio.to_thread(self._redis_client.setex, key, ttl, value)

# GOOD: Native async, zero thread overhead
self._async_redis = redis.asyncio.Redis.from_url(url)
await self._async_redis.setex(key, ttl, value)

# GOOD for rate limiting: Atomic Lua script (1 round-trip instead of 4-5)
RATE_LIMIT_SCRIPT = """
local key = KEYS[1]
local now = tonumber(ARGV[1])
local window = tonumber(ARGV[2])
local max_tokens = tonumber(ARGV[3])
redis.call('ZREMRANGEBYSCORE', key, '-inf', now - window)
local count = redis.call('ZCARD', key)
if count < max_tokens then
    redis.call('ZADD', key, now, ARGV[4])
    redis.call('EXPIRE', key, window)
    return 1
end
return 0
"""
```

Origin: Hey Seven R47 (2026-02-24) — All 4 external models (Gemini, Grok, GPT-5.2, DeepSeek) flagged `to_thread()` for Redis as CRITICAL. Thread pool exhaustion under 50 concurrent SSE streams. Internal review (R46) introduced the pattern and scored it positively.

## Never Hold Async Lock Across I/O (MANDATORY)

```python
# BAD: Redis I/O inside lock = head-of-line blocking
async with self._lock:
    await self._sync_from_backend()  # Redis round-trip while locked
    # All other callers serialize on Redis latency

# GOOD: I/O outside lock, fast mutation inside
remote_state = await self._sync_from_backend()  # No lock
async with self._lock:
    self._apply_remote_state(remote_state)  # Fast dict mutation only
```

Origin: Hey Seven R47 (2026-02-24) — R46 moved _sync_from_backend inside lock (R45 MINOR fix). R47 GPT-5.2 flagged this as CRITICAL: 100ms Redis stall blocks all 50 concurrent callers.

## Fail-Closed with Degradation Mode for Security Classifiers (MANDATORY)

Fail-closed on individual failures is correct. But fail-closed on EVERY failure during sustained LLM outage = self-DoS that blocks ALL legitimate traffic.

```python
# BAD: Every failure rejects
except Exception:
    return InjectionResult(is_injection=True)  # ALL guests blocked during outage

# GOOD: Degrade after consecutive failures
_consecutive_failures = 0
async def classify(text):
    global _consecutive_failures
    try:
        result = await classifier_llm.ainvoke(text)
        _consecutive_failures = 0
        return result
    except Exception:
        _consecutive_failures += 1
        if _consecutive_failures >= 3:
            logger.warning("Classifier degraded — deterministic guardrails only")
            return InjectionResult(is_injection=False)  # Fall back to regex-only
        return InjectionResult(is_injection=True)  # Fail-closed for first 1-2
```

Origin: Hey Seven R47 (2026-02-24) — All 4 external models flagged fail-closed semantic classifier as availability risk. Gemini API outage = total service outage for all guests.

## Reducer Must Support Explicit Deletion (MANDATORY for accumulated state)

```python
# BAD: Filters None, making fields "sticky" — cannot unset
def _merge_dicts(existing, new):
    merged = dict(existing or {})
    merged.update({k: v for k, v in (new or {}).items() if v is not None})
    return merged

# GOOD: Tombstone pattern allows explicit deletion
_UNSET = "__UNSET__"

def _merge_dicts(existing, new):
    merged = dict(existing or {})
    for k, v in (new or {}).items():
        if v == _UNSET:
            merged.pop(k, None)  # Explicit deletion
        elif v is not None and v != "":
            merged[k] = v
    return merged
```

Origin: Hey Seven R47 (2026-02-24) — 3/4 external models flagged _merge_dicts sticky state as CRITICAL. Guest says "remove the peanut allergy" → LLM returns `{"dietary": None}` → old value persists indefinitely.

## Keyword-Triggered Emotional Context Guides (Pattern for AI Agents)

When an AI agent needs emotional intelligence beyond basic sentiment (positive/negative/neutral/frustrated), add a keyword-triggered emotional context layer SEPARATE from the sentiment system:

```python
EMOTIONAL_CONTEXT_GUIDES = {
    "grief": "Guest mentioned loss. Extra gentleness, no promotions...",
    "anxiety": "Guest seems nervous. Be reassuring, offer simple guidance...",
    "allergy_concern": "SAFETY matter. Recommend contacting venue directly...",
}

# Detect via keywords in user message, NOT via VADER
user_msg_lower = user_msg.lower()
if any(kw in user_msg_lower for kw in ("passed away", "lost my", "funeral")):
    emotional_guides.append(EMOTIONAL_CONTEXT_GUIDES["grief"])
```

Key design properties:
- **Separate from VADER**: VADER detects valence (positive/negative). Keywords detect domain-specific emotional contexts (grief, anxiety, allergy).
- **Additive, not replacing**: Tone guides from VADER + emotional context guides from keywords both inject into system prompt.
- **Fail-silent**: Missing keywords = no injection. No false positives.
- **Extensible**: Add new emotional contexts without changing the sentiment detection pipeline.

Origin: Hey Seven R70 (2026-02-26) — Behavioral review scored B5 (Emotional Intelligence) at 3/10. Only 4 sentiment categories. Added 5 emotional context guides (grief, anxiety, celebration, allergy_concern, gambling_frustration) via keyword detection. Both GPT-5.2 and Grok independently flagged the gap.

## Behavioral Scenario Forbidden Keywords vs Mock LLMs (MANDATORY)

Adversarial behavioral test scenarios (YAML files with `forbidden_keywords`) are for LIVE agent evaluation, not mock-based unit tests. Mock LLMs don't understand sentiment or emotional context — they generate responses from property data templates.

```yaml
# BAD: Mock LLM will include "happy to help" regardless of sarcasm detection
forbidden_keywords: ["happy to help", "excited"]

# GOOD: Only use expected_keywords with mock LLMs
expected_keywords: ["sorry", "help"]
# Put forbidden_keywords in a separate evaluation rubric, not in test fixtures
```

If the test framework uses mock LLMs, remove `forbidden_keywords` from scenario YAML files. Reserve them for live agent evaluation or LLM-as-judge evaluation frameworks.

Origin: Hey Seven R70 (2026-02-26) — 20 behavioral scenarios with forbidden_keywords broke mock-based test_conversation_scenarios.py. Mock LLM included "happy to help" in sarcasm scenario. Fixed by removing forbidden_keywords from YAML.
