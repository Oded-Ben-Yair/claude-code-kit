# Hostile Review Sprint Protocol

Origin: Hey Seven R35-R45 Sprint (2026-02-23/24) — 11 internal rounds, 77→95. R47-R51 External Sprint (2026-02-24/25) — 5 external multi-model rounds, 67→80 consensus (4 model families).

## When to Use

- After MVP is feature-complete, before production launch
- After major refactor, to validate quality
- When code review score needs quantified improvement

## Protocol Evolution (Use Upgraded from Start)

### Original Protocol (R35-R39): ~2 points/round, drifted down
- 2 reviewers (alpha: dims 1-5, beta: dims 6-10) + 1 fixer
- All 10 dimensions every round = shallow coverage
- No calibration = hostile drift (-6 points over 5 rounds)

### Upgraded Protocol (R40+): ~3-5 points/round, stabilized
- **Focused rounds**: 3 weakest dimensions per round, not all 10
- **Calibration agent**: reads all previous summaries, normalizes for drift
- **Split fixers**: 2 parallel fixers (one per dimension cluster)
- **Combined reviewer-fixer**: single agent for efficiency at ceiling

**Always start with Upgraded Protocol. Original is obsolete.**

## Team Composition (4 agents max)

| Agent | Role | When |
|-------|------|------|
| reviewer | Deep review of 3 focused dims | Always |
| calibrator | Normalize scores, detect drift | Always |
| fixer-alpha | Fix dims 1-5 findings | Parallel with beta |
| fixer-beta | Fix dims 6-10 findings + summary | Parallel with alpha |

At ceiling (<1 point headroom): use combined reviewer-fixer (1 agent) for efficiency.

## Dimension Scoring Rubric (10 universal dimensions)

| Dim | Name | Weight | What 9.0+ Requires |
|-----|------|--------|---------------------|
| D1 | Graph/Agent Architecture | 0.20 | SRP (<100 LOC/fn), validation loops, structured routing, bounded retries |
| D2 | RAG Pipeline | 0.10 | Per-item chunking, RRF reranking, idempotent ingestion, version-stamp purging |
| D3 | Data Model | 0.10 | TypedDict state with custom reducers, parity checks, serialization safety |
| D4 | API Design | 0.10 | Pure ASGI middleware, SSE streaming, rate limiting, security headers |
| D5 | Testing Strategy | 0.10 | 90%+ coverage, 0 failures, property-based tests, E2E graph tests |
| D6 | Docker & DevOps | 0.10 | --require-hashes, SBOM, digest pinning, multi-stage, non-root, health check |
| D7 | Prompts & Guardrails | 0.10 | Multi-layer normalization, 10+ languages, pre-LLM deterministic, fail-closed |
| D8 | Scalability & Prod | 0.15 | TTL jitter, circuit breaker, graceful shutdown, per-client locks, backpressure |
| D9 | Trade-off Docs | 0.05 | ADRs for every deferred decision, accurate pattern counts, runbook sections |
| D10 | Domain Intelligence | 0.10 | Multi-property configs, regulatory accuracy, onboarding checklists |

## Cross-Validation Pattern

Each finding must be confirmed by 2+ models before inclusion:
- `vertex_code_review` (GPT-5.2 Codex) — security + correctness focus
- `gemini-query` (thinking=high) — architecture + design focus

Reject claims not verified against actual code. R37 rejected 3 Gemini false positives, R45 rejected 4.

## Calibration Rules

1. If code DIDN'T change for a dimension but score dropped → restore previous score (reviewer drift)
2. If code DID change (fixes applied) → credit the improvement
3. If new CRITICALs found and fixed → that IMPROVES the dimension
4. Check for severity inflation: MINOR in R36 upgraded to MAJOR in R38 without code change = inflation

## MANDATORY External Multi-Model Gate (Before claiming any score above 85)

Origin: Hey Seven R47 (2026-02-24) — Internal review scored 96.7, external 4-model consensus scored 65. 31-point gap caused by calibration drift, same-model blind spots, and incremental scoring that credits deltas instead of absolute quality.

**Rule**: After every 10 internal rounds OR when internal score exceeds 85, run a full external multi-model review (minimum 3 models from different families). This is the REAL score. Internal scores are progress trackers, not quality assessments.

**Process**:
1. Commit and push all code (reviewers need the actual codebase, not cherry-picked files)
2. Launch 3-4 models in parallel: Gemini (thinking=high), Grok 4, GPT-5.2 Codex, DeepSeek
3. Each model reviews ALL 10 dimensions cold (no context from previous rounds)
4. Synthesize: consensus findings (2+ models agree) are REAL. Single-model findings need code verification.
5. The consensus score IS the project score. Internal score is retired.

**Why this works**: Different model families have genuinely different blind spots. Gemini catches normalization issues Claude misses. GPT catches performance anti-patterns. Grok challenges architectural complexity. DeepSeek finds logical flaws.

**Why internal reviews fail at ceiling**:
- Same model reviewing its own fixes = confirmation bias
- Incremental scoring credits deltas (+0.5 for fixing X) instead of absolute quality
- Calibration rules ("don't drop score if code didn't change") hide systemic issues
- 45 rounds of context makes everything look "normal" — fresh eyes see what you've normalized

## Calibration Rules (UPDATED)

1. ~~If code DIDN'T change for a dimension but score dropped → restore previous score (reviewer drift)~~ **RETIRED** — this rule hid systemic issues for 30+ rounds. A fresh reviewer scoring D8 at 5.0 when internal scored 9.0 is not "drift" — it's finding what you missed.
2. If code DID change (fixes applied) → credit the improvement proportionally
3. If new CRITICALs found and fixed → that IMPROVES the dimension
4. **NEW**: Internal scores are RELATIVE (progress tracking). External scores are ABSOLUTE (quality assessment). Never compare them directly.
5. **NEW**: If internal and external scores diverge by >15 points, the internal review process has a systemic flaw. Stop and fix the process before continuing.

## Diminishing Returns Detection

| Signal | Action |
|--------|--------|
| 0 CRITICALs for 2+ rounds | Codebase hardened, shift to ceiling-push |
| Score plateau ±0.5 for 3 rounds | Change strategy (focused dims, refactor debt) |
| <0.1 improvement/round | Approaching ceiling, consider stopping |
| Findings are all MINOR/style | Ceiling reached |
| **Internal score > 85** | **MANDATORY: Run external multi-model gate before claiming the score** |
| **Gap > 15 points (internal vs external)** | **STOP: Fix review process, not code** |
| **External consensus plateau ±1 for 2 rounds** | **Review loop exhausted for quick fixes. Shift to structural improvements (DI refactor, re2 ReDoS, load tests).** |
| **0 CRITICALs in latest external round** | **Codebase is production-ready. Remaining MAJORs are design preferences, not bugs.** |

## 3-Tier Reproducible Evaluation System (ADR-023, 2026-02-27)

Origin: Hey Seven R70 — 70 rounds of review, SD 7.5-15, unmeasurable ICC. Forced-finding quotas, anchoring bias, hostile framing, and specialist assignment prevent convergence.

### Tier 1: Deterministic Quality Gates (Prerequisite)

Run `pytest tests/test_doc_accuracy.py -v` BEFORE any LLM review. These tests replace LLM judgment for measurable facts (D5-D9). All must pass.

| Dimension | Test Class | Key Assertions |
|-----------|-----------|----------------|
| D5 Testing | TestDeterministicD5 | test_count >= 2500, coverage config, 0 xfails |
| D6 DevOps | TestDeterministicD6 | Dockerfile: multi-stage, non-root, require-hashes, HEALTHCHECK /live |
| D7 Guardrails | TestDeterministicD7 | 204 patterns, 6 categories, 145 confusables, re2-only |
| D8 Scalability | TestDeterministicD8 | No threading.Lock in async, TTLCache with jitter |
| D9 Docs | TestDeterministicD9 | ADR count >= 22, all have Status+Date, version parity |

### Tier 2: Frozen LLM Evaluation

Use `docs/eval-prompt-v2.0.md` (version-controlled, frozen). Key differences from v1:

| Removed | Why |
|---------|-----|
| "Minimum 5 findings, look harder" | Forces manufactured criticisms at ceiling |
| `{previous_scores_table}` | Anchoring bias |
| "HOSTILE" framing | Primes for negativity, inflates severity |
| `{spotlight_area}` + severity bump | Changes instrument between rounds |
| Specialist dimension assignment | Prevents ICC calculation |

All 4 models score ALL 10 dimensions. Record exact model version IDs. Use calibration anchors (3/6/9 examples) for consistency.

### Tier 3: Behavioral Scenario Evaluation

50 scenarios in `tests/scenarios/behavioral_*.yaml` (B1-B5, 10 each). Evaluated by LLM-as-judge against live agent or full-pipeline mock. No forbidden_keywords (R70 lesson).

### ICC Measurement Protocol

With all 4 models scoring all 10 dimensions:
1. Collect 40 scores (4 models x 10 dimensions)
2. Calculate ICC(2,1) — two-way random, single measures
3. ICC > 0.7 = acceptable reliability
4. ICC < 0.5 = prompt needs revision or model selection needs adjustment

### When to Stop Reviewing

| Condition | Action |
|-----------|--------|
| Tier 1 all green AND ICC > 0.7 AND 0 CRITICALs for 3 rounds | Stop — quality plateau reached |
| ICC < 0.5 for 2 rounds | Fix prompt or model selection, not code |
| SD < 2 for 3 consecutive rounds | Stable — stop unless seeking specific improvement |

### Forced-Finding Quotas: RETIRED

"Minimum N findings" quotas are permanently retired. At quality ceiling, manufactured findings:
- Inflate MINOR counts artificially
- Distort severity distribution
- Create noise that obscures real issues
- Cause score oscillation from round to round

New rule: "Report all findings at MAJOR or above. If fewer than 2, explain why."

## External Review Cadence (R47-R51 Learnings)

**Trajectory**: Each round yields +4 points initially, then plateaus. R48: +4, R49: +4, R50: +5, R51: +0.2. Structural sprint R52-R57: +16.6 (cold baseline), then +1.4, +3.0, +1.4, +2.3 per round.

**Optimal cadence**: 3-4 external review rounds per improvement cycle:
- Round 1: Baseline (find CRITICALs, establish score)
- Round 2: Fix CRITICALs, see +4-5 point jump
- Round 3: Fix remaining MAJORs, approach plateau
- Round 4 (optional): Confirm plateau, extract structural improvement list

**After plateau**: Stop review loop. Invest in structural changes (testing infra, DI, performance). Then restart review loop with fresh round.

**Model calibration spread**: Expect 10-15 point spread between models. Use median-based consensus, not mean. Grok tends harsh on docs (D9), GPT-5.2 finds cross-file logic bugs, Gemini catches domain gaps, DeepSeek finds normalization/encoding issues.

**Reviewer prompt context sensitivity** (R55-R56): Same code scored 9.6 then 8.5 because the prompt lacked observability context. External reviewers only see what you show them. ALWAYS include full system capabilities in the prompt — especially observability, output guardrails, and infrastructure that isn't visible in the reviewed file snippets.

**ADRs as score accelerators** (R52-R57): Each ADR adds +0.1-0.3 to D9. Going from 0 to 20 ADRs with review dates pushed D9 from 5.5→9.0. Front-load ADR creation before review rounds.

**Dimension-specialist assignment** (R52-R68): Assign each model to dimensions matching its strengths: Gemini=D1/D2/D3 (architecture), GPT-5.3=D4/D5/D6 (quality/testing), DeepSeek=D7/D8 (security/scalability), Grok=D9/D10 (docs/domain). Sharper than all-dimension reviews. R68 confirmed: GPT-5.3 Codex finds ETag/RFC compliance issues Claude misses. Grok catches doc-code parity drift (helpline numbers, pattern counts). DeepSeek finds Redis-mode header inconsistencies.

**Parallel implementation + review in one session** (R68): 6-wave parallel implementation (5 code waves + 1 review wave) completed in ~2 hours. Key: strict file ownership per wave (no two waves editing same file). Code waves before doc waves for shared data (pattern counts, helpline numbers). Pre-review with GPT-5.3 Codex catches RFC violations before the consensus round.

**New behavior requires same-wave tests** (R68): Every wave that adds new API behavior (ETag, Cache-Control, 304) MUST include test coverage in its scope. "Don't modify test files" instructions cause MAJOR findings in the review. Change to "create new tests for new behavior."

Origin: Hey Seven R52-R68 Sprint (2026-02-25/26) — R52-R57 (6 rounds, 67.7→92.4), R68 (1 round, 91.6→92.9).

## Cost Profile (per round)

- Opus API: ~$40-60 per round (dominant cost)
- External LLMs (Gemini, GPT-5.2): ~$2-5 per round
- Total 11 rounds: ~$500-700
- Best ROI: rounds 1-3 (highest CRIT count) and upgrade round (R40: +12 points)

## The 95+ Code Checklist (Apply From Day 1)

### Security (prevents R35-R39 CRITICALs)
- [ ] Multi-layer input normalization: URL decode (iterative 10x) → HTML unescape (2-pass) → NFKD → Cf+Cc strip → confusable replace (110 entries) → punctuation strip
- [ ] Never return mutable module-level data (always deepcopy)
- [ ] PII redaction fails CLOSED (safe placeholder, never pass-through)
- [ ] Streaming output: redact BEFORE streaming, not after

### Correctness (prevents R36-R43 CRITICALs)
- [ ] Hash-based IDs use \x00 delimiter between fields (prevents collision)
- [ ] TTLCache not @lru_cache for cloud credential rotation
- [ ] Rename propagation: grep ALL string references after refactoring
- [ ] Retry loops: reuse same specialist, don't re-dispatch

### Scalability (prevents R37-R44 CRITICALs)
- [ ] TTL jitter on all singleton caches (prevent thundering herd)
- [ ] asyncio.Lock not threading.Lock in async code
- [ ] Background tasks: catch ALL exceptions (not just CancelledError)
- [ ] SIGTERM graceful drain for SSE streams
- [ ] Per-client rate limiting (not global lock)

### Testing (prevents R40 + R47 CRITICALs)
- [ ] Auth middleware → update test fixtures IMMEDIATELY
- [ ] Coverage config covers ALL source directories
- [ ] 0 test failures (not "pre-existing" — those are real bugs)
- [ ] E2E tests through full graph with schema-dispatching mock LLM
- [ ] **Tests with auth ENABLED for at least 1 E2E test** (R47: all 4 models flagged neutered tests)
- [ ] **Tests with semantic classifier ENABLED for at least 1 E2E test** (R47: production's most impactful path untested)
- [ ] **Property-based tests (Hypothesis) for regex/normalization patterns** (R47: 185 patterns with 0 fuzz coverage)
- [ ] **Coverage without neutering** — 90% coverage with auth+classifier disabled is fake coverage

### DevOps (prevents R41 CRITICALs)
- [ ] pip install --require-hashes from day 1
- [ ] .dockerignore: reviews/, .hypothesis/, .claude/, docs/
- [ ] No curl in production image (Python urllib for health check)
- [ ] Per-step timeouts in CI/CD

### Parity & Propagation (prevents R69 MAJORs — NEW)
- [ ] **After any parity-sensitive value change, grep ALL file types for old value** — VERSION, pattern count, confusable count, helpline numbers, jurisdiction URLs. Miss one = MAJOR in next review.
- [ ] **HEALTHCHECK uses /live (always 200), not /health** — /health returns 503 when degraded (CB open), causing unnecessary container restarts in docker-compose
- [ ] **pip-audit targets production requirements file, not dev** — Docker installs from requirements-prod.txt, audit must match
- [ ] **Scaffolded code must be wired before claiming "implemented"** — grep `from module import X` in src/ — zero hits = not wired

### Distributed Systems (prevents R47 CRITICALs — NEW)
- [ ] **NEVER use asyncio.to_thread() for Redis in async code** — use redis.asyncio or Lua scripts. to_thread exhausts default thread pool (~8-10 on Cloud Run) under load.
- [ ] **Never hold async lock across I/O** — acquire lock, mutate local state, release lock. I/O goes outside.
- [ ] **Bidirectional distributed state sync** — if state promotes in one direction (closed→open), recovery must also sync (open→closed)
- [ ] **Non-atomic Redis operations = race condition** — use Lua scripts for check-then-act patterns (rate limiter sorted sets)
- [ ] **Fail-closed + degradation mode** — fail-closed on first failure is correct, but 3+ consecutive failures should degrade (not DoS all traffic)
- [ ] **Drain timeout < platform SIGKILL timeout** — Cloud Run default is 10s, don't set drain to 30s

### State Correctness (prevents R47 CRITICALs — NEW)
- [ ] **Guard-then-strip, never guard-then-warn** — if a specialist returns keys it shouldn't own, strip them (not log a warning)
- [ ] **Reducers must support deletion** — if _merge_dicts filters None, add tombstone pattern ("__UNSET__") so fields can be explicitly cleared
- [ ] **Normalization scoped to detection only** — never let normalized text (O'Connor→OConnor) leak into state or responses

### Review Execution (prevents R70 context exhaustion — NEW)
- [ ] **Call MCP review tools from main session, not subagents** — subagents reading 10+ source files exhaust their context window before writing any review output. Direct MCP calls with focused code excerpts (50-100 lines per dimension) are 3x more efficient.
- [ ] **Gemini Pro 503 fallback** — Gemini 3.1 Pro frequently 503s during high demand. Always have a fallback plan: Flash (same MCP), Grok (grok_reason), or GPT (vertex_chat).
- [ ] **Grok API uses `problem` not `prompt`** — grok_reason parameter is `problem`, not `prompt`. Check tool schema before calling.
- [ ] **Behavioral scenarios are evaluation rubrics, not unit test fixtures** — forbidden_keywords break mock LLMs. Use expected_keywords for automated tests, reserve behavioral quality evaluation for live agent or LLM-as-judge.
