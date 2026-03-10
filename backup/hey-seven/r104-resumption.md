# R104 Pro Eval — Resumption Guide

## Status: HT EVAL PARTIALLY COMPLETE (15/30 scored before computer shutdown)

## What Was Done
1. Pre-flight: FORCE_PRO_MODEL=true verified working (smoke test OK)
2. HT eval started: 30 host_triangle scenarios with Pro model
3. Streaming judge (GPT-5.2) running concurrently
4. **15/30 scenarios completed and judged before shutdown**

## What Remains
1. **Re-run HT eval** — streaming results in `tests/evaluation/results/r104-ht-pro-streaming/` (15 files). The judge can re-judge existing files OR we can re-run the full 30.
2. **Relationship eval** (10 scenarios) — not started
3. **Profiling P8/P9/P10 eval** (10 scenarios) — not started
4. **Judge all results** and build comparison table
5. **Decision gate**: Pro vs Flash comparison

## Partial Results (15/30 HT Pro scored by GPT-5.2)

| Metric | Flash (R103, 86 scen) | Pro (R104, 15 scen) | Delta |
|--------|----------------------|---------------------|-------|
| B-avg | 6.51 | **6.78** | **+0.27** |
| P-avg | 5.06 | **5.23** | **+0.17** |
| H-avg | 5.05 | **5.36** | **+0.31** |

### Key Dimensions (the ones we're testing)
| Dim | Flash (R103) | Pro (R104, 15) | Delta |
|-----|-------------|----------------|-------|
| H9 Comp Strategy | 2.00 | **2.46** | +0.46 |
| P9 Host Handoff | 2.65 | **2.60** | -0.05 |
| H6 Rapport Depth | 4.40 | **4.67** | +0.27 |
| H10 Lifetime Value | 3.90 | **4.93** | **+1.03** |
| P6 Incentive Framing | 3.90 | **3.47** | -0.43 |
| P8 Profile Complete | 3.70 | **3.60** | -0.10 |

### Improved Dimensions (Pro vs Flash)
| Dim | Flash | Pro | Delta |
|-----|-------|-----|-------|
| B1 Sarcasm | 7.62 | **8.0** | +0.38 |
| B5 Emotional | 6.67 | **7.5** | +0.83 |
| P2 Active Probing | 6.51 | **7.2** | +0.69 |
| P3 Give-to-Get | 7.30 | **7.67** | +0.37 |
| H10 Lifetime Value | 3.90 | **4.93** | **+1.03** |

## Resumption Commands

### Option A: Resume incomplete HT eval (recommended)
The streaming dir has 15 completed scenarios. Re-run eval — it will overwrite existing files
but create new thread IDs. Judge the streaming dir after.

```bash
export $(grep "^GOOGLE_API_KEY=" .env | xargs)
export FORCE_PRO_MODEL=true

# Clear old streaming results (they'll have stale thread IDs)
rm -f tests/evaluation/results/r104-ht-pro-streaming/*.json

# Re-run full 30 HT scenarios
python3 tests/evaluation/run_live_eval.py \
  --pattern "host_triangle*.yaml" --round r104-ht-pro --timeout 120 \
  --streaming-dir tests/evaluation/results/r104-ht-pro-streaming

# In another terminal: streaming judge
export AZURE_AI_ENDPOINT=$(az keyvault secret show --vault-name kv-seekapa-apps --name AzureAIFoundry-Endpoint -o tsv --query value)
export AZURE_AI_KEY=$(az keyvault secret show --vault-name kv-seekapa-apps --name AzureAIFoundry-ApiKey -o tsv --query value)
python3 tests/evaluation/streaming_judge.py --watch tests/evaluation/results/r104-ht-pro-streaming --category all --output tests/evaluation/results/r104-ht-pro-judge-scores.json
```

### Option B: Judge existing 15 scenarios + run remaining
Judge the 15 existing streaming files, then run relationship + profiling evals.
Less optimal since we only have 15/30 HT but saves rate limit budget.

### Relationship + Profiling eval
```bash
export $(grep "^GOOGLE_API_KEY=" .env | xargs)
export FORCE_PRO_MODEL=true

python3 tests/evaluation/run_live_eval.py \
  --pattern "relationship*.yaml" --round r104-rel-pro --timeout 120 \
  --streaming-dir tests/evaluation/results/r104-rel-pro-streaming

python3 tests/evaluation/run_live_eval.py \
  --pattern "profiling_p8_p9_p10*.yaml" --round r104-prof-pro --timeout 120 \
  --streaming-dir tests/evaluation/results/r104-prof-pro-streaming
```

## Rate Limit Notes
- Gemini 3.1 Pro: 250 RPD free tier, ~10 RPM
- 15 scenarios completed = ~225 API calls used today
- Remaining budget: ~25 RPD (not enough for 15 more HT scenarios today)
- **Recommendation**: Resume HT eval tomorrow. Run relationship + profiling after HT.

## Files
- Eval log: `tests/evaluation/results/r104-ht-pro.log`
- Judge log: `tests/evaluation/results/r104-ht-pro-judge.log`
- Judge scores: `tests/evaluation/results/r104-ht-pro-judge-scores.json`
- Streaming results: `tests/evaluation/results/r104-ht-pro-streaming/*.json`
- Response file: `tests/evaluation/r104-ht-pro-responses.json` (written at eval end)
