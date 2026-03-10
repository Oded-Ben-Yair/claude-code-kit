# Iteration 4 Re-Grading: Dimensions 9-10

**Date**: 2026-02-17
**Document**: `/home/odedbe/projects/hey-seven/docs/plans/2026-02-17-v2-architecture-design.md`
**Section ranges**: Dim 9 (lines 12528-13495), Dim 10 (lines 13496-15515)

---

## Dimension 9: Conversation Design

### Rubric (9.5 requires ALL)
Progressive profiling; persona design; Whisper Track Planner; first message design; incentive mechanics; contextual data extraction; reciprocity pattern; human-like timing; multi-turn arcs; escalation triggers; opt-out handling; language EN/ES; consent mechanics; edge cases.

### Scores

| # | LLM | Score | Status |
|---|-----|-------|--------|
| 1 | GPT-5.2 | 9.5 | OK |
| 2 | Grok-4 | 9.5 | OK |
| 3 | Perplexity Sonar Reasoning Pro | UNAVAIL | Refused to grade (attempted web search instead of grading provided content). Retried once -- same result. |
| 4 | Gemini 3 Pro | 10.0 | OK |
| 5 | GPT-5.2 Chat2 | 9.0 | OK |
| 6 | GPT-5.2 Codex | UNAVAIL | Interpreted as code review task instead of grading. Retried once -- same result. |

**Valid scores**: 4/6
**Mean**: 9.50
**Median**: 9.50
**Range**: 9.0 - 10.0
**Consensus**: 9.5

### Per-LLM Details

**GPT-5.2 (9.5)**
- GAPS: None material vs rubric. All required items explicitly specified with mechanisms, schemas, and/or code + tests.
- STRENGTHS: Persona enforcement via validate_node/persona_envelope (not prompt-only) with under-160-char examples; jurisdiction-aware first message templates with verified character counts; progressive profiling with weighted confidence scoring; Whisper Track Planner Pydantic schema + hidden system injection; concrete multi-day multi-turn arcs + state machine transitions; incentive tiering with readiness triggers; structured extraction with confidence thresholds; robust escalation/opt-out/consent handling; bilingual detection and midstream switching; edge-case catalog + rubric coverage matrix + integration tests.
- SUGGESTION: Add explicit guidance for GSM-7 vs UCS-2 (emoji/accents/Spanish characters) segmentation handling and how templates adapt when a message would spill into multi-segment or switch encodings.

**Grok-4 (9.5)**
- GAPS: None.
- STRENGTHS: Detailed implementations like Python functions and Pydantic models for profiling, incentives, and planning; comprehensive edge case matrix and examples across multi-turn arcs.
- SUGGESTION: Expand A/B testing details for reciprocity pattern to include success metrics integration.

**Gemini 3 Pro (10.0)**
- GAPS: None.
- STRENGTHS: Architecture integrates legal compliance directly into conversation flow (9.2, 9.19); Whisper Track Planner with Pydantic models separates internal reasoning from external dialogue; timing formulas (9.8, 9.21) and reciprocity strategy (9.14) ensure natural behavior.
- SUGGESTION: Add an "Unsupported Media" handler to edge cases (9.13) to manage MMS (screenshots/images) gracefully.

**GPT-5.2 Chat2 (9.0)**
- GAPS: Explicit SMS opt-in capture mechanics (YES keyword flow, express written consent storage) not specified beyond disclosure and privacy link. HELP keyword handling not described. Spanish equivalents for compliance keywords (STOP/ALTO, START/INICIAR, HELP/AYUDA) not explicitly documented.
- STRENGTHS: Extremely comprehensive coverage with concrete implementations; strong Whisper Track Planner integration; excellent operational rigor with jurisdictional consent rules, escalation SLAs, integration tests, and metrics.
- SUGGESTION: Add explicit SMS compliance subsection covering opt-in keyword flows, HELP handling, and bilingual compliance keywords.

### Consensus Gaps (Dimension 9)

1. **SMS compliance keywords** (GPT-5.2 Chat2): Missing HELP keyword handler and Spanish compliance keyword equivalents (ALTO, INICIAR, AYUDA).
2. **GSM-7/UCS-2 encoding** (GPT-5.2): No explicit guidance on segmentation when messages cross encoding boundaries.
3. **MMS/unsupported media** (Gemini 3 Pro): No handler for when guests send images/screenshots via MMS.
4. **Opt-in capture mechanics** (GPT-5.2 Chat2): YES keyword flow and express written consent storage not fully specified.

---

## Dimension 10: Production Readiness

### Rubric (9.5 requires ALL)
Circuit breaker/retry/fallback; Cloud Run autoscaling; cold start mitigation; cost analysis; health endpoint; operational runbook; message windowing; graceful degradation; rate limiting; structured logging; backup; SLA targets; load testing; zero-downtime deployment.

### Scores

| # | LLM | Score | Status |
|---|-----|-------|--------|
| 1 | GPT-5.2 | 10.0 | OK |
| 2 | Grok-4 | 9.5 | OK |
| 3 | Gemini 3 Pro | 9.5 | OK |
| 4 | GPT-5.2 Chat2 | 9.5 | OK |
| 5 | Perplexity Sonar Reasoning Pro | UNAVAIL | Same refusal pattern as Dim 9. |
| 6 | GPT-5.2 Codex | UNAVAIL | Same code review interpretation as Dim 9. |

**Valid scores**: 4/6
**Mean**: 9.63
**Median**: 9.50
**Range**: 9.5 - 10.0
**Consensus**: 9.5

### Per-LLM Details

**GPT-5.2 (10.0)**
- GAPS: None against stated rubric items; all explicitly addressed with concrete mechanisms/configuration and code.
- STRENGTHS: Comprehensive circuit breaker + retries with safe fallbacks; explicit Cloud Run autoscaling and cold-start mitigation; detailed cost analysis with scaling projections; well-defined health/readiness/liveness endpoints; message windowing/summarization; multi-tier + distributed rate limiting; structured logging with PII redaction; backup/restore and DR with RPO/RTO; explicit SLA/SLO targets; k6 load testing with maxScale validation; robust zero-downtime deployment via canary + automated rollback; thorough operational runbooks and escalation matrix.
- SUGGESTION: Add a "capacity & quota guardrails" subsection enumerating hard limits/quotas per dependency (Gemini RPM/TPM, Firestore read/write/sec, Telnyx throughput, Redis limits) with preconfigured alert thresholds and automated throttling.

**Grok-4 (9.5)**
- GAPS: None.
- STRENGTHS: Detailed implementations for circuit breakers, retries, and fallbacks with code specifics; thorough cost and scaling analysis; extensive load testing and deployment strategies with automation and monitoring.
- SUGGESTION: Incorporate multi-region failover into disaster recovery for enhanced global resilience.

**Gemini 3 Pro (9.5)**
- GAPS: None.
- STRENGTHS: Comprehensive coverage with high technical specificity (Python classes, scaling configs). Schema Migration (10.15.1), Escalation Matrices (10.19), and Disaster Recovery RPO/RTO (10.16) exceed baseline requirements.
- SUGGESTION: Enable and document Firestore Point-in-Time Recovery (PITR) to improve RPO from ~24 hours to minutes.

**GPT-5.2 Chat2 (9.5)**
- GAPS: None relative to stated rubric.
- STRENGTHS: Exceptional completeness across all operational dimensions; strong circuit breaker and graceful degradation with real code; thorough cost modeling; mature deployment strategy with canary, automated rollback, and clear SLO/SLA linkage; unusually detailed operational runbook and disaster recovery.
- SUGGESTION: Add summary table mapping each SLA/SLO to exact alert thresholds and dashboards.

### Consensus Gaps (Dimension 10)

No gaps identified by any grading LLM against the rubric items. All 4 valid graders confirmed complete coverage of every rubric requirement. Suggestions are enhancements beyond rubric scope:

1. **Capacity/quota guardrails** (GPT-5.2): Enumerate per-dependency hard limits with alert thresholds.
2. **Multi-region failover** (Grok-4): DR currently single-region; multi-region would improve resilience.
3. **Firestore PITR** (Gemini 3 Pro): Point-in-time recovery would improve RPO from ~24h to minutes.
4. **SLA-to-dashboard mapping** (GPT-5.2 Chat2): Direct mapping from each SLO to specific alert names and dashboards.

---

## Summary Table

| Dimension | GPT-5.2 | Grok-4 | Gemini 3 Pro | GPT-5.2 Chat2 | Mean | Consensus |
|-----------|---------|--------|--------------|----------------|------|-----------|
| 9 - Conversation Design | 9.5 | 9.5 | 10.0 | 9.0 | 9.50 | 9.5 |
| 10 - Production Readiness | 10.0 | 9.5 | 9.5 | 9.5 | 9.63 | 9.5 |

**Unavailable LLMs**: Perplexity Sonar Reasoning Pro (refused -- attempted web search instead of grading), GPT-5.2 Codex (interpreted as code review instead of grading). Both retried once with reformulated prompts; same result. These tools are not suitable for document grading tasks due to their architecture (web-search-first for Perplexity, code-review-focused for Codex).

---

## Actionable Improvements (Priority Order)

### Dimension 9 (to close the 9.0 outlier to 9.5)
1. **Add HELP keyword handling**: Document HELP response ("Reply with your question or text STOP to opt out") per SMS industry standard.
2. **Add Spanish compliance keywords**: Map ALTO=STOP, INICIAR=START, AYUDA=HELP in opt-out processing.
3. **Add GSM-7/UCS-2 encoding note**: Brief note in 9.15 on how persona_envelope handles encoding boundary crossings.
4. **Add MMS handler edge case**: Brief row in 9.13 for unsupported media (images/screenshots) -- respond with text-only guidance.

### Dimension 10 (already at 9.5 consensus, stretch to 10.0)
5. **Add per-dependency quota table**: Gemini RPM/TPM, Firestore ops/sec, Telnyx throughput limits with alert thresholds.
6. **Document Firestore PITR**: One line noting PITR availability for sub-hour RPO.
7. **Add SLA-to-alert dashboard mapping table**: Connect each SLO to specific Cloud Monitoring alert name.
