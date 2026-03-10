# Iteration 2 Feedback -- Dimensions 5-7

Generated: 2026-02-17

---

## Dimension 5: Content Management

### GPT-5.2: 9.5
**GAPS**: None against stated rubric. Every required item explicitly covered with code-level detail.
**STRENGTHS**: End-to-end propagation design (Apps Script -> webhook -> Cloud Function -> embedding/indexing) with latency budget and cold-start mitigation. Strong data contract with per-column validation, protected ranges, server-side schema validation, and actionable editor feedback (cell comments + quarantine). Operational maturity: guardrails with severities, SLO/monitoring, rollback runbook with Force Re-sync tooling. Template-clone onboarding and explicit migration path.
**SUGGESTION**: Add explicit "details JSON schema" definition (JSON Schema per category) with representative valid/invalid examples and mapping to embedding/index fields.

### Grok-4: 9.5
**GAPS**: None -- all rubric items covered with required detail.
**STRENGTHS**: Exceptional depth with full code examples (Apps Script and Cloud Function), comprehensive breakdowns (latency steps, guardrail rules, migration phases), practical elements (runbooks, SLOs, training) that exceed basic rubric needs.
**SUGGESTION**: Expand migration path diagram in 5.10 to include pseudocode for Cloud Function integration point.

### Perplexity (Sonar Reasoning Pro): 9.0
**GAPS**: (1) Google Sheets UX justification beyond "why Sheets" not deeply analyzed. (2) Staff training depth -- no specifics on content structure, hands-on exercises, troubleshooting guides. (3) Guardrails enforcement mechanism unclear whether at Apps Script or Cloud Function layer.
**STRENGTHS**: Comprehensive code-level detail (80 lines Apps Script, 160 lines Cloud Function). Exhaustive operational coverage across all 11 rubric items. Production-grade SLO with burn rate alerting. Complete invalid data handling lifecycle.
**SUGGESTION**: Strengthen 5.1 with 2-3 sentence UX analysis: accessibility for non-technical staff, RACI mapped to permission tiers.

### Gemini 3 Pro: 9.5
**GAPS**: Fleet-wide schema evolution -- no specification for propagating schema changes (new columns, updated validation) to existing active casino sheets. Template creation covered but not ongoing template drift management.
**STRENGTHS**: Full Apps Script and Cloud Function implementations prove feasibility. _Quarantine sheet pattern is excellent for user-facing CMS.
**SUGGESTION**: Add "Fleet Update" script/process using Google Sheets API to programmatically inject columns and update validation rules across all registered casino spreadsheets.

### GPT-5 Pro (Brainstorm): 9.5
**GAPS**: Editor UX under-specified (missing draft->review->publish workflows, role/permission mapping, accessibility, mobile editing considerations). Webhook reliability (idempotency keys, ordered delivery, retry/backoff, dead-letter buffering). Schema evolution across active sheets.
**STRENGTHS**: (inferred from partial response -- tool output truncated)
**SUGGESTION**: (inferred from partial response -- tool output truncated)

### Codex (GPT-5.2 Code Review): 9.5
**GAPS**: "Why Sheets / UX fit" is implied but not explicit (editor workflows, permissioning, bulk edit). Exhaustive categories could be stronger (mapping to tabs/validation rules).
**STRENGTHS**: End-to-end automation is robust (Apps Script -> Cloud Function, HMAC, compare_digest, REQUIRED_FIELDS). Excellent data quality guardrails (column validation + quarantine + severities). Operational maturity (SLO, burn-rate alerting, rollback runbook, RACI, migration path).
**SUGGESTION**: Add "Why Sheets / UX" subsection documenting editor workflows + category coverage matrix mapping each category to tab/columns/validators.

---

## Dimension 6: Per-Casino Deployment & Infrastructure

### GPT-5.2: 9.5
**GAPS**: None against stated rubric. Every required item explicitly present with implementation detail.
**STRENGTHS**: Code-level completeness (Cloud Run YAML, Cloud Build YAML, Terraform module with IAM, DNS, monitoring). Strong isolation model (Firestore database-per-casino + per-casino service accounts + verification test). Operational readiness (per-casino alerting with Slack/PagerDuty, uptime checks, rollback, onboarding checklist). Specific scaling narrative with milestones.
**SUGGESTION**: Add break-glass/emergency access and secrets rotation procedure with Terraform/IAM snippets.

### Grok-4: 9.5
**GAPS**: None.
**STRENGTHS**: Comprehensive coverage of all rubric items with code-level details (YAML configs, Terraform modules, JSON schemas, scaling milestones), strong per-casino isolation, IaC, and operational aspects.
**SUGGESTION**: Include code snippet or diagram for cost model optimization levers.

### Perplexity (Sonar Reasoning Pro): 9.0
**GAPS**: (1) Network policies not explicitly mentioned for namespace isolation (no Kubernetes NetworkPolicy configs). (2) No disaster recovery/backup strategy or data recovery SLOs. (3) Terraform module at 300 lines may be insufficient for comprehensive resource coverage.
**STRENGTHS**: Concrete cost modeling ($111/mo, 78% margin). Code-level completeness (YAML, Terraform, Cloud Build with Trivy). Scaled milestone clarity (5/10/50). Onboarding efficiency (<4hr with 25+ checklist). Feature flag caching.
**SUGGESTION**: Add "Network Isolation & Security" subsection with default-deny NetworkPolicy, pod-to-pod traffic rules, and verification test output.

### Gemini 3 Pro: 9.5
**GAPS**: Feature flag propagation latency -- 5-min TTL cache introduces risk for emergency kill-switches, no cache invalidation mechanism described. State migration detail -- no Terraform state refactoring plan for splitting single-project state into regional states.
**STRENGTHS**: Comprehensive IaC packaging (Terraform "Casino-in-a-Box" with validation). Production-ready CI/CD (90% coverage gates, Trivy, rollback via revision routing). Granular economics ($111/mo with margin analysis).
**SUGGESTION**: Implement Pub/Sub-based cache invalidation for sub-second propagation of critical config changes.

### GPT-5 Pro (Brainstorm): 9.5
**GAPS**: Firestore DB isolation clarity (backup/restore cadence, index lifecycle, cross-casino reporting pattern). Secrets management (rotation policy automation, break-glass access, audit review). DNS (managed cert strategy, blue/green at L7, failover). Per-casino monitoring (SLOs/SLIs, synthetic checks, runbooks). Cost model ($111/mo potentially optimistic without logging/egress/CDN/WAF). CI/CD (canary rollout, migration sequencing). Cloud Run autoscaling (schedule-driven prewarming).
**STRENGTHS**: Solid Terraform module with 4-layer namespace isolation. Execution detail (full YAMLs, environment configs, flags). Onboarding process aligns with requirement. Scaling milestones show evolution. DNS integrated with deployment.
**SUGGESTION**: Package per-casino "observability kit" Terraform submodule with SLOs, dashboards, logs-based metrics, synthetic checks, and on-call alerts.

### Codex (GPT-5.2 Code Review): 9.0
**GAPS**: Per-casino feature flags not explicitly defined (no flag store, rollout strategy, or isolation model described).
**STRENGTHS**: Strong IaC coverage with full Terraform module, explicit namespace isolation (4 layers), clear Cloud Run and Cloud Build configs with Trivy, concrete cost/onboarding/scaling plans.
**SUGGESTION**: Add per-casino feature flag system design (flag namespace, rollout/rollback procedure).

---

## Dimension 7: Security & Compliance

### GPT-5.2: 9.5
**GAPS**: None against stated rubric. Every required item explicitly covered with concrete mechanisms and code-level detail.
**STRENGTHS**: STOP handling is end-to-end (keyword detection EN/ES, immediate consent update, outbound gating + scheduler enforcement, queue drain via Telnyx cancel API, immutable audit trail). Deterministic pre-LLM guardrails layered, prioritized, multilingual with explicit pattern counts and response templates. Compliance operationalized (TCPA validate_consent_for_send, CCPA export/delete, immutable consent events + Firestore rules). Strong tenant isolation with negative test expectation. API security and key management concrete (HMAC, replay, WIF, CMEK).
**SUGGESTION**: Add "control-to-evidence" table mapping each compliance control to (a) code module/function, (b) audit event type, (c) test(s) that validate it.

### Grok-4: 9.0
**GAPS**: Incident response lacks code-level detail (only high-level phases, no code/schema/implementation specifics). Escalation/handoff has some process details but minimal code.
**STRENGTHS**: Exceptionally detailed guardrails (5 layers, 73 patterns EN/ES, Python code, NamedTuple). Strong API security (HMAC, replay protection, secret rotation). Comprehensive audit logging (full schema, 13 event types, PII redaction, retention).
**SUGGESTION**: Add code-level details to incident response (function names, schemas, automated trigger code) to match guardrails/TCPA depth.

### Perplexity (Sonar Reasoning Pro): UNAVAIL
**NOTE**: Perplexity refused to grade, stating the task falls outside its core function as a search assistant. It offered to research compliance concepts instead.

### Gemini 3 Pro: 9.5
**GAPS**: No global circuit breaker / kill switch to sever LLM connections across all tenants during systemic incidents. No hallucinated offer detection (verification against valid offers database to prevent LLM fabricating promotions).
**STRENGTHS**: Outbound gate + queue draining via Telnyx cancel API provides deterministic "immediate cessation." Tenant isolation verification test moves isolation from theoretical to executable/auditable. Consent schema depth (revocation history array + immutable audit via Firestore security rules).
**SUGGESTION**: Introduce "Semantic Validator" or "Offer Verification Layer" cross-referencing LLM-generated monetary values against active campaign parameters before send.

### GPT-5 Pro (Brainstorm): 9.0
**GAPS**: AI disclosure (CA SB 243) not explicitly implemented with code-level enforcement (missing first-message copy, locale handling, retry semantics, re-disclosure triggers). LLM safety output validation lacks explicit code-level schema shown.
**STRENGTHS**: TCPA full consent schema + immutable trail. STOP handling broad keyword coverage. 5-layer bilingual guardrails (73 patterns). CCPA export + delete. 6-layer isolation. API security with replay protection, key rotation, KMS, Workload Identity. 13 audit event types with 7-year retention.
**SUGGESTION**: Implement CA SB 243 disclosure as code: inject on first message per conversation, localize EN/ES, log delivery, re-disclose on material AI changes.

### Codex (GPT-5.2 Code Review): 9.0
**GAPS**: AI disclosure (CA SB 243) not explicitly described with concrete message templates, delivery timing, enforcement/audit evidence. TCPA consent audit trail retention/immutability specifics (tamper-evident logs, signature of consent payloads) not spelled out.
**STRENGTHS**: Comprehensive STOP handling (multi-keyword EN/ES, 3-level enforcement, queue drain). Robust pre-LLM guardrails (5 layers, 73 patterns) and LLM safety. Strong data isolation (6 layers) and API security (HMAC + replay). CCPA, audit logging, escalation, incident response well covered.
**SUGGESTION**: Add explicit CA SB 243 disclosure mechanics (message copy, trigger timing, per-message enforcement checks) and make TCPA consent logs tamper-evident (hash chaining, retention policy).

---

## Score Summary

| LLM | Dim 5 (Content Mgmt) | Dim 6 (Per-Casino Deploy) | Dim 7 (Security & Compliance) |
|---|---|---|---|
| GPT-5.2 | 9.5 | 9.5 | 9.5 |
| Grok-4 | 9.5 | 9.5 | 9.0 |
| Perplexity | 9.0 | 9.0 | UNAVAIL |
| Gemini 3 Pro | 9.5 | 9.5 | 9.5 |
| GPT-5 Pro | 9.5 | 9.5 | 9.0 |
| Codex | 9.5 | 9.0 | 9.0 |
| **Mean** | **9.42** | **9.33** | **9.20** |
| **Median** | **9.5** | **9.5** | **9.0** |

---

## Consensus Gaps

### Dimension 5: Content Management
1. **Google Sheets UX workflow detail** (Perplexity, Codex, GPT-5 Pro): Editor workflows (draft->review->publish), permission mapping, bulk edit scenarios not deeply documented. The "why Sheets" comparison exists but lacks user-centered design rationale.
2. **Schema evolution / fleet update** (Gemini, GPT-5 Pro): No mechanism described for propagating schema changes (new columns, updated validation rules) to existing active casino spreadsheets. Template creation covered but ongoing drift management missing.
3. **Details JSON schema definition** (GPT-5.2): No formal JSON Schema per category for the Details JSON column; would reduce ambiguity and make validation more deterministic.

### Dimension 6: Per-Casino Deployment & Infrastructure
1. **Feature flag propagation latency** (Gemini, GPT-5 Pro): 5-minute TTL cache creates risk for emergency kill-switches. No cache invalidation mechanism (e.g., Pub/Sub push) for sub-second critical config propagation.
2. **Disaster recovery / backup** (Perplexity): No mention of per-casino backup mechanisms, failover procedures, or data recovery SLOs.
3. **Cost model completeness** (GPT-5 Pro): $111/mo may be optimistic without logging, egress, CDN, or WAF costs included.
4. **Feature flag system detail** (Codex): Feature flags present in Firestore but rollout strategy, isolation model, and rollback procedure not deeply specified.

### Dimension 7: Security & Compliance
1. **Incident response code-level detail** (Grok-4, GPT-5 Pro): Incident response described at process level (3 phases) but lacks function names, schemas, automated triggers, or code-level implementation specifics matching the depth of guardrails and TCPA sections.
2. **AI disclosure enforcement code** (GPT-5 Pro, Codex): CA SB 243 disclosure described with message template and feature flag but lacks code-level enforcement mechanics (injection logic, locale handling, retry semantics, delivery logging confirmation).
3. **Hallucinated offer detection** (Gemini): No verification of LLM-generated monetary values or promotional terms against a valid offers database to prevent legally binding fabricated rewards.
4. **Global kill switch** (Gemini): No documented circuit breaker to sever LLM connections fleet-wide during systemic incidents (prompt injection or poisoned model attack).
5. **TCPA tamper-evidence** (Codex): Consent audit trail uses Firestore security rules (append-only) but no explicit hash chaining or cryptographic tamper-evidence for consent payloads.
