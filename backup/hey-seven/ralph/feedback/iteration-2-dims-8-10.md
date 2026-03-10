# Iteration 2 Feedback -- Dimensions 8-10

Graded by 6 LLMs on 2026-02-17. Source: `/home/odedbe/projects/hey-seven/docs/plans/2026-02-17-v2-architecture-design.md`

---

## Dimension 8: Observability & Evaluation

### GPT-5.2: 9.5
- **GAPS**: None against the stated rubric. Every item covered with code-level detail.
- **STRENGTHS**: End-to-end LangFuse observability with trace/span/generation hierarchy, rich metadata, cost+token capture, PII hashing. Metrics completeness (per-node + nightly + RAG). Strong ops maturity (alerting, SLOs, error budgets, sampling, retention, incident response). Eval and experimentation are real (synthetic evals, manual review, A/B, replay). LangFuse vs alternatives and OTel both explicit.
- **SUGGESTION**: Add a "metric-to-action" runbook table linking each top alert/SLO breach to the exact dashboard panel(s), primary on-call query (LangFuse filter / OTel metric name), and first two remediation steps.

### Grok-4: 9.0
- **GAPS**: A/B testing lacks code-level detail (describes mechanisms but no code snippets). Dual dashboards are ASCII mockups without implementation code or tools specified.
- **STRENGTHS**: Excellent LangFuse integration with code, comparisons, trace structure. Robust metrics (per-node, conversation, retrieval) with tables/formulas/targets. Strong eval framework, replay, alerting, OTel, testing with full code examples.
- **SUGGESTION**: Include Python code snippets for A/B testing (feature flag logic and trace tagging) to provide code-level detail.

### Perplexity (Sonar Reasoning Pro): 9.0
- **GAPS**: LangFuse vs alternatives comparison is shallow (basic criteria, no detailed trade-off analysis on feature gaps, scalability, compliance). Dual dashboards are ASCII only (no backend API design, metric aggregation queries, or refresh cadence).
- **STRENGTHS**: Comprehensive code coverage across 7 sections. Metrics depth (12 per-node, 10 conversation-level) is exceptionally specific. Evaluation rigor (automated+manual). Production-grade infrastructure (SLOs, incident response, cost, governance). Advanced features (A/B, replay, correlation).
- **SUGGESTION**: Deepen Section 8.1 with a decision matrix comparing LangFuse/LangSmith/Phoenix on 4-5 dimensions critical to SMS agent systems.

### Gemini 3 Pro: 9.5
- **GAPS**: Operator dashboard implementation stack not specified (what renders it: Retool, Looker Studio, custom React?). Operators should not access LangFuse directly.
- **STRENGTHS**: Full-cycle engineering (replay+A/B alongside logging). Integration specificity (immediately implementable). Hybrid evaluation (synthetic+manual). OTel bridging for non-LLM ops.
- **SUGGESTION**: Select and diagram the technology stack for the Casino Operator Dashboard. Clarify how it authenticates users and queries the metrics store.

### GPT-5.2 Chat2: 9.0
- **GAPS**: LangFuse vs alternatives comparison not formalized (no scoring matrix). Alerting lacks severity taxonomy (but note: Section 8.16 does have SEV0-SEV3, which the grader missed). Evaluation drift monitoring absent. Replay lacks determinism guarantees.
- **STRENGTHS**: Every rubric item explicitly covered. Cost monitoring, correlation, incident response, SLOs, error budgets, data governance all go above rubric requirements.
- **SUGGESTION**: Add formal tool-selection matrix. Define evaluation trend dashboards with regression alerts. Specify replay determinism controls (model version, prompt hash, temperature=0).

### Codex (GPT-5.2): 9.0
- **GAPS**: Missing explicit LangFuse vs alternatives analysis. Testing strategy not clearly tied to observability outcomes. Dual dashboards and OTel mentioned but not evidenced with depth.
- **STRENGTHS**: Comprehensive coverage of all required areas. Clear subsection structure and breadth.
- **SUGGESTION**: Add dedicated subsection comparing LangFuse alternatives. Enrich dashboards and OTel with concrete implementation detail.

### Dimension 8 Score Summary

| Model | Score |
|-------|-------|
| GPT-5.2 | 9.5 |
| Grok-4 | 9.0 |
| Perplexity | 9.0 |
| Gemini 3 Pro | 9.5 |
| GPT-5.2 Chat2 | 9.0 |
| Codex | 9.0 |
| **Median** | **9.0** |
| **Mean** | **9.08** |

---

## Dimension 9: Conversation Design

### GPT-5.2: 9.5
- **GAPS**: None against the stated rubric. Every required item explicitly covered with code/schema-level detail.
- **STRENGTHS**: Progressive profiling is operationalized (priority + rationale + completeness scoring). Persona + SMS constraints enforceable (rule tables + deterministic validation). Whisper Track Planner clearly specified with injection format. First message compliant and testable. Robust operational handling (escalation, opt-out, consent, edge cases, bilingual).
- **SUGGESTION**: Add code-level detail for the language router (regex features/thresholds + LLM confirmation schema + fallback when they disagree).

### Grok-4: 9.5
- **GAPS**: None.
- **STRENGTHS**: Comprehensive coverage with consistent code-level details (Pydantic schemas, code functions, structured tables, implementation specifics). Strong emphasis on practical enforcement and measurement.
- **SUGGESTION**: Add explicit code snippets for multi-turn arc phase transitions.

### Perplexity (Sonar Reasoning Pro): 8.5
- **GAPS**: No production observability for persona adherence or extraction rates. Missing fallback/recovery for failed extractions. No integration testing matrix. No versioning/rollback for persona/prompt changes. No performance SLAs. No data security specification for consent records. Feedback loop underspecified.
- **STRENGTHS**: 100% rubric coverage. Type-safe architecture (Pydantic). Behavioral enforcement via validate_node. Multi-turn coherence (6-phase, Whisper state). Genuine bilingual support. Compliance-ready (opt-out, consent, CCPA). Safety layering (two-layer, 7 categories).
- **SUGGESTION**: Add production observability dashboards, integration testing matrix, and change management procedures.

### Gemini 3 Pro: 9.5
- **GAPS**: Phase transition logic (how system moves between arc phases -- time-based vs goal-based). System prompt that generates persona not shown (only validation rules).
- **STRENGTHS**: High-fidelity compliance (state-specific AI disclosure, GSM-7 analysis). Architectural rigor (Pydantic schemas for Whisper + Incentives). Measurable reciprocity (A/B with specific targets). Robust safety (comprehensive failure modes, self-harm distinction).
- **SUGGESTION**: Expand Section 9.5 to include state machine transition logic defining whether phase transitions are time-based, goal-completion-based, or hybrid.

### GPT-5.2 Chat2: 9.5
- **GAPS**: None material relative to rubric.
- **STRENGTHS**: Fully satisfies 9.5 bar. All 14+ rubric items explicitly addressed with code, schemas, or detailed specifications.
- **SUGGESTION**: Optional: add accessibility considerations and handoff transcript formatting.

### Codex (GPT-5.2): 8.5
- **GAPS**: Consent opt-in timing per jurisdiction not explicit. Escalation triggers missing handoff SLAs / after-hours handling. Multilingual handling missing locale detection fallback. Progressive profiling listed without abandonment recovery. Incentives lack over-incentivization guardrails. Metrics not mapped to decision thresholds.
- **STRENGTHS**: Comprehensive rubric coverage. Clear structure across all subsections. Whisper planner schema + extraction domains indicate implementation readiness. Multi-turn arcs + reciprocity show thoughtful engagement. EN/ES and consent scopes show compliance awareness.
- **SUGGESTION**: Add decision rules for consent timing, escalation SLAs, locale fallback, profiling recovery, incentive abuse safeguards, and metric-to-action mappings.

### Dimension 9 Score Summary

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

## Dimension 10: Production Readiness

### GPT-5.2: 9.5
- **GAPS**: Zero-downtime deployment present but no DB/schema migration strategy (backward-compatible Firestore field evolution). Minor completeness gap.
- **STRENGTHS**: CB + retry/backoff integrated with code. Scaling + cold start explicit. Cost per-component with scaling sensitivity. Health liveness/readiness with dependency criticality. Strong runbook, load testing, SLAs, capacity planning, backup/DR with drills. All rubric items covered.
- **SUGGESTION**: Add zero-downtime data evolution section: Firestore "schema migration" rules (additive fields, default handling, versioned readers/writers, backfill, rollback-safe toggles).

### Grok-4: 9.0
- **GAPS**: Graceful degradation lacks code-level detail (scenarios described but no code for detection/fallback). Operational runbook lacks code (table only, no scripts).
- **STRENGTHS**: Excellent depth on CB/retry (full classes/decorators), scaling/Firestore capacity (YAML, sharding code), cost analysis, health endpoint, rate limiting, logging, load testing, deployment.
- **SUGGESTION**: Include code snippets for fallback implementations in the graceful degradation section.

### Perplexity (Sonar Reasoning Pro): 9.2
- **GAPS**: Distributed rate limiting (in-memory only, multi-instance bypass risk with maxScale=10). No alerts tied to health endpoints. Canary rollback trigger criteria not explicit. Firestore backup lacks encryption/cross-region details. Message windowing MAX=40 not justified. No reserved capacity pricing.
- **STRENGTHS**: Comprehensive CB implementation (sliding window, asyncio.Lock, fail-open, singleton). Multi-layer scaling (Cloud Run + Firestore distributed counters). Cold start quantification with per-phase budget. Operational completeness (runbook + SLAs + RPO/RTO). PII handling exceeds basic compliance. k6 load testing bridges architecture to reality.
- **SUGGESTION**: Add Redis-based distributed rate limiting. Define explicit canary rollback triggers. Extend cost with reserved pricing. Justify windowing MAX=40.

### Gemini 3 Pro: 9.5
- **GAPS**: Observability privacy inconsistency (logging says "never log content" but LangFuse receives prompts/completions -- no PII redaction spec for LangFuse payloads). Load test at 100 concurrent is insufficient to validate maxScale=10 with 80 concurrency (~800 theoretical capacity).
- **STRENGTHS**: Cold start mitigation interplay (minScale=1 + startup budget + liveness vs readiness). Firestore distributed counters show deep platform knowledge. CI/CD with canary releases, metric monitoring, rollback scripts.
- **SUGGESTION**: Implement shared PII-redaction/scrubber class wrapping both Structured Logger and LangFuse SDK client.

### GPT-5.2 Chat2: 9.0
- **GAPS**: No automated post-rollback verification checks. No capacity forecast model tied to traffic growth. Cold start mitigation limited to minScale=1 (no warm-up or request hedging). Rate limiting lacks per-tenant fairness guarantees.
- **STRENGTHS**: Every rubric item explicitly covered with concrete artifacts. Full CB + retry + 5-service config. k6 load testing. Canary + rollback. DR with quarterly drills.
- **SUGGESTION**: Add post-deploy/rollback automated smoke tests. Include capacity forecast model. Document cold start strategy beyond minScale. Clarify tenant-aware rate limiting.

### Codex (GPT-5.2): 9.0
- **GAPS**: Retry backoff/jitter strategy not explicitly stated (but note: Section 10.14 does have full code with backoff+jitter parameters). Logging PII redaction vs allow-listing. Cost analysis lacks workload assumptions. Load test lacks duration and SLO pass/fail criteria.
- **STRENGTHS**: Covers all rubric areas with concrete artifacts (Cloud Run YAML, k6 script). Adds DR and health semantics beyond rubric.
- **SUGGESTION**: Specify retry backoff/jitter parameters. Define PII allow-list policy. Expand cost and load-test sections with assumptions and SLO criteria.

### Dimension 10 Score Summary

| Model | Score |
|-------|-------|
| GPT-5.2 | 9.5 |
| Grok-4 | 9.0 |
| Perplexity | 9.2 |
| Gemini 3 Pro | 9.5 |
| GPT-5.2 Chat2 | 9.0 |
| Codex | 9.0 |
| **Median** | **9.0** |
| **Mean** | **9.20** |

---

## Overall Score Summary

| Dimension | GPT-5.2 | Grok-4 | Perplexity | Gemini 3 Pro | GPT-5.2 Chat2 | Codex | Median | Mean |
|-----------|---------|--------|------------|--------------|---------------|-------|--------|------|
| 8. Observability | 9.5 | 9.0 | 9.0 | 9.5 | 9.0 | 9.0 | **9.0** | **9.08** |
| 9. Conversation Design | 9.5 | 9.5 | 8.5 | 9.5 | 9.5 | 8.5 | **9.5** | **9.17** |
| 10. Production Readiness | 9.5 | 9.0 | 9.2 | 9.5 | 9.0 | 9.0 | **9.0** | **9.20** |

---

## Consensus Gaps

### Dimension 8: Observability & Evaluation (Median 9.0)
1. **LangFuse vs alternatives comparison lacks depth** (4/6 models flagged): comparison exists but no formal decision matrix, no weighted criteria, no detailed trade-off on scalability/compliance/feature gaps
2. **Dual dashboards lack implementation detail** (3/6 models flagged): ASCII mockups are good but no rendering technology specified (Retool? Looker Studio? Custom React?), no backend API design, no refresh cadence
3. **Replay lacks determinism guarantees** (1/6 flagged but architecturally valid): no model version pinning, temperature pinning, or prompt hash for reproducible replay
4. **Evaluation drift monitoring absent** (1/6 flagged): no longitudinal model quality regression alerts

### Dimension 9: Conversation Design (Median 9.5)
1. **Phase transition logic undefined** (2/6 models flagged): 6-phase multi-turn arcs have full examples but lack explicit rules for phase transitions (time-based vs goal-completion vs hybrid)
2. **Language router implementation detail** (1/6 flagged but valid): regex features/thresholds + LLM confirmation schema + disagreement fallback not shown in code
3. **Integration testing absent** (2/6 flagged): no end-to-end test cases for cross-component interactions (persona + reciprocity + escalation together)
4. **Consent timing per jurisdiction** (1/6 flagged): opt-in timing varies by state but not specified per-jurisdiction

### Dimension 10: Production Readiness (Median 9.0)
1. **Rate limiting not distributed** (2/6 flagged): in-memory rate limiting works for minScale=1 but maxScale=10 means multiple instances could bypass limits -- needs Redis or equivalent
2. **Graceful degradation lacks code** (2/6 flagged): 8 scenarios with detection/fallback/impact described textually but no implementation code for fallback logic
3. **Schema migration / data evolution strategy missing** (2/6 flagged): zero-downtime deployment is present but no Firestore backward-compatible field evolution plan
4. **Load test insufficient for max capacity** (2/6 flagged): 100 concurrent tests below theoretical 800 capacity (maxScale=10 x concurrency=80)
5. **Canary rollback triggers not explicit** (2/6 flagged): canary described but automated rollback criteria (exact error_rate threshold, latency threshold) not formalized
