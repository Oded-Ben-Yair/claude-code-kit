# Autonomous 30-Dimension Perfection Sprint

Read `docs/plans/2026-03-01-30dim-perfection-sprint.md` for the full dimension reference and gap analysis. Then execute the following 5 rounds autonomously.

You have a GOOGLE_API_KEY in your environment. The live agent is Gemini 2.5 Flash. Tests: 3236 passed. Version: v1.4.0. Graph: 12-node StateGraph v2.3.

## ROUND 1: BASELINE EVALUATION

### Step 1A: Run live eval (all 195 scenarios)
```bash
GOOGLE_API_KEY=$GOOGLE_API_KEY python3 tests/evaluation/run_live_eval.py --pattern "*.yaml" --round r76-baseline
```
This takes ~45 minutes (195 scenarios, ~15s/turn). Run in background. While it runs, proceed to Step 1B.

### Step 1B: Technical code review (D1-D10)
While live eval runs, review the codebase for D1-D10 using 4 MCP models. Call each directly (NOT via subagents):

**Gemini** (D1 Graph Architecture + D2 RAG + D3 Data Model):
Use `gemini-query` with thinking=high. Pass the contents of `src/agent/graph.py`, `src/agent/profiling.py`, `src/agent/state.py`, `src/rag/pipeline.py`. Ask it to score D1, D2, D3 on a 0-10 scale with evidence-based justification and any MAJOR+ findings.

**GPT-5.2** (D4 API + D5 Testing + D6 DevOps):
Use `azure_chat`. Pass `src/api/app.py`, `src/api/middleware.py`, `Dockerfile`, `tests/conftest.py`. Score D4, D5, D6.

**Grok 4** (D7 Guardrails + D8 Scalability + D9 Docs):
Use `grok_reason`. Pass `src/agent/guardrails.py`, `src/agent/circuit_breaker.py`, `ARCHITECTURE.md`, list of ADR titles from `docs/adr/`. Score D7, D8, D9.

**DeepSeek** (D10 Domain):
Use `azure_deepseek_reason`. Pass `src/casino/config.py` (CASINO_PROFILES), `src/agent/prompts.py` (system prompt). Score D10.

### Step 1C: Judge behavioral + profiling responses
After live eval completes, read `tests/evaluation/r76-baseline-responses.json`.

Split responses into batches of 20. For each batch, call 3 models in parallel:

**For behavioral (B1-B10)**: Use the judge rubric from `tests/evaluation/batch-judge-prompt.txt`. Call `gemini-query`, `azure_chat`, `grok_reason` with the batch. Each scores B1-B10 per scenario.

**For profiling (P1-P10)**: Use the judge rubric from `tests/evaluation/profiling-eval-prompt.md`. Call the same 3 models with profiling scenario batches. Each scores P1-P10 per scenario.

### Step 1D: Synthesize baseline scores
Aggregate all scores into a 30-dimension table:
```
| Dim | Gemini | GPT-5.2 | Grok | DeepSeek | Median | Status |
|-----|--------|---------|------|----------|--------|--------|
| D1  | ...    | ...     | ...  | ...      | ...    | ...    |
...
| P10 | ...    | ...     | ...  | ...      | ...    | ...    |
```

Write results to `tests/evaluation/r76-baseline-scores.json`.
Identify the 5 LOWEST-scoring dimensions. These are Round 2 targets.

---

## ROUND 2: FIX LOWEST 5

### Step 2A: Diagnose root causes
For each of the 5 lowest dimensions, classify the failure:
- **Score < 5** → WIRING issue (code exists but doesn't fire live). Action: trace code path, add logging, verify feature flags.
- **Score 5-7** → PROMPT issue (code fires but LLM doesn't comply). Action: edit system prompt.
- **Score 7-8** → EDGE CASE issue (works for happy path, fails on tricky inputs). Action: add patterns/regex/scenarios.

### Step 2B: Apply fixes
Use a team with 2 parallel code-workers (strict file ownership):
- **prompt-tuner**: Owns `src/agent/prompts.py`, `src/agent/whisper_planner.py`
- **code-fixer**: Owns `src/agent/profiling.py`, `src/agent/agents/_base.py`, `src/agent/extraction.py`, `src/agent/incentives.py`

Each worker reads the diagnosis, applies targeted fixes, runs `pytest tests/ -x -q --no-cov` to verify no regressions.

### Step 2C: Re-evaluate fixed dimensions
Run live eval for ONLY the affected scenario files:
```bash
# Example: if B3 and P2 were fixed
GOOGLE_API_KEY=$GOOGLE_API_KEY python3 tests/evaluation/run_live_eval.py \
  --pattern "behavioral_b3_*.yaml" --round r76-fix1-b3
```

Judge with 2 models (quick validation). Update scores.

---

## ROUND 3: FIX NEXT 5

Same protocol as Round 2 for dimensions ranked 6th-10th lowest.

---

## ROUND 4: POLISH (8+ dimensions)

For dimensions scoring 8-8.9:
1. Read the specific live agent responses that scored 7-8
2. Identify the prompt language causing the gap
3. Apply surgical prompt edits (1-2 sentences, not rewrites)
4. Re-run only affected scenarios
5. Verify improvement without regression

---

## ROUND 5: FINAL CONSENSUS

Run full evaluation again:
```bash
GOOGLE_API_KEY=$GOOGLE_API_KEY python3 tests/evaluation/run_live_eval.py --pattern "*.yaml" --round r76-final
```

Judge ALL 30 dimensions with ALL 4 models. Calculate ICC(2,1) for reliability. Write final report to `tests/evaluation/r76-final-report.md`.

---

## Rules (NON-NEGOTIABLE)

1. **LIVE agent only** — mock overestimates by 40% (proven R72-R75)
2. **MCP tools directly** — do NOT use subagents for judging (they exhaust context)
3. **Validate findings against code** — reviewers are often wrong. Read the actual file before accepting a finding. R74: 5/14 MAJORs were false positives.
4. **Fix prompts before code** — prompt changes are cheaper and often higher ROI
5. **Max 5 dims per fix round** — more causes context pollution and regressions
6. **Run pytest after every code change** — 3236 must remain 0 failures
7. **Never use `Explore` subagent** — hardcoded to haiku. Use `general-purpose` with `model: opus`
8. **Commit after each round** — git commit with round number and score delta

## Between Rounds: Learning Loop

After each round, before starting the next:
1. Which fixes worked? WHY did they work?
2. Which fixes didn't work? WHY not?
3. What pattern can I extract for the next round?
4. Are there dimensions where the fix strategy needs to change?

Write 3-5 bullets to `tests/evaluation/r76-learning-log.md` after each round.

## When to Stop

- **All 30 dims >= 9.0**: Gold. Done. Ship it.
- **25+ dims >= 9.0, none < 7.0**: Silver. Document gaps in ADRs. Stop.
- **ICC < 0.5 on any dimension**: Fix the eval prompt, not the code.
- **Same dimension doesn't improve after 2 fix rounds**: Structural limitation, not a quick fix. Document in ADR and move on.
