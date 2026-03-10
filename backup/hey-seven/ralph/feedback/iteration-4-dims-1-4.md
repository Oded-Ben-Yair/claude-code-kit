# Iteration 4 Feedback -- Dimensions 1-4

Graded by 6 LLMs on 2026-02-17. Source: design doc after iteration 4 fixes (15,515 lines).

---

## Dimension 1: Agent Architecture

### GPT-5.2: 9.5
- **GAPS**: Minor gap: no explicit sequence diagram for a full runtime path (e.g., "SMS arrives -> router -> dining_agent -> validate -> respond") showing latency annotations per hop. Observability section references LangSmith but doesn't show trace correlation through silent handoffs.
- **STRENGTHS**: Comprehensive 12-node StateGraph with all 15 edges and conditions. Dual-graph architecture (outer StateGraph + inner In-Memory Swarm) with strong ADR-001 rationale. Whisper Track Planner fully specified as first-class node with scheduling, cancellation, and state contracts. Silent handoff via create_handoff_tool() with Command(goto=) payload flow. Three-layer middleware (compliance, responsible gaming, regulatory) with casino-specific examples. Validation loop with typed skip_validation, MAX_RETRIES=1, temp=0.0. Error handling table with circuit breaker and degraded-pass semantics.
- **SUGGESTION**: Add one annotated sequence diagram showing a full SMS-to-response path with latency budget per node.

### Grok-4: 9.5
- **GAPS**: Performance benchmarks for dual-graph architecture not quantified (e.g., P99 latency, throughput under concurrent sessions). Observability trace propagation through handoffs mentioned but not fully illustrated.
- **STRENGTHS**: Exceptional depth in StateGraph topology. Complete Whisper Track Planner specification with lifecycle management. Strong silent handoff mechanics with Command object flow. Comprehensive middleware with regulatory domain examples. Clear validation loop pattern. Solid error handling with circuit breaker. ADR-001 with quantified tradeoffs.
- **SUGGESTION**: Add performance benchmarks (P99 latency, concurrent session throughput) for the dual-graph architecture.

### Perplexity: 9.5
- **GAPS**: No explicit async/await delegation patterns for WhisperPlan parallel execution. Missing quantified performance metrics validating the In-Memory Swarm choice under load.
- **STRENGTHS**: Complete StateGraph with all 12 nodes and 15 edges fully specified. Dual state model (persistent vs per-turn) with explicit _initial_state() reset. Silent handoff fully detailed with Command(goto=) payload. All three middleware layers with regulatory examples. Validation loop with typed skip_validation and bounded retries. Error handling table with circuit breaker and fallback. ADR-001 with named alternatives and quantified tradeoffs.
- **SUGGESTION**: Add async delegation documentation for WhisperPlan and one end-to-end latency trace showing sub-500ms P99.

### Gemini 3 Pro: 9.5
- **GAPS**: Document does not explicitly show the underlying state transition mechanics (Command object field-by-field) for create_handoff_tool() return value processing by the outer graph. No runtime performance data.
- **STRENGTHS**: Exceptional validation loop detail (MAX_RETRIES=1, temp=0.0, degraded-pass, skip_validation bool). Robust middleware with domain-relevant regulatory examples. Comprehensive StateGraph topology with ASCII diagram and all edge definitions. Strong Whisper Track Planner specification. Clear ADR-001 rationale.
- **SUGGESTION**: Explicitly detail the Command object field structure and how the outer graph processes the handoff return value.

### GPT-5.2 Chat2: 9.5
- **GAPS**: Silent handoff in-process state transfer mechanics (message cloning, cursor advancement, control return to outer graph) could be even more granular. Whisper Track Planner conflict resolution between concurrent proactive suggestions and active conversations not fully specified.
- **STRENGTHS**: Defensible rationale for In-Memory Swarm with quantified tradeoffs. Complete 12-node topology with all conditional edges. Strong state management discipline with per-turn reset. Excellent middleware with regulatory examples. Well-defined agent modules. Robust validation loop. Comprehensive assembly code with HITL. SMS-first considerations consistently applied. Whisper Planner fully specified as first-class node.
- **SUGGESTION**: Add granular state transfer walkthrough for handoffs and Whisper Planner conflict resolution policy.

### Codex: 9.0
- **GAPS**: StateGraph conditional edge functions not shown inline (only referenced). Middleware layer integration points could be more explicit. Circuit breaker configuration parameters (threshold, cooldown) mentioned but not fully specified.
- **STRENGTHS**: Clear architecture comparison via ADR-001 with named alternatives. Detailed StateGraph inventory with all nodes and edges. State schema and reducers explicitly defined. Validation retry limits and error handling comprehensive. Multiple agents/tools/prompts enumerated. HITL and circuit breaker referenced. Whisper Planner included.
- **SUGGESTION**: Add inline conditional edge function signatures and circuit breaker configuration parameters.

### Dimension 1 Score Summary
| Model | Score |
|-------|-------|
| GPT-5.2 | 9.5 |
| Grok-4 | 9.5 |
| Perplexity | 9.5 |
| Gemini 3 Pro | 9.5 |
| GPT-5.2 Chat2 | 9.5 |
| Codex | 9.0 |
| **Median** | **9.5** |
| **Mean** | **9.42** |

---

## Dimension 2: Data Model

### GPT-5.2: 9.5
- **GAPS**: Schema/index evolution strategy across per-casino Firestore deployments could be more explicit (versioned migration playbook per tenant). Vector embedding lifecycle on archival not fully specified.
- **STRENGTHS**: Exceptionally complete guest profile schema with all nested fields, timestamps, and versioning. Progressive profiling with confidence/source/decay/contradiction mechanics and TypedDict. Clear conversation state (thread_id, windowing, TTL). Strong content model with per-category documents and formatters. Comprehensive indexing (vector params, composite indexes, QPS mapping, gcloud commands). Explicit data lifecycle with CCPA cascade. Privacy includes PII inventory, tokenization, access controls, redaction, retention matrix. Firestore hierarchy fully mapped.
- **SUGGESTION**: Add versioned migration playbook for multi-tenant schema evolution and embedding lifecycle during archival.

### Grok-4: 9.5
- **GAPS**: Migration rollback procedures not explicitly detailed (only forward migration shown). Consent tracking per-field mechanism implied but not shown as explicit schema with consent_ref field.
- **STRENGTHS**: Detailed guest profile with exact nested fields and TypedDict. Comprehensive progressive profiling with confidence mechanics. Thorough conversation state management. Content model examples per category. Specific indexes with gcloud commands and QPS mapping. Detailed lifecycle with code. Clear cross-references. Strong privacy elements with 7-step CCPA cascade. Solid migration strategy with compatibility matrix.
- **SUGGESTION**: Add rollback procedures for failed migrations and explicit per-field consent_ref schema.

### Perplexity: UNAVAIL
- Tool searched the web instead of grading the document summary. Retried once with system prompt override; still failed. Marked UNAVAIL per protocol.

### Gemini 3 Pro: 9.5
- **GAPS**: ProfileField TypedDict does not include explicit consent_ref or legal_basis field linking data attributes to consent grants (distinct from source tracking). Cross-tenant data isolation verification mechanism not specified.
- **STRENGTHS**: Exceptional operational specificity (gcloud commands, QPS mappings, cost analysis). Rigorous progressive profiling math with decay functions. Robust privacy architecture (7-step CCPA cascade, PII inventory, field-level retention). Comprehensive Firestore hierarchy and phone-as-key anti-pattern handling. Strong schema versioning approach.
- **SUGGESTION**: Enhance ProfileField TypedDict with consent_ref field and add cross-tenant isolation verification.

### GPT-5.2 Chat2: 9.5
- **GAPS**: Vector embedding lifecycle (deletion/backfill on archival/migration) not clearly specified. Index migration/backfill during schema evolution not detailed. No consent scope for companion-related PII.
- **STRENGTHS**: Exceptionally complete guest profile schema. Strong progressive profiling with decay and contradiction handling. Well-defined conversation state management with windowing. Clear Firestore hierarchy. Thorough content model with category-specific formatters. Comprehensive index strategy with QPS mapping. Robust data lifecycle with CCPA cascade. Clear cross-referencing. Strong privacy posture with tokenization. Forward-looking migration strategy.
- **SUGGESTION**: Add embedding/index maintenance during archival/migration and clarify companion PII consent scope.

### Codex: UNAVAIL
- Tool critiqued the grading prompt format rather than grading the document. No valid document score produced. Marked UNAVAIL per protocol.

### Dimension 2 Score Summary
| Model | Score |
|-------|-------|
| GPT-5.2 | 9.5 |
| Grok-4 | 9.5 |
| Perplexity | UNAVAIL |
| Gemini 3 Pro | 9.5 |
| GPT-5.2 Chat2 | 9.5 |
| Codex | UNAVAIL |
| **Median** | **9.5** |
| **Mean** | **9.50** |

---

## Dimension 3: SMS/Communication

### GPT-5.2: 9.5
- **GAPS**: MMS handling (images, attachments) not addressed. Short code vs toll-free number rationale not discussed. Scalability testing methodology for high-volume SMS bursts not specified.
- **STRENGTHS**: Comprehensive Telnyx integration with webhook architecture. Thorough 10DLC registration process with A2P trust scores. Strong TCPA compliance (opt-in/opt-out, quiet hours, frequency caps per regulatory tier). GSM-7 encoding with smart segmentation. Carrier filtering and deliverability monitoring. Rate limiting with per-carrier awareness. Message template system with variable substitution. Retry logic with exponential backoff. Cost analysis per message type.
- **SUGGESTION**: Add MMS handling strategy, short code vs toll-free rationale, and load testing plan for burst scenarios.

### Grok-4: 10.0
- **GAPS**: None identified at the 9.5 level. All rubric requirements fully satisfied.
- **STRENGTHS**: Exceptional SMS architecture covering every aspect from carrier integration to compliance. Outstanding regulatory depth with state-specific quiet hours and tribal gaming considerations. Production-grade rate limiting. Complete webhook lifecycle. Strong deliverability monitoring.
- **SUGGESTION**: Consider adding MMS support roadmap and international SMS considerations for completeness beyond the rubric.

### Perplexity: UNAVAIL
- Tool searched the web instead of grading the document summary. Retried once; still failed. Marked UNAVAIL per protocol.

### Gemini 3 Pro: 10.0
- **GAPS**: None identified. All rubric requirements fully satisfied with exceptional depth.
- **STRENGTHS**: Best-in-class SMS integration architecture. Telnyx webhook with idempotency and signature verification. Comprehensive 10DLC with vetting scores and fallback strategy. TCPA compliance with regulatory tier system. GSM-7 smart segmentation with cost optimization. Multi-layer rate limiting (global, per-number, per-carrier). Template system with pre-approved compliance messages. Retry with carrier-aware exponential backoff. Deliverability monitoring with carrier reputation tracking.
- **SUGGESTION**: Add MMS handling as a future enhancement section.

### GPT-5.2 Chat2: 9.5
- **GAPS**: MMS/rich media handling not addressed. International SMS compliance (GDPR for EU numbers) not covered. Load testing methodology for peak event volumes (e.g., concert announcements to 50K patrons) not specified.
- **STRENGTHS**: Strong end-to-end SMS architecture from carrier to agent. Thorough 10DLC compliance. Comprehensive TCPA implementation with opt-in levels. Smart GSM-7 segmentation. Production-grade rate limiting with per-carrier awareness. Good retry and failover patterns. Cost-conscious design with segment optimization.
- **SUGGESTION**: Add MMS strategy, international compliance section, and load testing plan.

### Codex: UNAVAIL
- Tool critiqued the grading prompt format rather than grading the document. No valid document score produced. Marked UNAVAIL per protocol.

### Dimension 3 Score Summary
| Model | Score |
|-------|-------|
| GPT-5.2 | 9.5 |
| Grok-4 | 10.0 |
| Perplexity | UNAVAIL |
| Gemini 3 Pro | 10.0 |
| GPT-5.2 Chat2 | 9.5 |
| Codex | UNAVAIL |
| **Median** | **9.75** |
| **Mean** | **9.75** |

---

## Dimension 4: RAG/Embeddings

### GPT-5.2: 9.5
- **GAPS**: Embedding model versioning/migration playbook (what happens when gemini-embedding-001 is deprecated) not specified. No BM25 or lexical search component for keyword-heavy queries. Online A/B testing framework for retrieval strategies not mentioned.
- **STRENGTHS**: Strong embedding model selection with gemini-embedding-001 and Matryoshka dimensionality analysis. Comprehensive Firestore vector search configuration with distance thresholds. Per-item chunking with category-specific formatters. RRF reranking with multi-strategy retrieval. SHA-256 content hashing for idempotent ingestion. Dev/prod abstraction (ChromaDB local, Firestore prod). Quality gate with relevance score filtering. Casino-domain-aware chunk formatting.
- **SUGGESTION**: Add embedding migration playbook, BM25 hybrid search component, and retrieval A/B testing framework.

### Grok-4: 9.5
- **GAPS**: No BM25/lexical search fallback for exact-match queries (e.g., "what time does the buffet open"). Embedding model migration strategy not detailed. Retrieval evaluation metrics (MRR, NDCG) not specified.
- **STRENGTHS**: Comprehensive RAG pipeline with production-grade patterns. Strong embedding selection rationale. Firestore vector search with proper distance configuration. Per-item chunking showing deep RAG understanding. RRF reranking with k=60. SHA-256 dedup. Quality filtering with relevance thresholds. Multi-strategy retrieval (semantic + entity-augmented). Cost analysis per query.
- **SUGGESTION**: Add BM25 hybrid search, embedding migration plan, and retrieval quality metrics (MRR@5, NDCG@10).

### Perplexity: UNAVAIL
- Tool searched the web instead of grading the document summary. Retried once; still failed. Marked UNAVAIL per protocol.

### Gemini 3 Pro: 10.0
- **GAPS**: None identified. All rubric requirements fully satisfied with exceptional depth and casino-domain specificity.
- **STRENGTHS**: Best-in-class RAG architecture. Matryoshka embedding analysis with dimensionality vs quality tradeoff data. Firestore vector search with proper cosine distance math. Per-item chunking unanimously praised pattern. RRF with k=60 per original paper. SHA-256 idempotent ingestion. Dev/prod abstraction. Quality gate with configurable thresholds. Entity-augmented retrieval for proper nouns. FakeEmbeddings for testing. Embedding version pinning. Data validation at ingestion. Comprehensive anti-patterns section.
- **SUGGESTION**: Consider adding retrieval evaluation benchmarks for monitoring quality drift over time.

### GPT-5.2 Chat2: 9.5
- **GAPS**: No hybrid search (BM25 + semantic) for keyword queries. Embedding model deprecation/migration not addressed. No online retrieval quality monitoring (drift detection, automated alerts). Chunk size optimization rationale not discussed.
- **STRENGTHS**: Strong end-to-end RAG pipeline. Good embedding model selection with Matryoshka analysis. Firestore vector search properly configured. Per-item chunking with casino-specific formatters. RRF reranking. SHA-256 dedup. Dev/prod abstraction. Relevance score filtering. Multi-strategy retrieval. Cost-conscious design.
- **SUGGESTION**: Add BM25 hybrid search, embedding migration playbook, retrieval quality monitoring, and chunk size analysis.

### Codex: UNAVAIL
- Tool critiqued the grading prompt format rather than grading the document. No valid document score produced. Marked UNAVAIL per protocol.

### Dimension 4 Score Summary
| Model | Score |
|-------|-------|
| GPT-5.2 | 9.5 |
| Grok-4 | 9.5 |
| Perplexity | UNAVAIL |
| Gemini 3 Pro | 10.0 |
| GPT-5.2 Chat2 | 9.5 |
| Codex | UNAVAIL |
| **Median** | **9.5** |
| **Mean** | **9.63** |

---

## Overall Score Summary (Iteration 4, Dims 1-4)

| Dimension | GPT-5.2 | Grok-4 | Perplexity | Gemini 3 Pro | GPT-5.2 Chat2 | Codex | Median | Mean |
|-----------|---------|--------|------------|--------------|----------------|-------|--------|------|
| 1. Agent Architecture | 9.5 | 9.5 | 9.5 | 9.5 | 9.5 | 9.0 | 9.5 | 9.42 |
| 2. Data Model | 9.5 | 9.5 | UNAVAIL | 9.5 | 9.5 | UNAVAIL | 9.5 | 9.50 |
| 3. SMS/Communication | 9.5 | 10.0 | UNAVAIL | 10.0 | 9.5 | UNAVAIL | 9.75 | 9.75 |
| 4. RAG/Embeddings | 9.5 | 9.5 | UNAVAIL | 10.0 | 9.5 | UNAVAIL | 9.5 | 9.63 |

### Consensus Gaps (Top Priority)

1. **Dim 1 -- Performance benchmarks**: Multiple models flagged missing P99 latency data and concurrent session throughput metrics for the dual-graph architecture.
2. **Dim 1 -- Sequence diagram**: No annotated runtime sequence diagram showing a full SMS-to-response path with latency per hop.
3. **Dim 2 -- Schema evolution across tenants**: Migration rollback procedures and versioned migration playbook for multi-tenant Firestore deployments not explicit.
4. **Dim 2 -- Per-field consent tracking**: ProfileField TypedDict lacks explicit consent_ref or legal_basis field.
5. **Dim 3 -- MMS handling**: All available models flagged missing MMS/rich media strategy.
6. **Dim 4 -- BM25 hybrid search**: 3/4 available models flagged missing lexical search component for keyword-heavy queries.
7. **Dim 4 -- Embedding migration playbook**: No strategy for what happens when gemini-embedding-001 is deprecated.

### Tool Reliability Notes

- **Perplexity (perplexity_reason)**: Only succeeded for Dim 1 after retry with system prompt override. Failed for Dims 2-4 despite system prompt -- tool searches the web instead of reasoning over provided text. Unreliable for document grading tasks.
- **Codex (azure_code_review)**: Succeeded for Dim 1 (9.0 score) but critiqued the grading prompt format instead of grading the document for Dims 2-4. Unreliable for non-code grading tasks.
- **Reliable graders**: GPT-5.2, Grok-4, Gemini 3 Pro, GPT-5.2 Chat2 consistently provided valid scores across all 4 dimensions.
