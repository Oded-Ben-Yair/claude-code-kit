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

## Unconditional Instructions Supplement Gated Mechanisms (Pattern)

When a gated mechanism (whisper planner, proactive suggestions) has multiple conditions that rarely all pass simultaneously, add an unconditional instruction in the system prompt as a fallback. The gated mechanism provides precision when it fires; the unconditional instruction provides coverage when it doesn't.

```python
# GATED (fires ~10% of turns — requires whisper_plan + question + technique != none + sentiment OK):
if whisper and whisper.get("next_profiling_question"):
    if technique != "none" and sentiment not in ("frustrated", "negative"):
        system_prompt += f"REQUIRED: Ask This Question: {question}"

# UNCONDITIONAL (fires 100% — always in system prompt):
system_prompt += (
    "## Natural Follow-Up\n"
    "End every response with ONE natural follow-up question..."
)
```

The unconditional instruction is less precise (no specific question from planner) but ensures the behavior happens every turn. The gated mechanism overrides with a specific question when conditions align.

Origin: Hey Seven R85 (2026-03-03) — Profiling question injection had 4 gates: whisper_plan exists AND next_profiling_question AND technique != "none" AND sentiment not negative. Rarely all passed. Adding unconditional "always ask a follow-up" pushed P2 active probing from 2.0 to 4.2.

## Tool-Empowered Authority Model: CCD Pattern (MANDATORY for tool-using agents)

When a LangGraph agent has @tool functions that return real data, the authority model must align prompts, examples, validation criteria, and training data to the same authority level. The Checked-Confirmed-Dispatched (CCD) pattern:

1. **Checked** (agent calls tool): "Let me pull up your account..."
2. **Confirmed** (states tool result as fact): "You've earned $25 in dining credit at Emerald tier."
3. **Dispatched** (decisive handoff for non-tool actions): "I'll get the host team to set that up before dinner."

```python
# Authority tiers for tool-using agents:
# Tier 1 (Tool-verified): Agent states results as facts
#   "Your tier includes spa access" — tool returned this data
# Tier 2 (Host-facilitated): Agent decides, team executes
#   "I'll get the team to hold your table" — decisive delegation
# Tier 3 (Cannot do): Transparent limitation
#   "That's outside what I can help with"
```

**Propagation checklist** after any authority change:
1. Main system prompt (Rule 2, examples, NEVER list)
2. ALL specialist agent prompts (grep `ONLY provide information` or equivalent)
3. Validation criteria (was "Read-only", now "Authority-appropriate")
4. Gold traces / training data (remove "booked", "loaded", "I'll text you")
5. Eval rubrics (judge must score new authority, not old)

Origin: Hey Seven R107 (2026-03-09) — External audit scored 6.4/10 HOLD due to authority contradiction. Prompts said "never book," examples said "booked." CCD pattern resolved all contradictions. Research confirmed 3-tier model is industry standard (Acres, Gaming Analytics, Cosmopolitan Rose).

## Deterministic Tools Require Model Capability to Integrate (MANDATORY)

When building deterministic business-logic tools that inject structured prompt sections (comp offers, rapport patterns, LTV nudges), the tool provides DATA but the LLM provides INTEGRATION. A smaller model (Flash) may read the section but generate the same generic response regardless.

```python
# Tool injects structured data into system prompt:
system_prompt += "\n\n## Comp Strategy\n- Dining credit $25 (auto-approve)..."
system_prompt += "\n\n## Rapport Technique: callback\nExample: ..."
system_prompt += "\n\n## Return Visit: upcoming show..."

# Flash: reads sections, responds generically → H9 goes 1.9 → 2.16
# Pro: reads sections, integrates naturally → H9 expected 5.0+
```

**Pattern**: Build tools with Flash, validate with Pro. If Flash can't leverage the data, switch to Pro for the integration layer. Then distill Pro behavior back to Flash via fine-tuning.

**Testing trap**: Deterministic tool tests pass (119/119) because they test the tool output, not the LLM's use of it. Always validate with live eval, not just unit tests.

Origin: Hey Seven R98 (2026-03-06) — 4 behavior tools (CompStrategy, HandoffOrchestrator, LTV Nudge, Rapport Ladder) all wired correctly. Flash eval: H9 1.9→2.16, H10 3.5→3.77, H6 4.0→4.07. Tools provide data but Flash doesn't integrate into natural conversation. Pro switch is the critical next step.

**R103 confirmation** (2026-03-08): Added comp bridge injection (3 lines for non-comp agents) + handoff prompt wiring + field name fix. P8 +1.0 (field alignment = pure data fix). H9 stayed 2.0, P9 stayed 2.65 with Flash — **confirmed**: Flash ignores even lightweight 3-line prompt sections for comp/handoff. The R98 finding is not just about multi-section complexity; Flash fundamentally doesn't integrate injected context into natural responses. Pro eval (R104) is the definitive test.

## Streaming Eval+Judge Pipeline (Pattern)

For eval rounds with 50+ scenarios, use streaming judge that scores results as they arrive instead of sequential eval-then-judge:

```bash
# Terminal 1: Run eval (writes results as they complete)
python3 tests/evaluation/run_live_eval.py --pattern "*.yaml" --round r99

# Terminal 2: Stream-judge as results arrive (batch-parallel 5 at a time)
python3 tests/evaluation/streaming_judge.py --watch <results-dir> --category behavioral
```

**Benefits**: 40-60% wall-clock reduction, real-time dimension scores, early-stop if regression detected (rolling avg < 3.0 for 5 consecutive scenarios).

**Anti-pattern**: Running all 109 scenarios → waiting 2 hours → then running judge for 10 minutes. By the time you see scores, you've wasted 2 hours on a bad configuration.

Origin: Hey Seven R98 (2026-03-06) — Sequential pipeline took 160+ min (109 scenarios × 80s + judge). Streaming judge catches regressions after 5 scenarios, not 109.

## Compliance Gate Bypass Creates Language Detection Gap (MANDATORY for safety)

When `compliance_gate_node` short-circuits a message (crisis, BSA/AML, responsible gaming), the router never runs. Any state fields set by the router (detected_language, query_confidence) remain at their initial values. Add local detection heuristics in downstream nodes for safety-critical branches.

```python
# In off_topic_node, self_harm branch:
# detected_language is None because compliance_gate bypassed the router
if not _is_spanish and user_message:
    _SPANISH_INDICATORS = ("ayuda", "necesito", "hablar", "por favor", "estoy")
    if any(ind in user_message.lower() for ind in _SPANISH_INDICATORS):
        _is_spanish = True  # Local heuristic fills the router gap
```

Origin: Hey Seven R85 (2026-03-03) — Spanish-speaking guests in crisis ALWAYS got English responses because detected_language was never set (compliance_gate short-circuits before router). Local Spanish heuristic fixed Safety from 42% to 95%.

## Short-Circuit Detector Must Check for Follow-Up Questions (MANDATORY)

When a compliance gate short-circuits messages (confirmations, greetings), check for embedded questions before matching. "Sounds good. What about after dinner?" starts with a confirmation pattern but contains a real question that needs specialist routing.

```python
# BAD: "Sounds good. What about dinner?" matched as pure confirmation
if msg.startswith("sounds ") and len(msg.split()) < 8:
    return confirmation_response  # Guest's question is lost

# GOOD: Check for question signals first
_has_question = "?" in msg or any(qw in msg for qw in ("what ", "where ", "when ", "how "))
if not _has_question and msg.startswith("sounds ") and len(msg.split()) < 8:
    return confirmation_response
```

Origin: Hey Seven R102 (2026-03-08) — 3 of 5 eval transcripts lost turns 4-5 to the confirmation detector. "Sounds good. What about after dinner?" got canned response instead of specialist routing. Simple question-word check fixed it.

## Extraction Prompt Precision > Recall for Identity Fields (MANDATORY)

LLM extraction prompts that say "when in doubt, EXTRACT IT" will parse common phrases as names. "I'm done" → guest_name: "Done". For identity fields (name, contact), precision matters more than recall — a wrong name used repeatedly is worse than no name.

```python
# In extraction prompt, add explicit exclusions:
### Do NOT extract:
- "I'm done" / "I'm good" / "I'm fine" / "I'm set" → guest_name: null (NOT names)
- Generic sentiments as preferences: "whatever" / "anything" → null (too vague)
```

Origin: Hey Seven R102 (2026-03-08) — "I'm done" extracted as name "Done". Agent addressed frustrated guest as "Done" for 3 turns. All 4 Codex external reviews flagged extraction as over-aggressive.

## Identity Prompt = Behavioral Ceiling (Pattern)

The model's self-concept ("I am a concierge" vs "I am a host") sets the behavioral ceiling. A concierge answers questions. A host builds relationships. Changing one line of identity from "knowledgeable concierge" to "casino host building a relationship" produced B-avg +0.72 and P-avg +0.80 in a single round.

Three Jobs Every Turn pattern:
1. Address the immediate need
2. Learn something new (ONE natural question)
3. Use what you know to personalize

Origin: Hey Seven R102 (2026-03-08) — R101 found root cause: agent at 5.9 had solved TONE but not RELATIONSHIP. Identity rewrite + profiling question bank + gold trace examples shifted behavior. P3 give-to-get hit 7.4.

## Prompt Engineering Ceiling for Sub-5.0 Dimensions (MANDATORY)

When a behavioral dimension stays below 5.0 after 3+ rounds of prompt-only changes, it is NOT a prompt problem — it's an architecture problem. Prompt engineering has a ceiling:

| Approach | Ceiling | Evidence |
|----------|---------|----------|
| Identity rewrite | +0.8 one-time | R102: "host" vs "concierge" |
| Few-shot examples | +0.3 | R83/R94: 27 examples |
| Instruction refinement | ±0.1 | R105: 7 dimensions, all ±0.3 |
| Section injection | ±0.1 | R98-R105: tools inject data, model ignores |
| Aggressive vs conversational framing | 0.0 | R105: "MUST mention" ≈ "if it feels natural" |
| "Generous" vs "balanced" extraction | 0.0 | R105: both produce same extraction rate |

**Architecture changes that CAN break the ceiling:**
- Tool-use: Agent calls tools mid-conversation (real comp lookup, real booking)
- RAG-grounded data: Agent retrieves REAL comp tiers, not policy templates
- Fine-tuning: Gold trace distillation (3/6/9 scored conversations)
- Multi-agent: Specialist hand-off with structured context passing

**Anti-pattern**: Spending N rounds changing prompt wording for a sub-5.0 dim. If 3 rounds of prompts didn't move it, stop prompting and change architecture.

Origin: Hey Seven R105 (2026-03-09) — 7 prompt-level changes to 7 sub-5.0 dims, +1734 LOC, +252 tests. Result: ALL 7 dims ±0.3 (within noise). R98/R103 found same pattern for Flash; R105 confirms for Pro too. The ceiling is the architecture, not the prompt.

## System Prompt Injection Must Happen BEFORE LLM Call (MANDATORY)

When injecting context into the system prompt (handoff, comp bridge, validation feedback), the injection MUST happen BEFORE `llm.ainvoke(llm_messages)`. Appending to `llm_messages` AFTER the call is dead code — the LLM never sees it.

```python
# BAD: Dead code — LLM already generated response
response = await llm.ainvoke(llm_messages)
llm_messages.append(SystemMessage(content=handoff_prompt))  # NEVER SEEN

# GOOD: Inject before LLM call
if handoff_detected:
    llm_messages.append(SystemMessage(content=handoff_prompt))
response = await llm.ainvoke(llm_messages)
```

**Testing trap**: Unit tests verify the handoff data is in `result["handoff_request"]` but don't test whether the LLM received the prompt. Add integration tests that assert the LLM response CONTAINS handoff language.

Origin: Hey Seven R105 (2026-03-09) — Handoff prompts (frustration + 4 new modes) appended to llm_messages at line 1460, but llm.ainvoke was at line 1317. Dead code for 2+ rounds. Code-judge caught it; 3789 tests missed it.

## Soft Handoff Triggers Need State Guards (Pattern)

When adding non-urgent handoff triggers (farewell, long conversation), they MUST have state guards to prevent re-triggering every turn:

```python
# BAD: Fires on every turn after turn 7
if turn_count >= 7:
    return HandoffMode.LONG_CONVERSATION

# GOOD: Sticky flag prevents re-trigger
if turn_count >= 7 and not state.get("handoff_offered"):
    return HandoffMode.LONG_CONVERSATION
# In result: result["handoff_offered"] = True  # _keep_truthy reducer
```

For farewell detection, also guard against over-matching:
- Word-count guard: only trigger on SHORT messages (<10 words)
- Follow-up word check: "thanks, what about dinner?" is NOT farewell
- Question mark check: "thanks?" is NOT farewell
- VIP_REQUEST and FRUSTRATION always override (higher priority)

Origin: Hey Seven R105 (2026-03-09) — Code review caught: LONG_CONVERSATION fired every turn 7+; farewell "thanks" matched inside longer messages. Both would have tanked behavioral scores.

## Shared Base Function = Blast Radius Multiplier (MANDATORY awareness)

When specialist agents share a base execution function (`execute_specialist()` in `_base.py`), ANY change to that function affects ALL specialists. Treat changes to the shared base as high-risk:

1. **Mock test cascade**: Adding state access (e.g., `state.get("extracted_fields")`) breaks every mock-based specialist test because mocks don't set up all state fields
2. **Before editing _base.py**: grep all test files that import from specialist agents — they ALL run through `execute_specialist()`
3. **Prefer injection points over base changes**: If a feature only applies to some specialists, add it via config/flag in the agent-specific wrapper, not in the shared base

Origin: Hey Seven R110 (2026-03-09) — Profile-reference injection in `_base.py` broke ~60 mock tests across 8 files. Required 4 iteration rounds to skip all failures. Full mock purge is the permanent fix.
