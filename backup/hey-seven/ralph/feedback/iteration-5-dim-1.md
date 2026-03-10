# Iteration 5 — Dimension 1: Agent Architecture — Per-LLM Feedback

**Date**: 2026-02-17
**Document**: `/home/odedbe/projects/hey-seven/docs/plans/2026-02-17-v2-architecture-design.md`
**Section**: Lines 25-1771 (~1750 lines)
**Iteration 5 Fixes Applied**:
1. Added conditional edge function implementations inline (route_after_validate, route_after_router, etc.)
2. Added full CircuitBreakerConfig dataclass with all parameters (threshold, cooldown, half-open probes)
3. Added middleware-to-graph integration points with lifecycle diagram and hook code

---

## Score Summary

| LLM | Score | Gaps |
|-----|-------|------|
| GPT-5.2 | 9.5 | Whisper Planner-to-agent interface contract could be more formally specified |
| Grok-4 | 9.5 | None identified |
| Perplexity (Sonar Reasoning Pro) | 9.5 | None identified in summary |
| Gemini 3 Pro | 10.0 | None identified |
| GPT-5.2 Chat2 | 9.5 | None identified |
| Codex (GPT-5.2 Codex) | 9.5 | None identified |

**Mean**: 9.58 / 10
**Min**: 9.5 / 10
**Unanimous 9.5+**: YES (6/6)

---

## Per-LLM Detail

### 1. GPT-5.2

**SCORE**: 9.5

**GAPS**:
- No explicit mention of a separate "speaking agent" interface contract for the Whisper Track Planner beyond middleware injection + state field usage (planner-to-agent boundary could be even more formally specified, though described).

**STRENGTHS**:
- LangGraph In-Memory Swarm pattern is explicitly selected, contrasted vs alternatives, and operationalized with build_swarm() + create_handoff_tool() details and worked traces
- Outer StateGraph topology is fully enumerated (12 nodes, 15 edges) with code for all conditional routing functions and no production lambdas
- Inner agent modules are well specified: responsibilities, toolsets, extraction targets, and system prompt intent excerpts, including safe injection approach
- Silent handoff mechanism is described with Command anatomy, in-process state transfer, and end-to-end control flow steps
- LangGraph 1.0 middleware usage is concrete (before_model/after_model/wrap_tool_call) with casino-specific examples and hook ordering/integration diagrams
- State management is strong: TypedDict + Annotated reducers, explicit per-turn vs persistent fields, and reset function addressing a real leakage bug
- Whisper Track Planner is architected (Pydantic model, entry/exit conditions, conflict rules, lifecycle scenarios, cancellation semantics) and integrated via state + middleware injection
- Validation loop is fully specified with retry limit, validator configuration, fail-open/closed behavior, recursion limit analysis, and retry feedback mechanism
- Error handling is comprehensive at node boundaries and middleware boundaries, with circuit breaker implementation, exception taxonomy, and propagation semantics
- Clear justification for architecture choice over Supervisor/pure custom/executor alternatives with measurable constraints (SMS latency/tool scale) and mitigations

**SUGGESTION**:
Tighten the Whisper Planner-to-speaking agents contract by explicitly naming the planner node/tool boundary and documenting a stable schema/versioning strategy for whisper_plan consumption (e.g., required vs optional fields, validation at agent entry), so the integration point is as code-level explicit as the rest of the document.

---

### 2. Grok-4

**SCORE**: 9.5

**GAPS**: None

**STRENGTHS**:
- Comprehensive coverage of all rubric items with code-level details like inline Python functions, Pydantic models, and full implementations
- Strong rationale for architecture choices via comparison tables and ADR
- Detailed diagrams, tables, and examples enhance clarity and specificity

**SUGGESTION**:
Consider adding performance benchmarks for middleware hooks to quantify casino-specific impacts like latency in SMS scenarios.

---

### 3. Perplexity (Sonar Reasoning Pro)

**SCORE**: 9.5

**GAPS**: None identified in summary

**STRENGTHS**:
- Comprehensive coverage of all 10 rubric requirements with architectural decision rationale
- Complete state schema with typed reducers
- Explicit conditional routing logic with empirical accuracy metrics (94% to 61%)
- Full middleware hook implementations with casino-specific compliance examples
- Circuit breaker with formal 3-state machine and configurable thresholds
- Validation loop with retry limits and fallback semantics
- Error handling per node with exception hierarchy
- Explicit architecture justification (rejection of Supervisor on latency, Pure Custom on god-node risk, Agent Executor on tool scaling)
- Dual-graph topology clearly illustrated with 12 nodes, 15 named edges, and state transfer worked example

**SUGGESTION**:
If implementation code exists beyond the summary, include actual Python function signatures for create_handoff_tool(), route_after_compliance(), middleware hook registration, and CircuitBreaker class to elevate from 9.5 to 10.0. Verify empirical router accuracy drop (94% to 61%) with production data if available for consequences section evidence.

---

### 4. Gemini 3 Pro

**SCORE**: 10.0

**GAPS**: None

**STRENGTHS**:
- The architecture justification (ADR-001) is exemplary, referencing specific metrics (latency, debuggability) to defend the In-Memory Swarm pattern against alternatives like Supervisors
- Middleware implementation (LangGraph 1.0 hooks) is deeply integrated with the domain context, solving specific problems like regulatory compliance (NJ DGE) and cost attribution via wrap_tool_call
- State management clearly distinguishes between persistent conversation history and ephemeral per-turn metadata, with a dedicated _initial_state reset mechanism to prevent context pollution
- The validation loop is robust, featuring a defined retry strategy (max 1), fallback logic, and separate validator LLM configuration
- Error handling is comprehensive, covering every node boundary with a specific behavior table and a fully specified Circuit Breaker pattern

**SUGGESTION**:
Ensure the route_after_handoff logic explicitly handles edge cases where a Command object might attempt to update active_agent to a node that is temporarily disabled by the Circuit Breaker, potentially adding a check within the handoff tool itself.

---

### 5. GPT-5.2 Chat2

**SCORE**: 9.5

**GAPS**: None

**STRENGTHS**:
- Exhaustive LangGraph In-Memory Swarm description with concrete code-level detail
- Complete outer StateGraph topology with named nodes/edges and pure conditional routing functions
- Precise inner agent module responsibilities with tools and system prompt intent
- Clear in-process silent handoff via create_handoff_tool() and Command anatomy
- Thorough LangGraph 1.0 middleware usage with casino-specific before_model/after_model/wrap_tool_call examples
- Fully specified TypedDict state schema with reducers and per-turn vs persistent fields
- Well-defined Whisper Track Planner architecture and integration
- Robust validation loop with retry/fallback limits
- Comprehensive per-node error handling and circuit breaker design
- Strong justification versus supervisor and custom alternatives

**SUGGESTION**:
If aiming beyond 9.5, consider adding empirical performance/latency benchmarks, testing/monitoring plans, and a small code appendix showing real hook implementations to move from design-level specificity to drop-in implementation.

---

### 6. Codex (GPT-5.2 Codex)

**SCORE**: 9.5

**GAPS**: None

**STRENGTHS**:
- Complete rubric coverage: explicit StateGraph nodes/edges/conditionals and agent module responsibilities/tools/prompts
- Clear in-process handoff mechanics with stepwise trace and middleware hooks (before/after/wrap) tied to casino constraints
- Strong state management (TypedDict + reducers), validation loop, WhisperPlan integration, and exhaustive per-node error handling
- Well-argued architecture choice with mitigations and concrete build_graph/build_swarm assembly

**SUGGESTION**:
To push beyond a 9.5, add concrete performance/latency benchmarks, testing/monitoring plans, and a small code appendix showing real hook implementations to move from design-level specificity to drop-in implementation.

---

## Iteration 5 Fix Validation

All three iteration-5 fixes addressed the gaps that caused Codex to score 9.0 in iteration 4:

| Fix | Validated By |
|-----|-------------|
| Conditional edge function implementations inline | GPT-5.2 praised "code for all conditional routing functions and no production lambdas". Codex noted "explicit StateGraph nodes/edges/conditionals". |
| Full CircuitBreakerConfig dataclass | GPT-5.2 praised "circuit breaker implementation, exception taxonomy". Gemini noted "fully specified Circuit Breaker pattern". |
| Middleware-to-graph integration points | GPT-5.2 praised "hook ordering/integration diagrams". Multiple LLMs noted middleware integration clarity. |

**Conclusion**: All three fixes landed successfully. Codex moved from 9.0 to 9.5. Dimension 1 now scores 9.5+ unanimously across all 6 LLMs.

---

## Optional Future Improvements (not required for 9.5)

These are suggestions for a theoretical 10.0 push (only Gemini gave 10.0 already):

1. **Performance benchmarks**: Add latency numbers for middleware hooks and overall graph traversal (suggested by Grok-4, GPT-5.2 Chat2, Codex)
2. **Whisper Planner interface formalization**: Document required vs optional fields, schema versioning for whisper_plan consumption (suggested by GPT-5.2)
3. **Circuit breaker + handoff edge case**: Handle Command routing to a circuit-breaker-disabled agent node (suggested by Gemini 3 Pro)
4. **Empirical router accuracy**: Provide production data backing the 94% to 61% accuracy drop at confidence < 0.3 (suggested by Perplexity)
