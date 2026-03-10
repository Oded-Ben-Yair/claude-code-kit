# Session Handover: R77-R80 Sprint (3 of 4 rounds complete)

**Session ID**: `hey-seven-session-20260302-af39ae`
**Date**: 2026-03-02
**Health**: 85/100 (Good)
**Memory MCP Entity**: `hey-seven-session-20260302-af39ae`

---

## What Was Done

### R77 (commit 7e26b5b) — Safety + Fallback Rate
- 7 Spanish self-harm patterns in `guardrails.py` (211 total, was 204)
- 13 Spanish crisis patterns across 3 severity levels in `crisis.py`
- Allergy/dietary exclusion for age verification (`detect_age_verification`)
- Confirmation detection at `compliance_gate.py` position 7.9
- Validator temperature 0.0 → 0.3 in `nodes.py`
- Comp agent profile completeness gate REMOVED (was canned "explore rewards" loop)
- Momentum tier data added to `knowledge-base/casino-operations/momentum-tiers.md`

### R78-R79 (commit e427765) — Profiling + Behavioral Polish
- Profiling message ID-based replacement in `profiling.py` (fixed duplication bug)
- REQUIRED profiling question injection in `_base.py` (not "weave naturally")
- `profile_completeness_50` + birthday-from-occasion incentive triggers in `incentives.py`
- `format_handoff_summary()` in `extraction.py` for structured crisis handoff
- 4 few-shot response examples (EN + ES) in `prompts.py`
- Tone calibration sections in all 4 specialist agents
- Cross-turn profile injection from `extracted_fields` in `_base.py`
- Anti-slop guidance ("NEVER say I'd love to help you explore")

### R80 (commit 3551b78) — Validator Grounding
- Validation prompt rewritten: real venue names ALWAYS acceptable
- Only FAIL on numerical contradictions or invented venues
- Root cause: Gemini Flash knows Mohegan Sun venues but validator rejected them

### Metrics
- **Tests**: 3305 passed, 0 failures, 90.42% coverage
- **Files changed**: 25 files, +1087/-243 lines
- **New tests**: +69 tests (3236 → 3305)
- **GitHub**: Fully pushed (e7a345c = HEAD = origin/main)

---

## What Was NOT Done

### R80 Live Eval (INCOMPLETE — P0 for next session)
- The live behavioral eval was started but terminal closed at scenario 15/89
- **Early signal**: fallback rate dropped from 40% (R76) to 21% (R80 early)
- Eval needs full re-run with ALL R77-R80 fixes (current code)
- Then 3-model judge panel on results
- Then profiling eval (56 scenarios)

---

## 10 Key Learnings (Deep Learning Loop)

1. **Validator grounding = #1 fallback driver** — Gemini Flash knows real venues; validator was rejecting them as "fabrications." Only reject numerical contradictions.
2. **Parallel 3-worker sprints = highest efficiency** — strict file ownership, zero conflicts, 3x throughput. Default for 3+ independent fix areas.
3. **"Weave naturally" = ignored by LLM 90%+** — passive instructions are optional. Use REQUIRED/MUST for mandatory behavior.
4. **LangGraph add_messages: ID-based replacement** — pass original `msg.id` to replace, not append. Without this = duplicate AI messages.
5. **Profile completeness gates kill conversations** — personalize with profile data, never gatekeep RAG access behind it.
6. **Confirmation detection at compliance_gate = highest-impact fallback fix** — "Great, sounds good" should never hit RAG retrieval.
7. **Few-shot examples > lengthy tone instructions** — 4 calibrated examples anchor the LLM's register more than 200 words of description.
8. **extracted_fields as fallback for empty guest_context** — profiling node accumulates data that guest_context (form data) often lacks.
9. **Live eval: 89 scenarios = 30+ min** — start first, fix code while running, restart after fixes.
10. **Pattern count drift tests are valuable** — always update expected count alongside pattern additions.

---

## Technical State

```
Branch: main
HEAD: e7a345c (pushed to GitHub)
Tests: 3305 passed, 1 skipped, 0 failures
Coverage: 90.42%
Uncommitted: eval artifacts only (coverage.xml, old review docs)
```

---

## Next Session Prompt (Copy-Paste Ready)

```
Read the handover at .claude/handover-20260302-af39ae.md and MEMORY.md.

This is the R80 completion session. R77-R79 code is committed and pushed.
Current: 3305 tests, 0 failures, 90.42% coverage.

STEP 1: Run the live behavioral eval (89 scenarios):
  GOOGLE_API_KEY=<from-kv> python3 tests/evaluation/run_live_eval.py \
    --pattern "behavioral_*.yaml" --round r80-final

STEP 2: While eval runs, run the profiling eval (56 scenarios):
  GOOGLE_API_KEY=<from-kv> python3 tests/evaluation/run_live_eval.py \
    --pattern "profiling_*.yaml" --round r80-profiling

STEP 3: Judge behavioral responses with 3-model panel:
  Use gemini-query (thinking=high), azure_chat (GPT-5.2), grok_reason
  Batch 20 scenarios per judge call
  Score per-scenario on B1-B5 dimensions

STEP 4: Judge profiling responses with same panel:
  Score per-scenario on P1-P10 dimensions

STEP 5: Calculate dimension means, ICC, and overall score.
  Compare to R76 baseline: Tech 9.2, Behavioral 5.24, Profiling 2.99.
  Early signal: fallback rate dropped from 40% to 21%.

STEP 6: Write final R80 report with honest dimension-by-dimension assessment.
  Commit and push to GitHub.

Key API key: az keyvault secret show --vault-name kv-seekapa-apps \
  --name MarketingNewsletter-GeminiApiKey --query value -o tsv
```

---

## Score Trajectory

| Round | Technical | Behavioral | Profiling | Overall |
|-------|-----------|------------|-----------|---------|
| R52 | 67.7 | — | — | 67.7 |
| R68 | 92.9 | — | — | 92.9 |
| R72 | — | 4.1 (live) | — | — |
| R74 | 9.34 | 8.15 (mock) | — | 8.75 |
| R75 | 9.63 | 5.8 (live) | — | 7.72 |
| R76 | 9.2 | 5.24 (live) | 2.99 (live) | 5.81 |
| R80 | pending | pending (21% fallback early) | pending | pending |
