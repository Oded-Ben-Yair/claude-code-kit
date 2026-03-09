# Team Memory: r97-audit

Created: 2026-03-05T10:00:00Z
Goal: Full architecture audit of all 12 hey-seven components. Read-only. No code changes. Determine production-readiness and gaps blocking 8.0+ behavioral scores.

## Context

- Project: hey-seven (AI Casino Host Agent)
- Current scores: B-avg 6.62, P-avg 5.12, H-avg 4.84
- Weakest dims: H9(1.9), P9(2.1), H10(3.5), P8(3.7), H6(4.0)
- Strategy decided: "Pro-First, Distill-Down" — but need audit before Phase 1 (Pro switch)
- Tests: ~3502 tests, 0 failures, 90%+ coverage
- Graph: 13-node StateGraph v2.4, 29 state fields, 17 feature flags
- Version: v1.5.0

## Output Format (per component)

Each auditor writes to `reviews/r97-audit/{component}.md` with:
1. **Files** — exact files, line counts
2. **Wiring Verification** — grep proof of imports from entry points
3. **Test Coverage** — test files, test count, what they actually test
4. **Live vs Mock** — are tests using live LLM or mocks?
5. **Known Gaps** — what's missing, broken, scaffolded
6. **Confidence %** — 0-100 production-readiness
7. **Verdict** — production-ready / needs-fixes / needs-new-tool / scaffolded

## 7 Questions Per Component

1. What exists? (files, line counts, entry points)
2. What's real vs scaffolded? (grep wiring verification)
3. What tests cover it? (test files, count, what they test)
4. Are tests REAL or MOCKED? (live LLM or mock dispatch)
5. Success rate (live eval pass rate)
6. Known gaps (missing, broken, fake)
7. Confidence level (0-100% production-readiness)

## Shared Decisions

<!-- Cross-team decisions that affect multiple auditors -->

## Agent: auditor-core

### Summary (4 components audited)

| Component | Files | Lines | Tests | Confidence | Verdict |
|-----------|-------|-------|-------|------------|---------|
| 1. Graph Architecture | 3 | 1,112 | ~173 | 88% | production-ready |
| 2. Router + Dispatch | 3 | 2,213 | ~272 | 85% | production-ready |
| 3. Specialist Agents | 8 | 1,863 | ~156 | 82% | production-ready (caveats) |
| 4. Guardrails + Compliance | 3 | 2,059 | ~372 | 92% | production-ready |

### Key Cross-Component Findings

1. **All 4 components are fully wired** — every file has imports traced from `app.py` entry point
2. **Mock testing dominates** — Rule 8 ("NO MOCK TESTING") is violated in E2E/integration tests. Only 1 live LLM test exists (`test_live_llm.py`). Guardrails are appropriately mock-free (regex-based).
3. **nodes.py is a 1,674-line monolith** — contains 8 node functions + routing + LLM management + tone enforcement. Should be decomposed.
4. **_base.py at 1,379 lines** — ~15 responsibilities. Should extract prompt builder.
5. **Guardrails are the strongest component** — 214 patterns, 11 languages, RE2, multi-layer normalization, 372+ tests including fuzz/ReDoS
6. **Flash->Pro model routing is deterministic** — well-designed, no extra LLM call needed
7. **No prompt token counting anywhere** — risk of exceeding model context window on complex turns
8. **Comp agent has hardcoded Mohegan Sun data** — breaks multi-property portability

### Reports Written
- `reviews/r97-audit/01-graph-architecture.md`
- `reviews/r97-audit/02-router-dispatch.md`
- `reviews/r97-audit/03-specialist-agents.md`
- `reviews/r97-audit/04-guardrails-compliance.md`

## Agent: auditor-pipeline

### Summary (4 components audited)

| Component | Files | Lines | Tests | Confidence | Verdict |
|-----------|-------|-------|-------|------------|---------|
| 5. RAG Pipeline | 5 | 1,686 | ~142 | 82% | production-ready |
| 6. Profiling + Extraction | 4 | 1,922 | ~325 | 75% | needs-new-tool |
| 7. Incentives + Crisis + Sentiment | 4 | 1,446 | ~205 | 85% | needs-new-tool |
| 8. Prompts + Persona | 2 | 1,385 | ~69 | 78% | needs-fixes |

### Key Cross-Component Findings

1. **All 15 files are fully wired** — every module has imports traced from production entry points (app.py, graph.py, tools.py, _base.py)
2. **Deterministic modules appropriately mock-free** — extraction, crisis, sentiment, slang, persona are all regex/VADER/business rules. No LLM mocking needed.
3. **LLM-dependent paths have live tests** — profiling_live.py (2 tests) validates Gemini schema acceptance. Whisper planner + extraction_llm have live integration tests.
4. **pipeline.py at 1203 LOC** — largest single file in these components. Mixes ingestion, retrieval, and caching. Should be split.
5. **prompts.py at 1052 LOC** — central prompt repository used by 5+ modules. Should split into system prompts, routing prompts, compliance data, few-shot examples.
6. **Dual completeness calculations** — whisper_planner.py uses simple field count while profiling.py uses proper weighted calculation. May diverge.
7. **No Firestore vector search live tests** — ChromaDB tested thoroughly, Firestore retriever only tested with mocked GCP SDK.

### Critical Gaps Blocking 8.0+ Scores

| Gap | Dimension | Score | What's Needed |
|-----|-----------|-------|---------------|
| No comp policy engine | H9 | 1.9 | CompStrategy tool with player worth/ADT rules |
| No structured handoff | P9 | 2.1 | HandoffOrchestrator tool (6-point summary) |
| No return-visit seeding | H10 | 3.5 | LTV Nudge Engine for frequency-based offers |
| Profile completeness ceiling | P8 | 3.7 | Pro model + smarter extraction (conversation length limit) |
| No micro-pattern retrieval | H6 | 4.0 | Rapport Ladder tool for guest-type-specific techniques |

### Key Insight

H9(1.9), P9(2.1), H10(3.5) are **missing business logic, not model capability**. Deterministic tools with typed schemas will have more impact than prompt optimization or model upgrade for these dimensions.

### Reports Written
- `reviews/r97-audit/05-rag-pipeline.md`
- `reviews/r97-audit/06-profiling-extraction.md`
- `reviews/r97-audit/07-incentives-crisis-sentiment.md`
- `reviews/r97-audit/08-prompts-persona.md`

## Agent: auditor-api

### Summary (4 components audited)

| Component | Files | Lines | Tests | Confidence | Verdict |
|-----------|-------|-------|-------|------------|---------|
| 9. API Layer | 6 | 2,294 | ~127 | 88% | production-ready |
| 10. CMS + SMS | 6 | 1,796 | ~155 | 82% | production-ready (consent store caveat) |
| 11. Observability | 3 | 770 | ~15 | 72% | needs-fixes |
| 12. Config + Flags | 5 | 2,201 | ~108 | 90% | production-ready |

### Key Cross-Component Findings

1. **All 20 files are fully wired** — every module has imports traced from production entry points
2. **Mock testing is structurally appropriate** for API/CMS/SMS (external service integrations). Streaming PII redactor and TCPA compliance logic are tested without mocks.
3. **Config layer is the strongest component** — import-time parity checks, immutable defaults, production secret validation, TTL jitter, double-check locking
4. **Observability is the weakest** — trace spans are local-only (not exported to Cloud Trace), no alerting on LangFuse failure, no request-ID correlation
5. **SMS consent store is in-memory only** — TCPA liability risk if enabled without Firestore backing
6. **Rate limiting is per-instance** — Redis backend exists but requires configuration for multi-instance Cloud Run
7. **Pure ASGI middleware correctly chosen** — BaseHTTPMiddleware would break SSE streaming

### Critical Gaps

| Gap | Component | Severity | What's Needed |
|-----|-----------|----------|---------------|
| Trace span export | Observability | MEDIUM | Export NodeSpan to Cloud Trace or LangFuse custom events |
| Consent persistence | SMS | MEDIUM | Wire ConsentHashChain to Firestore (code is ready) |
| Redis rate limiting | API | MEDIUM | Configure REDIS_URL for multi-instance deployment |
| No live Redis/Firestore tests | Config | MEDIUM | Add @pytest.mark.live integration tests |
| LangFuse failure alerting | Observability | LOW | Health check or metric for tracing connectivity |

### Reports Written
- `reviews/r97-audit/09-api-layer.md`
- `reviews/r97-audit/10-cms-sms.md`
- `reviews/r97-audit/11-observability.md`
- `reviews/r97-audit/12-config-flags.md`

## Agent: auditor-tests

### Key Findings
- **3555 tests collected**, 104 test files, 90.62% committed line coverage
- **Rule 8 ("NO MOCK TESTING") is violated**: 55 of 104 test files (52.9%) use mocks, 1694 mock occurrences total
- Only **3 files** import live LLM clients; only **16 tests** call real LLM (all skip-gated, none run in CI)
- **Guardrails testing is excellent**: 530+ tests, fuzz/ReDoS coverage, mostly deterministic (no mocks needed)
- **Auth + semantic classifier disabled by default** in conftest (re-enabled in 2 dedicated test files)
- **No CI-enforced live LLM tests** — schema compatibility only caught by manual local runs
- Conftest has comprehensive singleton cleanup (17 caches)

### Files Modified
- `reviews/r97-audit/13-test-reality-check.md`: Full audit report

### Verdict: ADEQUATE (with documentation dishonesty)
Test suite is structurally sound but Rule 8 compliance is fiction. Tests validate wiring/logic/error handling, not LLM output quality. Live behavioral quality measured by evaluation framework (outside pytest).
