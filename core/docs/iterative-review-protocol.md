# Iterative Review Protocol

Origin: Hey Seven 2026-02-15 — 12 review rounds, 5 multi-model hostile reviews, 180+ findings, 3 context overflows solved.

**Trigger words**: review round, hostile review, architecture review, quality sprint, multi-model review

---

## When to Use This Protocol

- Architecture document review (10+ page design docs)
- Code quality review sprints (post-implementation)
- Multi-model hostile review (critical decisions)
- Any review that will generate 50+ findings

## TeamCreate Swarm Protocol (Prevents Context Overflow)

**Problem**: Review rounds R6-R8 caused 3 context overflows. Review findings + fix edits consumed too much main context.

**Solution**: TeamCreate swarm. Main lead NEVER sees full findings.

### Step-by-Step

```
STEP 1: Main lead creates team "review-round-N"
STEP 2: Main lead creates tasks:
  - Task A: "Review dimensions 1-5" (assigned to reviewer-alpha)
  - Task B: "Review dimensions 6-10" (assigned to reviewer-beta)
  - Task C: "Apply fixes from reviewer findings" (assigned to fixer, blocked by A+B)
  - Task D: "Write round summary" (assigned to fixer, blocked by C)

STEP 3: Teammates execute:
  - reviewer-alpha: Reads doc, writes findings to reviews/round-N/alpha.md
  - reviewer-beta: Reads doc, writes findings to reviews/round-N/beta.md
  - fixer: Reads BOTH finding files, applies fixes, writes summary

STEP 4: Main lead reads ONLY reviews/round-N/summary.md (5-10 lines)
STEP 5: Main lead shuts down team, reports to user
```

### Key Rules

1. **Findings go to FILES, not parent context** — reviewers write to `reviews/round-N/*.md`
2. **Fixer reads files, not messages** — no large finding payloads in team messages
3. **Main lead reads only summary** — never the detailed findings
4. **Max 4 teammates** — 2 reviewers + 1 fixer + 1 reserve
5. **Each reviewer covers 5 dimensions** — parallel, no overlap
6. **Fixer works bottom-up** in the doc to minimize line shift conflicts

## Dimension-Based Review Framework (10 Dimensions)

Split into two groups for parallel review:

**Group A** (reviewer-alpha):
1. Graph/Agent Architecture
2. RAG Pipeline
3. Data Model / State Design
4. API Design
5. Testing Strategy

**Group B** (reviewer-beta):
6. Docker & DevOps
7. Prompts & Guardrails
8. Scalability & Production Readiness
9. Trade-off Documentation
10. Domain Intelligence / Research Accuracy

Each dimension scored 1-10 with specific findings. Enables measurable progress tracking.

## Multi-Model Hostile Review Protocol

For critical decisions, use 3-5 different model families:

1. **Select models** from different families: Claude, Gemini, GPT, Grok, Perplexity
2. **Same prompt** to each model with the code/doc to review
3. **Cross-critique matrix**: each model critiques other models' findings
4. **Consensus scoring**: average scores across models, flag divergences > 2 points
5. **Final synthesis**: union of all unique findings, weighted by model agreement

### Model Selection Guide

| Model | Strength | Best For |
|-------|----------|----------|
| Claude (code-judge) | Code patterns, security | Primary code review |
| Gemini 3 Pro | Regulatory/safety angles | Compliance, streaming safety |
| GPT-5.2 Codex | Code structure, testing | Implementation quality |
| Grok 4 | Direct, contrarian | Challenging assumptions |
| Perplexity | Research-backed benchmarks | Best practice comparison |

### Key Insight

Score convergence across 3+ models in same range (e.g., 87-92) validates quality is genuine, not model-specific bias. Divergence > 5 points on same dimension = investigate (Gemini caught streaming-before-validation risk that Claude missed).

## Quality Sprint Pattern

After each review round, immediately apply fixes:

1. Review findings prioritized: Critical → Major → Minor
2. Fix bottom-up in file to minimize line shift conflicts
3. Run tests after each fix batch (not after all fixes)
4. Track: test count before vs after sprint
5. Commit with message: `fix: quality sprint R{N} — {count} findings addressed`

### Score Trajectory Tracking

| Round | Score | Delta | Key Theme |
|-------|-------|-------|-----------|
| R1 | baseline | -- | Foundation |
| R2 | +20-25 | biggest | Structural fixes |
| R3-R5 | +1-3 | diminishing | Polish |
| R6+ | 0 | converged | Done |

**When to stop**: Score convergence across 3+ consecutive rounds OR 3+ models in same range = done. Further rounds find only polish items.

## Promotional Language Detection

Strip from architecture/design documents:
- Superlatives: "single most impressive", "groundbreaking", "revolutionary"
- Evaluator quotes used as selling points (e.g., "Gemini CTO said...")
- Marketing phrasing in technical documents
- Unverified statistics or claims

## Research Fact Verification (MANDATORY)

AI-generated research MUST be verified against primary sources:
- Financial figures: Check Wikipedia, SEC filings, press releases
- Legal citations: Check court records, law firm alerts
- Regulatory status: Check if rules are still in effect (not vacated/overturned)
- Company metrics: Check against official announcements

Origin: Hey Seven R1 — 5 critical factual errors caught. Flutter/TSG merger cited at $12B (actual ~$6B). TCPA rule cited as effective (actually vacated by 11th Circuit). Would have been career-damaging in an interview.
