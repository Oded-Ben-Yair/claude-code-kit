# Iteration 3 Feedback -- Dimensions 1-4

Graded by 6 LLMs on 2026-02-17. Source: design doc after iteration 3 fixes (12,687 lines).

---

## Dimension 1: Agent Architecture

### GPT-5.2: 9.0
- **GAPS**: Whisper Track Planner placement/edges not explicit in topology (entry/exit conditions, concurrency mechanism in LangGraph terms underspecified). Error handling at node boundaries described declaratively in table but lacks node-by-node boundary specifics (exception classes, edge propagation, middleware vs model errors).
- **STRENGTHS**: Clear ADR-001 with latency/observability tradeoffs. Strong StateGraph coverage (named nodes, conditional routing, recursion_limit). Concrete state management (TypedDict, reducers, per-turn reset). Specific silent handoff mechanism. Casino-grounded middleware examples. Well-formed validation loop.
- **SUGGESTION**: Add code-level LangGraph-1.0-specific description of Whisper Planner as a first-class node with edges/conditions, scheduling mechanism, and state write/read contract alongside error semantics.

### Grok-4: 9.0
- **GAPS**: Whisper Track Planner architecture and interfacing with speaking agents only has structured output mentioned, not full details. State management persistent fields distinction only implicit.
- **STRENGTHS**: Detailed outer StateGraph topology with 12 nodes, 15 edges, and conditions. Comprehensive middleware with casino-specific examples. Strong architecture alternatives rationale via ADR-001. Thorough error handling table.
- **SUGGESTION**: Explicitly describe the Whisper Track Planner's architecture and its interfacing mechanisms with speaking agents.

### Perplexity: 9.5
- **GAPS**: No observability hooks at middleware boundaries. No explicit async/await patterns for WhisperPlan parallel execution. No quantified performance metrics validating In-Memory Swarm choice. Unclear whether fallback_node can retry or terminates.
- **STRENGTHS**: Complete StateGraph with all 12 nodes and 15 edges. Dual state model (persistent vs per-turn with explicit reset). Silent handoff fully detailed. All three middleware layers with regulatory examples. Validation loop with typed skip_validation. Error handling table with circuit breaker. ADR-001 with named alternatives.
- **SUGGESTION**: Add async/await delegation docs for WhisperPlan and one end-to-end latency trace showing <500ms P99.

### Gemini 3 Pro: 9.5
- **GAPS**: Summary does not confirm document explains underlying state transition mechanics (Command object or active_agent pointer update) for create_handoff_tool().
- **STRENGTHS**: Exceptional validation loop detail (MAX_RETRIES=1, temp=0.0, degraded-pass). Robust middleware with domain-relevant examples. Comprehensive StateGraph topology with ASCII diagram and edge definitions.
- **SUGGESTION**: Explicitly detail the payload flow (e.g., Command(goto="agent_name") return object) within the silent handoff section.

### GPT-5.2 Chat2: 9.0
- **GAPS**: Silent handoff in-process mechanics (state transfer, message cloning, cursor advancement, control return to outer graph) not fully specified. Error handling more declarative than concrete. Whisper Track Planner lifecycle timing (ordering, cancellation, conflict resolution) could be stronger.
- **STRENGTHS**: Defensible rationale for In-Memory Swarm with quantified tradeoffs. Complete 12-node topology. Strong state management discipline. Excellent middleware with regulatory examples. Well-defined agent modules. Robust validation loop. Comprehensive assembly code with HITL. SMS-first considerations consistently applied.
- **SUGGESTION**: Add code-level walkthrough of create_handoff_tool() showing state, message, and control transfer in-process.

### Codex: 8.5
- **GAPS**: In-Memory Swarm pattern code-level specificity (summary format). StateGraph conditionals not explicitly explained. Silent handoff lacks in-process mechanics. Middleware lacks casino-specific detail in summary. Whisper Planner interface only referenced. Validation loop flow not fully spelled out.
- **STRENGTHS**: Clear architecture comparison (ADR-001). Detailed StateGraph inventory. State schema and reducers called out. Validation retry limits and error handling mentioned. Multiple agents/tools/prompts enumerated. HITL and circuit breaker referenced.
- **SUGGESTION**: Add concrete walkthrough with specific conditional edge, create_handoff_tool() code snippet, and casino-specific middleware example.

### Dimension 1 Score Summary
| Model | Score |
|-------|-------|
| GPT-5.2 | 9.0 |
| Grok-4 | 9.0 |
| Perplexity | 9.5 |
| Gemini 3 Pro | 9.5 |
| GPT-5.2 Chat2 | 9.0 |
| Codex | 8.5 |
| **Median** | **9.0** |
| **Mean** | **9.08** |

---

## Dimension 2: Data Model

### GPT-5.2: 9.5
- **GAPS**: Minor ambiguity on canonical identifier (section 1 uses phone as _id, section 14 moves to guest_uuid). Consent per field mechanism implied rather than spelled out as exact nested schema.
- **STRENGTHS**: Detailed guest profile with explicit fields, nesting, timestamps, versioning. Progressive profiling with confidence/source/decay/contradiction. Clear conversation state (thread_id, windowing, TTL). Strong content model with per-category documents. Unusually complete indexing (vector params, composite indexes, QPS mapping). Explicit data lifecycle with CCPA cascade. Privacy includes PII inventory, tokenization, access controls, redaction, retention matrix.
- **SUGGESTION**: Publish single "current canonical schemas" section reconciling ID strategy and explicitly show per-field consent storage.

### Grok-4: 9.0
- **GAPS**: Specific collection/subcollection details not explicitly listed in hierarchy (only per-casino databases mentioned). Consent tracking included but not explicitly detailed as per-field tracking.
- **STRENGTHS**: Detailed guest profile with exact nested fields. Comprehensive progressive profiling with TypedDict and confidence mechanics. Thorough conversation state. Content model examples per category. Specific indexes with gcloud commands. Detailed lifecycle with code. Clear cross-references. Strong privacy elements. Solid migration strategy.
- **SUGGESTION**: Provide explicit collection/subcollection mapping and add per-field consent tracking details.

### Perplexity: UNAVAIL
- Perplexity was not called for Dimension 2 (tool refused to grade on summaries; would require full document text).

### Gemini 3 Pro: 9.5
- **GAPS**: ProfileField TypedDict does not explicitly include a specific metadata attribute for "consent tracking per field" (e.g., linking a value to a consent grant ID), distinct from source tracking.
- **STRENGTHS**: Exceptional operational specificity (gcloud commands, QPS mappings, cost analysis). Rigorous progressive profiling math. Robust privacy architecture (7-step CCPA cascade, PII inventory, field-level retention). Comprehensive Firestore hierarchy and phone-as-key anti-pattern handling.
- **SUGGESTION**: Enhance ProfileField TypedDict with consent_ref or legal_basis field linking data attributes to consent grants.

### GPT-5.2 Chat2: 9.5
- **GAPS**: Vector embedding lifecycle (deletion/backfill on archival/migration) not clearly specified. Index migration/backfill during schema evolution not detailed. No consent scope for companion-related PII.
- **STRENGTHS**: Exceptionally complete guest profile schema. Strong progressive profiling. Well-defined conversation state management. Clear Firestore hierarchy. Thorough content model. Comprehensive index strategy. Robust data lifecycle. Clear cross-referencing. Strong privacy posture. Forward-looking migration strategy.
- **SUGGESTION**: Add embedding/index maintenance during archival/migration and clarify companion PII consent.

### Codex: 8.0
- **GAPS**: Graded the prompt format rather than document content (received summary, wanted actual schemas inline). Missing actual JSON, index definitions, Firestore constraints analysis. No consistency checks between sections.
- **STRENGTHS**: Clear rubric coverage list. Concise summary. Actionable scope items.
- **SUGGESTION**: Include actual JSON schema blocks and index definitions inline. Add rubric-to-section mapping.

### Dimension 2 Score Summary
| Model | Score |
|-------|-------|
| GPT-5.2 | 9.5 |
| Grok-4 | 9.0 |
| Perplexity | UNAVAIL |
| Gemini 3 Pro | 9.5 |
| GPT-5.2 Chat2 | 9.5 |
| Codex | 8.0 |
| **Median** | **9.5** |
| **Mean** | **9.10** |

---

## Dimension 3: SMS/Communication Design

### GPT-5.2: 9.5
- **GAPS**: No meaningful gaps. All required areas explicitly addressed with implementation details.
- **STRENGTHS**: End-to-end Telnyx integration. Unusually complete 10DLC coverage. Well-structured TCPA with tiered consent. Robust GSM-7/UCS-2 handling. Deliverability safeguards beyond basics (Thompson Sampling). Multi-level rate limits. Clear cost model.
- **SUGGESTION**: Add explicit "fallback channel" decision tree (voice/email) tied to DLR failure classes and consent constraints.

### Grok-4: 9.5
- **GAPS**: Delay pipeline position not explicitly described. Rate limiting doesn't explicitly call out all scopes. First-message trigger mechanism not detailed. Cost model lacks per-message breakdown. Session context loading not mentioned.
- **STRENGTHS**: Comprehensive Telnyx integration with DLR handling and idempotency. Thorough 10DLC and TCPA. Strong carrier filtering with A/B testing. Excellent multilingual. Production-ready monitoring.
- **SUGGESTION**: Add details on delay pipeline position, rate limiting scopes, first-message triggers, per-message costs, and context loading.

### Perplexity: 8.5
- **GAPS**: 10DLC lacks implementation specificity (no code, no TCR integration logic). Session management vague (no state machine or resume logic). Delay formula lacks behavioral validation. Carrier filtering weights unjustified. Cost model unverified. Multilingual lacks precision/recall metrics. First-message omits template examples.
- **STRENGTHS**: 14-step webhook flow with HMAC and DLR. TCPA three-tier consent with opt-in metadata. Multi-layered rate limiting. Error resilience with backoff and DLQ. GSM-7 optimization. Monitoring with incident response.
- **SUGGESTION**: Add 10DLC flowchart, session state machine, delay validation data, carrier risk factor enumeration, and cost breakdown.

### Gemini 3 Pro: 9.5
- **GAPS**: No provider/channel fallback if Telnyx has total outage or carrier block. No secondary aggregator specified.
- **STRENGTHS**: Exceptional TCPA/10DLC compliance depth (consent decay, eligibility gating, non-keyword opt-out). Superior human-like behavior (Thompson Sampling, jitter formula). Production-ready webhook security (HMAC dual-key, idempotency).
- **SUGGESTION**: Define circuit breaker pattern for provider redundancy (auto-route to backup provider on high error rate).

### GPT-5.2 Chat2: 9.5
- **GAPS**: Carrier filtering enforcement specifics limited. Error taxonomy not explicitly enumerated. Multilingual expansion strategy not discussed.
- **STRENGTHS**: Complete Telnyx + 10DLC coverage. Strong TCPA compliance. Messaging correctness (GSM-7/UCS-2). Realistic delay model. Advanced deliverability awareness. Production-grade controls. Clear cost model. EN+ES fully satisfied.
- **SUGGESTION**: Add carrier-specific enforcement actions and formal error taxonomy with retry/fail-fast rules.

### Codex: 8.5
- **GAPS**: Telnyx webhook signature verification rules not fully defined (exact headers, canonical string). Carrier filtering weights lack calibration details. Rate limiting burst behavior and distributed consistency not addressed. GSM-7 edge cases (emoji, combining marks) not covered. Consent opt-out regex brittle (no Unicode normalization). Exponential backoff lacks max delay cap. Consent storage security not fully specified.
- **STRENGTHS**: Comprehensive coverage matching rubric. Operational realism (HMAC, dual-key, idempotency). Compliance-aware (TCPA, AI disclosure). Performance protections (rate limiting, carrier filtering).
- **SUGGESTION**: Define Telnyx signature verification precisely, add retry/backoff caps, expand GSM-7 edge cases, clarify carrier filtering evaluation, add consent storage security.

### Dimension 3 Score Summary
| Model | Score |
|-------|-------|
| GPT-5.2 | 9.5 |
| Grok-4 | 9.5 |
| Perplexity | 8.5 |
| Gemini 3 Pro | 9.5 |
| GPT-5.2 Chat2 | 9.5 |
| Codex | 8.5 |
| **Median** | **9.5** |
| **Mean** | **9.17** |

---

## Dimension 4: RAG/Embeddings Pipeline

### GPT-5.2: 9.5
- **GAPS**: None against rubric. Every required bullet explicitly covered with implementation details.
- **STRENGTHS**: Production-oriented Matryoshka justification tied to Firestore constraints. Firestore vector search with index config, query code, and limitations reasoning. Strong structured-data chunking rationale. Category formatters as registry/router. SHA-256 for idempotent ingestion. RRF fully specified with k=60 and multi-strategy. Multi-tenant property_id filtering. Relevance thresholds with calibration methodology. Testing and ops maturity (FakeEmbeddings, latency SLOs, cache design, monitoring).
- **SUGGESTION**: Add "Firestore vector search gotchas" checklist (distance semantics, index build times, max neighbors, pagination interactions).

### Grok-4: 9.0
- **GAPS**: RRF multi-strategy fusion mechanics not explicitly described (how strategies are combined). Re-indexing lacks explicit incremental webhook trigger coverage. Firestore limitations not directly listed beyond 2048-dim mention. Minor: 6 formatters vs 7 data types misalignment.
- **STRENGTHS**: Comprehensive embedding model details. Strong per-item chunking with rationale. Excellent SHA-256 idempotency. Thorough quality filtering with calibration. Solid multi-tenant filtering, cost comparison, testing, performance. Exceeds rubric with IR metrics, faithfulness, E2E pipeline, error handling, monitoring.
- **SUGGESTION**: Expand re-indexing to detail incremental webhook flows, clarify RRF multi-strategy fusion, add Firestore limitations subsection.

### Perplexity: UNAVAIL
- Perplexity refused to grade (requires full document text, not summaries). Two retry attempts failed.

### Gemini 3 Pro: 9.0
- **GAPS**: Document details batch reindex_all() and ingest_items() but does not explicitly document the webhook trigger/architecture for handling incremental real-time updates/deletes.
- **STRENGTHS**: Exceptional platform awareness (Matryoshka 3072->768 circumventing Firestore 2048 limit). Production-grade testing/QA (FakeEmbeddings, calibration methodologies, comprehensive evaluation metrics). Well-defined RRF with k=60 and multi-strategy fusion.
- **SUGGESTION**: Explicitly map ingest_items() to a webhook-based event handler to distinguish real-time from batch paths.

### GPT-5.2 Chat2: 9.5
- **GAPS**: No explicit index maintenance strategy (rebuild cadence, cost during backfills, versioning). Query-time Matryoshka truncation policy could be more explicit. Cache cold-start behavior not quantitatively validated. Cost guardrail thresholds not specified.
- **STRENGTHS**: Fully satisfies all rubric requirements. Strong Matryoshka rationale. Clear Firestore implementation. Robust chunking. Well-designed formatters. Correct SHA-256 idempotency. Proper RRF k=60. Property ID defense-in-depth. Comprehensive re-indexing. Thoughtful cost analysis. Practical FakeEmbeddings. Strong performance with stampede protection. Goes beyond rubric with IR metrics, faithfulness, E2E, failure modes, monitoring.
- **SUGGESTION**: Add index versioning/rollover, query-time projection rules, cache cold-start impact, and cost alert thresholds.

### Codex: 9.5
- **GAPS**: No concrete gcloud index definition shown (only parameters described). Embedding normalization not addressed (whether normalized at write/query time). No explicit safety guard preventing FakeEmbeddings in production.
- **STRENGTHS**: Complete rubric coverage (all required elements present). Concrete implementation details (async vector search, rerank logic, per-category overrides, batch ingestion). Operational maturity (reindex flow, nightly reconciliation, cache stampede, metrics, fallback table).
- **SUGGESTION**: Add Firestore index & limits appendix with explicit config snippet, note embedding normalization, harden test/prod separation.

### Dimension 4 Score Summary
| Model | Score |
|-------|-------|
| GPT-5.2 | 9.5 |
| Grok-4 | 9.0 |
| Perplexity | UNAVAIL |
| Gemini 3 Pro | 9.0 |
| GPT-5.2 Chat2 | 9.5 |
| Codex | 9.5 |
| **Median** | **9.5** |
| **Mean** | **9.30** |

---

## Overall Score Summary

| Dimension | GPT-5.2 | Grok-4 | Perplexity | Gemini 3 Pro | GPT-5.2 Chat2 | Codex | Median | Mean |
|-----------|---------|--------|------------|--------------|----------------|-------|--------|------|
| 1. Agent Architecture | 9.0 | 9.0 | 9.5 | 9.5 | 9.0 | 8.5 | 9.0 | 9.08 |
| 2. Data Model | 9.5 | 9.0 | UNAVAIL | 9.5 | 9.5 | 8.0 | 9.5 | 9.10 |
| 3. SMS/Communication | 9.5 | 9.5 | 8.5 | 9.5 | 9.5 | 8.5 | 9.5 | 9.17 |
| 4. RAG/Embeddings | 9.5 | 9.0 | UNAVAIL | 9.0 | 9.5 | 9.5 | 9.5 | 9.30 |
| **Overall Median** | | | | | | | **9.25** | |
| **Overall Mean** | | | | | | | | **9.16** |

---

## Consensus Gaps

### Dimension 1: Agent Architecture (3+ LLMs agree)
1. **Whisper Track Planner integration specifics** (4/6 LLMs): Architecture and lifecycle timing underspecified -- missing explicit node edges/conditions in topology, concurrency mechanism, cancellation conditions, and conflict resolution with speaking agents.
2. **Silent handoff in-process mechanics** (3/6 LLMs): How create_handoff_tool() works internally (state transfer, Command object, control flow return to outer graph) not at code-path level.
3. **Error handling concreteness** (3/6 LLMs): Error handling table exists but is declarative -- lacks per-node exception classes, edge propagation semantics, and middleware-specific error behavior.

### Dimension 2: Data Model (3+ LLMs agree)
1. **Per-field consent tracking** (3/5 LLMs): Consent scopes exist but the mechanism linking individual ProfileField instances to specific consent grants/versions is implied, not explicit.
2. **Canonical schema reconciliation** (2/5 LLMs): Phone-as-key in early sections vs guest_uuid in later sections creates ambiguity about the final schema.

### Dimension 3: SMS/Communication (3+ LLMs agree)
1. **Provider/channel fallback** (3/6 LLMs): No secondary SMS aggregator or alternative channel (voice/email) fallback when Telnyx is unavailable.
2. **Carrier filtering calibration** (2/6 LLMs): Risk factor weights lack derivation/justification and evaluation methodology.

### Dimension 4: RAG/Embeddings (3+ LLMs agree)
1. **Incremental webhook re-indexing** (3/5 LLMs): Batch reindex_all() is detailed but the real-time webhook-triggered incremental update path is not explicitly mapped to code/architecture.
2. **Firestore vector search limitations** (2/5 LLMs): Limitations beyond the 2048-dim constraint not explicitly documented (index build times, max neighbors, pagination).
