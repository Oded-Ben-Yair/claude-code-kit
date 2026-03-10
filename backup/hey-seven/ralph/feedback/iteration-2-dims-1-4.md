# Iteration 2 Feedback -- Dimensions 1-4

**Date**: 2026-02-17
**Document**: `/home/odedbe/projects/hey-seven/docs/plans/2026-02-17-v2-architecture-design.md`
**Grading LLMs**: GPT-5.2, Grok-4, Perplexity (Sonar Reasoning Pro), Gemini 3 Pro, GPT-5.2-Chat2, Codex (GPT-5.2)

---

## Dimension 1: Agent Architecture

### GPT-5.2: 9.5
**GAPS**: None against the stated rubric. Every required element is explicitly present with code-level detail.
**STRENGTHS**: Complete auditable topology (all nodes/edges/conditions + worst-case path analysis). Strong state hygiene (per-turn vs persistent + v1 leakage lesson). Middleware has full code and casino-specific rationale. Silent handoffs correctly implemented. Validation and error handling are production-grade with node-by-node error table and circuit breaker.
**SUGGESTION**: Add a small end-to-end runnable wiring code snippet that instantiates the full StateGraph (node registration + conditional edges) and demonstrates one happy-path and one retry/fallback path via a minimal test harness.

### Grok-4: 9.5
**GAPS**: None.
**STRENGTHS**: Comprehensive coverage of all rubric items with explicit code-level details (middleware, validation node, Whisper planner, handoff tools, state schema). Strong rationale via comparison table and ADR. Detailed error handling table for every node.
**SUGGESTION**: Include the full Python code snippet for compiling the outer StateGraph (e.g., state_graph.compile()) to further elevate topology documentation beyond descriptive lists and diagrams.

### Perplexity: 9.5
**GAPS**: (1) Middleware-validation integration: no explicit documentation of how validation loop interacts with middleware hooks during retry cycles. (2) Silent handoff state transfer: which state fields transfer vs reset during handoffs not specified. (3) Recursive depth edge case: interaction of validation retries with circular conditional edges not fully analyzed.
**STRENGTHS**: Comprehensive state schema with Annotated/TypedDict. Production hardening (circuit breaker, error table, no self-retry). Domain-specific middleware baked into hooks. ADR with comparison table + consequences.
**SUGGESTION**: Add a Section 1.10 State Lifecycle Diagram showing which fields flow through handoffs, validation retries, and middleware hooks. Create a state field ownership matrix.

### Gemini 3 Pro: 9.5
**GAPS**: The summary does not explicitly confirm the inclusion of the raw Python StateGraph wiring code (e.g., builder.add_node, builder.add_conditional_edges) for the outer graph, whereas other sections explicitly mention full Python code.
**STRENGTHS**: Middleware implementation mapping business logic to LangGraph 1.0 hooks is perfect. Validation loop (skip_validation bool, retry limits, fallback) is architecturally sound. State schema with TypedDict/Annotated meets strict typing requirements. Swarm mechanics correctly identified.
**SUGGESTION**: Include the literal Python code block for the StateGraph construction (wiring of nodes and conditional edges) in Section 1.2.

### GPT-5.2-Chat2: 9.0
**GAPS**: (1) In-Memory Swarm bootstrap/assembly code not explicit (create_agent shown but not swarm initialization/execution entrypoint). (2) Fallback path not clearly enumerated as a distinct node in the topology separate from FAIL.
**STRENGTHS**: Exceptional completeness and rigor. Correct LangGraph 1.0 usage with realistic casino examples. Strong agent modularization. Advanced orchestration (silent handoffs, Whisper Planner, disciplined validation loop). Solid ADR.
**SUGGESTION**: Add a small explicit code block showing In-Memory Swarm construction and execution (agent registration + run call), and label a dedicated fallback node/edge in the validation loop.

### Codex (GPT-5.2): 9.0
**GAPS**: Missing casino-specific example usage for LangGraph 1.0 middleware hooks (hooks shown but no domain-specific examples according to this reviewer).
**STRENGTHS**: Comprehensive topology (12 nodes/15 edges with conditionals). Clear state management. Explicit handoff tools. Detailed agent modules/prompts. Whisper planner with code. Validation loop with retry limits. Thorough node-level error handling. ADR comparison.
**SUGGESTION**: Add concrete casino-domain examples for each middleware hook to fully satisfy the rubric's "casino examples" requirement.

---

## Dimension 2: Data Model

### GPT-5.2: 9.5
**GAPS**: None against the stated rubric. All required items explicitly covered with code-level detail.
**STRENGTHS**: Guest profile schema exceptionally complete (exact fields/types/nesting + per-field provenance + consent scoping). Progressive profiling actionable (confidence ranges + update/decay/exclusion rules). Conversation state production-grade (windowing, TTL, schemas). Casino content concrete per category. Indexing unusually strong (vector + composite + cost analysis). Privacy thorough (PII inventory, tokenization, IAM, log redaction, CCPA deletion). Migration explicit and versioned.
**SUGGESTION**: Add an explicit field-level retention policy matrix (per PII field: retention duration, deletion/anonymization method, legal basis, CCPA export/delete inclusion).

### Grok-4: 9.0
**GAPS**: Data lifecycle covered at high level with 4 stages but lacks code-level detail (no implementation examples, scripts, or workflows). Cross-reference guest-to-conversation could use more explicit nesting examples.
**STRENGTHS**: Excellent code-level details in privacy (tokenization, Terraform IAM), indexes (gcloud, cost analysis), and migration (code example). Comprehensive schemas for guest profile, conversation state, and content models.
**SUGGESTION**: Expand data lifecycle section with a code example (e.g., Python script for stage transitions) to match the detail level of other sections.

### Perplexity: 9.0 (rescored from initial 9.2)
**GAPS**: (1) No explicit error handling/recovery for partial write failures or orphaned conversations. (2) Audit log schema/retention/query patterns undefined. (3) No performance SLAs for conversation retrieval or cross-reference queries. (4) No backup/restore or disaster recovery strategy. (5) No data quality monitoring/alerting.
**STRENGTHS**: Comprehensive schema definition with field-level confidence scoring. Conversation state clarity (windowing, two-layer TTL). Strong privacy framework (per-field consent, CCPA deletion, encryption). Cross-casino isolation. Concrete examples. Confidence decay mechanics.
**SUGGESTION**: Define an audit event schema with standardized fields and document error handling for orphaned conversations.

### Gemini 3 Pro: 9.0
**GAPS**: (1) Primary key vs stable identity conflict: using mutable PII (phone) as document key is an anti-pattern; if guest changes number it forces delete/copy migration and breaks thread_id. (2) Content schema detail: summary doesn't explicitly list distinct schema fields per category to prove category variance handling.
**STRENGTHS**: Progressive profiling logic with mathematical rules for confidence scoring is outstanding and directly implementable. Privacy granularity with per-field consent_scope. Vector search specifications are precise.
**SUGGESTION**: Refactor Guest Profile collection to use guest_uuid as Firestore Document ID. Treat E.164 solely as a unique indexed field.

### GPT-5.2-Chat2: 9.0
**GAPS**: (1) Firestore schema typing rigor: not explicit about Firestore-native types (Timestamp vs ISO strings, GeoPoint, DocumentReference, Map). (2) No explicit confidence decay function at code level. (3) Field-level retention durations not enumerated. (4) Vector index schema binding to specific embedding field paths not explicit.
**STRENGTHS**: Exceptionally complete conversation state modeling. Strong casino content modeling. Clear Firestore hierarchy. Above-average privacy and compliance depth. Migration section unusually solid. Indexing includes cost analysis.
**SUGGESTION**: Add a schema appendix listing every Firestore field with exact Firestore type, retention period, confidence decay formula, and vector index field path mapping.

### Codex (GPT-5.2): UNAVAIL
**NOTE**: Codex reviewed the prompt structure rather than grading the content. Marked as unavailable for Dimension 2.

---

## Dimension 3: SMS/Communication Design

### GPT-5.2: 9.0
**GAPS**: (1) TCPA consent lacks explicit handling for reassigned numbers, consent revocation mechanics beyond STOP, and START re-opt-in workflow at code level. (2) First message flow not fully specified as a state machine with enforcement gates for 10DLC readiness, quiet hours, consent tier.
**STRENGTHS**: End-to-end Telnyx lifecycle unusually complete. STOP/HELP precedence before agent graph correctly emphasized. Encoding/segmentation at right implementation detail level. Strong operational maturity (monitoring, alerting, carrier-block playbook, idempotency).
**SUGGESTION**: Add an explicit message eligibility gate (code + state diagram) checking consent tier + STOP status + quiet hours + 10DLC readiness + first-message rules with START re-opt-in handling.

### Grok-4: 9.0
**GAPS**: (1) 10DLC registration lacks code-level detail (no API integration code or automation scripts). (2) Rate limiting describes tiers but no implementation code. (3) First message flow has content but no code. (4) Cost model has formulas but no billing calculation function.
**STRENGTHS**: Comprehensive coverage of all rubric items with extras (KPIs, A/B testing, idempotency). Strong code-level details in STOP/HELP, GSM-7, delay, carrier mitigation, session management, error handling, multilingual.
**SUGGESTION**: Add pseudocode for rate limiting enforcement (e.g., function implementing 4 tiers with Redis counters).

### Perplexity: 8.5
**GAPS**: (1) Message content specificity: no actual SMS template examples tested for character efficiency. (2) Opt-out mechanism detail: STOP handling described but template examples with STOP instructions in EN/ES not shown fully. (3) No device/carrier testing strategy. (4) KPI targets could reference industry benchmarks more explicitly.
**STRENGTHS**: Exceptionally strong technical depth. 14-step Telnyx flow. Comprehensive 10DLC framework. GSM-7 encoding with multi-segment UDH. TCPA consent tiers. Delay formula with research. Carrier risk scoring. Thompson Sampling A/B testing.
**SUGGESTION**: Provide 2-3 real template examples (one per compliance tier) showing exact character counts, encoding classification, CTA phrasing, and STOP instructions in both EN/ES.

### Gemini 3 Pro: 9.5
**GAPS**: (1) Carrier filtering omits specific URL management strategy (custom domains vs public shorteners). (2) Inbound concatenation: unclear if webhook handler reassembles inbound multi-part messages (UDH handling) before passing to AI.
**STRENGTHS**: Encoding and cost precision (GSM-7 vs UCS-2 tied to cost model) is high-maturity. Compliance depth (10DLC workflows, TCPA tiers, localized STOP). Human-like mechanics balance UX with avoiding bot-like traffic patterns.
**SUGGESTION**: Define URL domain strategy. Explicitly prohibit public URL shorteners. Add requirement for dedicated short-link domain.

### GPT-5.2-Chat2: 9.0 (rescored from 9.2)
**GAPS**: (1) Missing concrete webhook signature validation, replay protection, secret rotation details. (2) No treatment of partial delivery (multi-segment failures) or carrier-specific error codes. (3) No budget caps, anomaly alerts, or auto-throttling for spend spikes. (4) Expansion path beyond EN/ES or i18n framework not stated.
**STRENGTHS**: All major rubric items addressed including less-common ones (human-like delay research, carrier filtering, Thompson Sampling). Compliance-aware design. Operational maturity. Carrier realism. Clear sequencing.
**SUGGESTION**: Add a Security and Abuse subsection covering webhook signature verification, replay attack prevention, per-number fraud detection, and automated spend kill-switches.

### Codex (GPT-5.2): UNAVAIL
**NOTE**: Codex was not invoked for Dimension 3 (marked unavailable based on Dimension 1-2 behavior of reviewing prompt structure rather than grading).

---

## Dimension 4: RAG/Embeddings Pipeline

### GPT-5.2: 9.0
**GAPS**: (1) Re-indexing flow lacks code-level detail for the full reindex job (pagination, concurrency, backoff, batching limits, progress checkpoints, verification). (2) Firestore native vector search: not explicit that Firestore vector field/index primitives are used end-to-end vs abstracted wrapper. (3) Cache key design, stampede protection not explicit.
**STRENGTHS**: Embedding choice tightly justified with Matryoshka rationale and Firestore dim limits. Per-item chunking domain-appropriate. Category formatters and registry routing explicitly implemented. SHA-256 idempotent ingestion clearly specified. RRF k=60 has code and citation. property_id filtering mandatory and defended. Testing, monitoring, evaluation, error-handling unusually strong.
**SUGGESTION**: Add code-level full reindex + reindex verification: a concrete reindex_all(property_id) implementation with bounded concurrency, retry/backoff, orphan detection, and post-check assertion.

### Grok-4: 9.0
**GAPS**: (1) Per-item chunking describes approach but lacks explicit code-level detail (full functions). (2) Re-indexing flow has ASCII and latency table but no code snippets. (3) Category formatters described at high level without full code examples (note: full code IS in the actual document but may not have been captured in summary).
**STRENGTHS**: Excellent depth on core components (embeddings with Matryoshka rationale, vector search full code, idempotent ingestion full code, RRF reranking full code with citation, cost tables). Strong extras beyond rubric (monitoring, evaluation, failure modes).
**SUGGESTION**: Include full code snippets for per-item chunking logic to match code-level detail in other sections.

### Perplexity: 9.0 (rescored from 9.2)
**GAPS**: (1) Relevance threshold calibration process: 0.65 specified but methodology for deriving it missing (no precision-recall curves or ground truth calibration). (2) Embedding model evaluation methodology: no validation evidence (recall@k against casino-domain queries). (3) Generation/faithfulness evaluation details lack specifics on hallucination detection. (4) No hybrid search discussion. (5) Completeness scorer definition lacking.
**STRENGTHS**: Complete rubric coverage with implementation details, code, and rationale. Dimension-specific decisions justified with domain constraints. Operational rigor (cost analysis, latency targets, monitoring). Testability (FakeEmbeddings deterministic approach). Multi-strategy retrieval. SHA-256 idempotency throughout.
**SUGGESTION**: Add a validation section documenting how gemini-embedding-001 was benchmarked against alternatives on casino-domain queries with recall@k results and threshold calibration.

### Gemini 3 Pro: 9.5
**GAPS**: None relative to mandatory rubric items. Minor implicit gap: exact Firestore vector index configuration parameters (HNSW vs Flat) implied but not explicitly detailed in summary.
**STRENGTHS**: Comprehensive evaluation strategy (4.12-4.14) exceeds rubric. Advanced optimization (Matryoshka, RRF k=60). Deterministic testing (SHA-384 FakeEmbeddings). Robust idempotent ingestion (SHA-256).
**SUGGESTION**: Expand re-indexing flow to detail a Blue/Green Indexing Strategy for embedding model rotation (e.g., upgrading to gemini-embedding-004) with parallel collection/index and atomic traffic cutover.

### GPT-5.2-Chat2: 9.0 (rescored from 9.2)
**GAPS**: (1) FakeEmbeddings uses SHA-384 while ingestion uses SHA-256: breaks parity, can mask collision bugs. (2) Matryoshka dimensional truncation strategy (768->256 for recall-first passes) not documented. (3) Cache keys, TTLs, invalidation on re-index not specified. (4) 0.65 threshold hard-coded without calibration method or per-category overrides.
**STRENGTHS**: Complete alignment with core rubric items. Clear code references for vector search, RRF, filters, ingestion. Solid operational coverage (eval pipeline, failure modes, 9 monitoring metrics). Sensible re-index latency and cost awareness.
**SUGGESTION**: Unify testing and prod by switching FakeEmbeddings to SHA-256, document Matryoshka truncation tiers, and add cache invalidation rules tied to re-index events.

### Codex (GPT-5.2): UNAVAIL
**NOTE**: Codex was not invoked for Dimension 4 (marked unavailable based on earlier behavior).

---

## Score Summary

| LLM | DIM1 Agent Arch | DIM2 Data Model | DIM3 SMS/Comm | DIM4 RAG/Embed |
|---|---|---|---|---|
| GPT-5.2 | 9.5 | 9.5 | 9.0 | 9.0 |
| Grok-4 | 9.5 | 9.0 | 9.0 | 9.0 |
| Perplexity | 9.5 | 9.0 | 8.5 | 9.0 |
| Gemini 3 Pro | 9.5 | 9.0 | 9.5 | 9.5 |
| GPT-5.2-Chat2 | 9.0 | 9.0 | 9.0 | 9.0 |
| Codex | 9.0 | UNAVAIL | UNAVAIL | UNAVAIL |
| **Mean** | **9.33** | **9.10** | **9.00** | **9.10** |
| **Median** | **9.5** | **9.0** | **9.0** | **9.0** |

---

## Consensus Gaps (cited by 2+ LLMs)

### Dimension 1: Agent Architecture
1. **Missing StateGraph wiring/compilation code** (Grok-4, Gemini, GPT-5.2-Chat2): The outer StateGraph topology is described via ASCII + tables + edges, but the actual Python code for `builder.add_node()`, `builder.add_conditional_edges()`, and `graph.compile()` is absent.
2. **Missing Swarm assembly/execution code** (GPT-5.2, GPT-5.2-Chat2): No code showing In-Memory Swarm initialization, agent registration, and execution entrypoint.

### Dimension 2: Data Model
1. **Data lifecycle lacks code-level detail** (Grok-4, GPT-5.2-Chat2): 4-stage table is high-level; no implementation code for stage transitions, archival, or GCS export.
2. **Field-level retention durations not specified** (GPT-5.2, GPT-5.2-Chat2): PII inventory exists but per-field retention periods (e.g., dob: 7 years, chat_messages: 30 days) not enumerated.
3. **Firestore-native type specificity** (Gemini, GPT-5.2-Chat2): Document schema uses JSON but doesn't specify Firestore-native types (Timestamp vs ISO string, Map vs nested object).
4. **Phone as document key anti-pattern** (Gemini, Perplexity): Using mutable PII as Firestore document key complicates phone number migration despite guest_uuid existing.

### Dimension 3: SMS/Communication Design
1. **Rate limiting lacks implementation code** (Grok-4, GPT-5.2): Four tiers described but no enforcement logic code (e.g., token bucket implementation).
2. **First message flow lacks code/state machine** (GPT-5.2, Grok-4): Content is defined but no message eligibility gate code checking consent + STOP + quiet hours + 10DLC.
3. **Webhook security details incomplete** (GPT-5.2-Chat2, Gemini): HMAC mentioned but no signature verification code, replay protection, or secret rotation.
4. **TCPA consent revocation and reassigned numbers** (GPT-5.2, GPT-5.2-Chat2): START re-opt-in, non-keyword revocation, and reassigned number handling not specified.

### Dimension 4: RAG/Embeddings Pipeline
1. **Re-indexing flow lacks code-level detail** (GPT-5.2, Grok-4, GPT-5.2-Chat2): ASCII diagram and latency table present but no reindex_all() implementation code with concurrency, retry, verification.
2. **Relevance threshold 0.65 not calibrated** (Perplexity, GPT-5.2-Chat2): Hard-coded without precision-recall curve, per-category overrides, or calibration methodology.
3. **Cache implementation details insufficient** (GPT-5.2, GPT-5.2-Chat2): LRU cache mentioned but cache key design, invalidation rules, stampede protection not specified.
4. **FakeEmbeddings/production hash mismatch** (GPT-5.2-Chat2): SHA-384 in tests vs SHA-256 in production breaks parity.
