# Hostile Review Sprint Protocol

Origin: Production LLM agent projects — 70+ review rounds across multiple codebases, multi-model consensus scoring.

## When to Use

- After MVP is feature-complete, before production launch
- After major refactor, to validate quality
- When code review score needs quantified improvement

## Protocol (Use Upgraded from Start)

### Team Composition (4 agents max)

| Agent | Role | When |
|-------|------|------|
| reviewer | Deep review of 3 focused dims | Always |
| calibrator | Normalize scores, detect drift | Always |
| fixer-alpha | Fix dims 1-5 findings | Parallel with beta |
| fixer-beta | Fix dims 6-10 findings + summary | Parallel with alpha |

At ceiling (<1 point headroom): use combined reviewer-fixer (1 agent) for efficiency.

### Key Techniques

- **Focused rounds**: 3 weakest dimensions per round, not all 10
- **Calibration agent**: reads all previous summaries, normalizes for drift
- **Split fixers**: 2 parallel fixers (one per dimension cluster)
- **Combined reviewer-fixer**: single agent for efficiency at ceiling

## Dimension Scoring Rubric (10 universal dimensions)

| Dim | Name | Weight | What 9.0+ Requires |
|-----|------|--------|---------------------|
| D1 | Architecture | 0.20 | SRP (<100 LOC/fn), validation loops, structured routing, bounded retries |
| D2 | Data Pipeline | 0.10 | Per-item chunking, reranking, idempotent ingestion, stale data purging |
| D3 | Data Model | 0.10 | Typed state with custom reducers, parity checks, serialization safety |
| D4 | API Design | 0.10 | Pure middleware, SSE streaming, rate limiting, security headers |
| D5 | Testing Strategy | 0.10 | 90%+ coverage, 0 failures, property-based tests, E2E tests |
| D6 | DevOps | 0.10 | Hash-pinned deps, SBOM, digest pinning, multi-stage builds, non-root, health check |
| D7 | Safety & Guardrails | 0.10 | Multi-layer normalization, pre-LLM deterministic checks, fail-closed |
| D8 | Scalability | 0.15 | TTL jitter, circuit breaker, graceful shutdown, per-client locks, backpressure |
| D9 | Documentation | 0.05 | ADRs for every deferred decision, accurate counts, runbook sections |
| D10 | Domain Intelligence | 0.10 | Multi-property configs, regulatory accuracy, onboarding checklists |

## Cross-Validation Pattern

Each finding must be confirmed by 2+ models before inclusion. Reject claims not verified against actual code.

## Calibration Rules

1. Internal scores are RELATIVE (progress tracking). External scores are ABSOLUTE (quality assessment). Never compare them directly.
2. If code DID change (fixes applied), credit the improvement proportionally.
3. If new CRITICALs found and fixed, that IMPROVES the dimension.
4. If internal and external scores diverge by >15 points, the internal review process has a systemic flaw. Stop and fix the process before continuing.

## External Multi-Model Gate (Before claiming any score above 85)

After every 10 internal rounds OR when internal score exceeds 85, run a full external multi-model review (minimum 3 models from different families). This is the REAL score. Internal scores are progress trackers, not quality assessments.

**Process**:
1. Commit and push all code (reviewers need the actual codebase)
2. Launch 3-4 models in parallel from different families
3. Each model reviews ALL 10 dimensions cold (no context from previous rounds)
4. Synthesize: consensus findings (2+ models agree) are REAL. Single-model findings need code verification.
5. The consensus score IS the project score. Internal score is retired.

**Why this works**: Different model families have genuinely different blind spots. Cross-model consensus catches what any single model misses.

## Diminishing Returns Detection

| Signal | Action |
|--------|--------|
| 0 CRITICALs for 2+ rounds | Codebase hardened, shift to ceiling-push |
| Score plateau +/-0.5 for 3 rounds | Change strategy (focused dims, refactor debt) |
| <0.1 improvement/round | Approaching ceiling, consider stopping |
| Findings are all MINOR/style | Ceiling reached |
| Internal score > 85 | MANDATORY: Run external multi-model gate |
| Gap > 15 points (internal vs external) | STOP: Fix review process, not code |
| External consensus plateau +/-1 for 2 rounds | Review loop exhausted for quick fixes |
| 0 CRITICALs in latest external round | Codebase is production-ready |

## 3-Tier Reproducible Evaluation System

### Tier 1: Deterministic Quality Gates (Prerequisite)

Run deterministic tests BEFORE any LLM review. These tests replace LLM judgment for measurable facts (test counts, coverage config, Dockerfile checks, pattern counts). All must pass.

### Tier 2: Frozen LLM Evaluation

Use a version-controlled evaluation prompt (frozen between rounds). Key rules:
- NO forced-finding quotas ("minimum 5 findings" is retired)
- NO previous scores in prompt (anchoring bias)
- NO hostile framing (primes for negativity)
- NO spotlight area with severity bump (changes instrument between rounds)
- All models score ALL dimensions. Use calibration anchors (3/6/9 examples) for consistency.

### Tier 3: Behavioral Scenario Evaluation

Behavioral scenarios evaluated by LLM-as-judge against live agent or full-pipeline mock. Use expected_keywords for automated tests, reserve behavioral quality evaluation for live agent assessment.

### ICC Measurement Protocol

With all models scoring all dimensions:
1. Collect scores (N models x 10 dimensions)
2. Calculate ICC(2,1) — two-way random, single measures
3. ICC > 0.7 = acceptable reliability
4. ICC < 0.5 = prompt needs revision or model selection needs adjustment

### When to Stop Reviewing

| Condition | Action |
|-----------|--------|
| Tier 1 all green AND ICC > 0.7 AND 0 CRITICALs for 3 rounds | Stop |
| ICC < 0.5 for 2 rounds | Fix prompt or model selection, not code |
| SD < 2 for 3 consecutive rounds | Stable — stop unless seeking specific improvement |

## External Review Cadence

**Optimal cadence**: 3-4 external review rounds per improvement cycle:
- Round 1: Baseline (find CRITICALs, establish score)
- Round 2: Fix CRITICALs, see +4-5 point jump
- Round 3: Fix remaining MAJORs, approach plateau
- Round 4 (optional): Confirm plateau, extract structural improvement list

**After plateau**: Stop review loop. Invest in structural changes (testing infra, DI, performance). Then restart review loop with fresh round.

**Model calibration spread**: Expect 10-15 point spread between models. Use median-based consensus, not mean.

## Key Lessons

- **False positive validation**: ALWAYS read actual code before accepting reviewer findings. Reviewers often lack runtime context.
- **ADRs as score accelerators**: Each ADR adds +0.1-0.3 to D9. Front-load ADR creation before review rounds.
- **Dimension-specialist assignment**: Assign each model to dimensions matching its strengths for sharper reviews.
- **New behavior requires same-wave tests**: Every wave that adds behavior MUST include test coverage.
- **Forced-finding quotas are harmful**: At ceiling, manufactured findings inflate MINOR counts and distort scores.
- **Same-model review has confirmation bias**: Different model families see what your primary model normalizes.
- **Infrastructure without wiring = zero improvement**: Creating utilities without connecting them to consumers achieves nothing.
