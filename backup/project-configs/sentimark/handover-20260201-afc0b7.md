# Sentimark Comprehensive Handover — Production Readiness Plan

**Session**: sentimark-session-20260201-afc0b7
**Date**: 2026-02-01 18:23 UTC
**Health**: 65/100 (Acceptable — Memory MCP down, ghost deletions in git)
**Purpose**: Complete context for next agent session to plan all remaining work to production readiness

---

## 1. WHAT IS SENTIMARK

A **market prediction system** that uses a **4-LLM ensemble** (GPT5-Pro, Perplexity, Gemini, Grok) plus **8 intelligence sources** to generate directional predictions (bullish/bearish/neutral) for **134 assets** across crypto, stocks, forex, commodities, and indices.

### Architecture
```
asset_rotation_timer (every 2 min)
└── For Tier-1 assets (up to 3 per cycle):
    └── LLMPredictionEngine.generate_predictions()
        ├── GPT5-Pro (25.6%) ── direct prediction + reasoning
        ├── Perplexity (30%) ── search-grounded real-time analysis
        ├── Gemini (24.4%) ── pattern comparison + macro regime
        └── Grok (20%) ── X/Twitter social sentiment
    └── 8 Intelligence Sources
        ├── fear_greed ── market sentiment index
        ├── technical ── yfinance technical indicators
        ├── social_sentiment ── Perplexity API social analysis
        ├── geopolitical ── Perplexity API geopolitical scoring
        ├── political ── Perplexity API political impact
        ├── crowd_wisdom ── Kalshi (traditional) + Polymarket (crypto) + Manifold (fallback)
        ├── financial ── financial metrics
        └── ai_consensus ── meta-consensus from other sources
    └── Consensus Engine (V2 production, V3 shadow)
    └── Store to prediction_history table
```

### Infrastructure
| Component | Details |
|-----------|---------|
| Backend | `polymarket-analyzer` Azure Function App (Python) |
| Frontend | `sentimark-v2-frontend` Azure Web App (Next.js) |
| Database | `polymarket_analyzer` on `postgres-seekapatraining-prod.postgres.database.azure.com` |
| Pipeline | `sentimark-backend-deploy` (Azure DevOps) |
| Git | `git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/sentimark` branch `master` |
| Key Vault | `kv-seekapa-apps` secret `Sentimark-DbConnectionString` |

### Live URLs
| Service | URL |
|---------|-----|
| Frontend | https://sentimark-v2-frontend.azurewebsites.net/v2 |
| Backend API | https://polymarket-analyzer.azurewebsites.net/api |
| Source Health | https://polymarket-analyzer.azurewebsites.net/api/v2/admin/source-health |

---

## 2. CURRENT SYSTEM STATE (Verified Feb 1, 2026)

### What's Working
| Component | Status | Evidence |
|-----------|--------|----------|
| Backend API | ✅ ONLINE | health 200, 32 crypto assets returned |
| Frontend | ✅ ONLINE | Next.js build clean (18 routes) |
| Predictions | ✅ RUNNING | Every 2 min, 134 assets |
| Intelligence (8/8) | ✅ HEALTHY | All sources returning real data, overall fallback 0.09% |
| LLM Ensemble (4/4) | ✅ WORKING | All 4 LLMs returning features |
| Portfolios | ✅ ACTIVE | 3 active (Conservative +0.70%, Moderate +0.95%, Aggressive -0.36%) |
| V3 Shadow Mode | ✅ LOGGING | Shadow data collecting since Feb 1 13:00 UTC |
| Pipeline | ✅ CLEAN | #10238 succeeded (latest) |

### What's Broken / Needs Work

| Issue | Severity | Details |
|-------|----------|---------|
| **Prediction accuracy** | **P0** | 86.9% neutral rate, ~15% overall accuracy, 9.9% crypto — system is architecturally biased toward NEUTRAL |
| **V3 not yet validated** | **P0** | Shadow data collecting but no evaluation done yet. Need 72h+ data (target Feb 4) |
| **5 crypto crowd_wisdom fallback** | P2 | MATIC, BNB, HBAR, CRV, PEPE still using fallback (CRV missing from MANIFOLD_SEARCH_TERMS) |
| **llm_raw_outputs stale** | P3 | Logging stopped Jan 15, low priority |
| **price_history empty** | P3 | Never populated, low priority |
| **Ghost git deletions** | P3 | 9 files show as deleted from reverted cleanup — cosmetic, `git checkout -- .` to fix |
| **Memory MCP permission error** | P3 | `/usr/lib/node_modules/.../memory.json` EACCES — need `sudo chown` or reinstall |

---

## 3. THE ACCURACY PROBLEM (Core Challenge)

### Root Cause Analysis (7 compounding failure modes)
1. **Generic prompt** says "extract features, don't predict" → LLMs return timid center-biased scores
2. **7→3 direction collapse** loses granularity (slightly_bullish → bullish)
3. **Score compression**: `score = 0.6 * confidence` further compresses toward zero
4. **Confidence miscalibration**: production avg is 0.035 (should be 0.3-0.9)
5. **Adaptive threshold** (0.10-0.15) rejects most compressed scores → NEUTRAL
6. **Disagreement checks** (>0.55 → uncertain) add more neutral paths
7. **Coherence penalty** (30% confidence reduction) suppresses remaining directional signals

### What's Been Done (Phases 1-7 of plan COMPLETE)
- **Phase 1**: Data audit confirmed 86.9% neutral, 9.9% crypto accuracy
- **Phase 2**: Deep research on SOTA LLM-based prediction (prompt engineering, ensemble methods)
- **Phase 3**: Multi-model debate on 4 key decisions (direct prediction, Thompson consensus, crypto pipeline, neutral strategy)
- **Phase 4**: All APIs audited, all 8 sources + 4 LLMs verified working
- **Phase 5**: New prompt templates designed (category-specific, horizon-specific, LLM-differentiated)
- **Phase 6**: V3 algorithm designed (Thompson sampling, Platt scaling, dynamic LLM weighting)
- **Phase 7**: V3 implemented and deployed in shadow mode (commit 39f9f9e, 73 tests, migration 055)

### What's Remaining (Phase 8: Validation & Iteration)
- Evaluate V3 shadow data (72h+ needed, target Feb 4)
- If V3 shows improvement: switch `CONSENSUS_VERSION=v3` as default
- If V3 insufficient: iterate on prompts/thresholds
- Continue until targets met

### Success Criteria
| Metric | Current | Minimum Target | Stretch |
|--------|---------|----------------|---------|
| Overall accuracy | ~15% | >33% (above random) | >45% |
| Crypto accuracy | 9.9% | >30% | >40% |
| Neutral rate | 86.9% | 40-50% (balanced) | <40% |
| Directional accuracy | ~11% | >25% | >40% |
| Brier score | 0.697 | <0.35 | <0.25 |

### Statistical Methods Required
- **Permutation tests** for significance (NOT t-tests — <500 samples)
- **Bootstrap 95% CIs** for accuracy differences
- **Cohen's h** for effect size on proportions

---

## 4. COMPLETE NEXT STEPS TO PRODUCTION READINESS

### P0: V3 Shadow Evaluation (IMMEDIATE — data should be ready ~Feb 4)

```bash
# 1. Check shadow data volume
python3 scripts/monitor_v3_shadow.py

# 2. Query shadow predictions directly
# SELECT model_version, direction, COUNT(*) FROM prediction_history
# WHERE model_version IN ('v2', 'v3') AND created_at > '2026-02-01'
# GROUP BY model_version, direction;

# 3. Run full evaluation with bootstrap CIs
# python3 evaluation/v3_evaluation.py  (may need to create/verify this exists)

# 4. Compare V3 neutral rate vs 86.9% baseline
# Compare V3 accuracy vs V2 accuracy per category
```

**Decision gate**: If V3 reduces neutral rate significantly AND doesn't reduce accuracy → switch to V3. If V3 is worse → iterate.

### P0: Switch CONSENSUS_VERSION (if V3 passes evaluation)

```bash
# Azure Function App → Configuration → Application settings
# Change: CONSENSUS_VERSION=v2 → CONSENSUS_VERSION=v3
# Or via CLI:
az functionapp config appsettings set -g AZAI_group -n polymarket-analyzer \
  --settings CONSENSUS_VERSION=v3
```

### P1: Iterate if V3 Insufficient

If V3 doesn't meet targets:
1. Analyze which LLMs contribute most to errors
2. Tune Thompson sampling hyperparameters
3. Adjust category-specific neutral thresholds
4. Consider adding new data sources (funding rates, open interest, DEX volume)
5. Re-evaluate prompts for specific failure categories

### P1: Frontend Asset Page Inventory

User requested a comprehensive inventory of every feature on the asset detail page. This was deferred due to the production outage. Needs to be done to identify gaps and plan improvements.

### P2: Fix Remaining Crowd Wisdom Fallbacks

5 crypto still falling back: MATIC, BNB, HBAR, CRV, PEPE
- CRV definitely missing from `MANIFOLD_SEARCH_TERMS` in `shared/external/manifold_client.py`
- Others may need better search terms

### P2: New Data Source Integration (evaluated but not implemented)

From Phase 4 research, these were identified as high-value:
| Source | API | Value For |
|--------|-----|-----------|
| Funding rates | Binance/Bybit | Crypto 24h predictions |
| Open interest / liquidations | Coinglass | Crypto sentiment |
| DEX volume / TVL | DefiLlama | DeFi token predictions |
| Whale transactions | Whale Alert | Crypto large-move prediction |
| Economic calendar | FOMC/CPI dates | All asset timing |
| Options flow / put-call ratio | TBD | Stock predictions |

### P3: Cleanup & Maintenance

- Fix ghost git deletions: `git checkout -- "29-01 chagpt report" SVG audit-session-18437`
- Fix Memory MCP permission: `sudo chown -R $USER /usr/lib/node_modules/@modelcontextprotocol/server-memory/`
- Investigate llm_raw_outputs staleness (stopped Jan 15)
- Consider debug folder cleanup (444M)

---

## 5. KEY FILES MAP

| Purpose | Location |
|---------|----------|
| Backend entry point | `function_app.py` |
| LLM prediction engine | `shared/rotation/llm_prediction.py` |
| V3 consensus (shadow) | `shared/rotation/llm_prediction.py` (V3 class alongside V2) |
| Asset rotation timer | `shared/rotation/asset_rotation.py` |
| Intelligence sources | `shared/intelligence/` (8 modules) |
| External API clients | `shared/external/` (Kalshi, Polymarket, Manifold, etc.) |
| Crowd wisdom routing | `shared/intelligence/crowd_wisdom.py` |
| Manifold search terms | `shared/external/manifold_client.py` |
| Source cache (fallback) | `shared/intelligence/source_cache.py` |
| V3 monitor script | `scripts/monitor_v3_shadow.py` |
| V3 evaluation | `evaluation/v3_evaluation.py` (verify exists) |
| Pipeline config | `azure-pipelines.yml` |
| System truth doc | `docs/SYSTEM_TRUTH.md` |
| Project config | `CLAUDE.md` |
| Status tracking | `.claude/status.json` |
| Accuracy plan | `~/.claude/plans/shimmering-marinating-deer.md` |
| Frontend | `sentimark-v2/frontend/` (Next.js) |

---

## 6. CRITICAL RULES (MUST FOLLOW)

1. **Schema-first**: ALWAYS query `information_schema.columns` before writing SQL
2. **Wire-before-commit**: Every new file must be traceable from `function_app.py`
3. **NEVER bulk-delete from shared/**: One file per commit, verify pipeline + function count > 0 between each
4. **Explore agent dead code is unreliable**: 87% false positive rate
5. **After deploy verify function count > 0**: `az functionapp function list -g AZAI_group -n polymarket-analyzer --query "length(@)"`
6. **Permutation tests for <500 samples**: NOT t-tests
7. **CONSENSUS_VERSION env var**: Never switch V3 without statistical evidence
8. **V1 paths in Function App**: imports from `shared/`, NOT `sentimark-v2/backend/shared/`
9. **Pipeline deploys ROOT requirements.txt**: Not subdirectory
10. **Key Vault for creds**: Never hardcode connection strings

---

## 7. RECENT INCIDENT HISTORY

### 2026-02-01: Bulk Cleanup Broke Production (RESOLVED)
- Cleanup commit 955c974 deleted 4 files from shared/ (zero grep imports)
- Deploy succeeded but function app had 0 functions — all APIs 404
- Reverted via de5613c, pipeline #10238 restored service
- **Lesson**: grep zero imports ≠ safe to delete

### 2026-01-22: Intelligence Sources Dead (RESOLVED)
- Perplexity model deprecated, missing is_fallback flag, migration 033 not applied
- Fixed all three root causes, fallback rate dropped from 40% to 0.09%

---

## 8. NEXT SESSION PROMPT (COPY-PASTE READY)

```
You are continuing work on Sentimark, a market prediction system.

## Current State (Feb 1, 2026)
- Backend: ONLINE (polymarket-analyzer Azure Function App)
- Frontend: ONLINE (https://sentimark-v2-frontend.azurewebsites.net/v2)
- All 8 intelligence sources HEALTHY, all 4 LLMs WORKING
- V3 consensus engine in SHADOW MODE since Feb 1 13:00 UTC
- V2 is production default (CONSENSUS_VERSION=v2)

## The Core Problem
Prediction accuracy is poor: 86.9% neutral rate, ~15% overall accuracy, 9.9% crypto. The system is architecturally biased toward NEUTRAL due to 7 compounding failure modes (score compression, confidence miscalibration, aggressive disagreement checks).

## What's Been Done (Phases 1-7 COMPLETE)
A comprehensive 8-phase plan (see ~/.claude/plans/shimmering-marinating-deer.md) addressed this:
- Data audit, deep research, multi-model debate, API audit, prompt redesign, algorithm redesign all COMPLETE
- V3 consensus engine implemented with Thompson sampling + Platt scaling + dynamic LLM weighting
- Deployed in shadow mode (commit 39f9f9e, 73 tests, migration 055 applied)

## Immediate Tasks (in priority order)

### P0: V3 Shadow Evaluation
V3 has been collecting shadow data since Feb 1 13:00 UTC. Evaluate:
1. Run `python3 scripts/monitor_v3_shadow.py` to check data volume
2. Query prediction_history for V3 vs V2 distribution (neutral rate, direction breakdown)
3. Run full statistical evaluation: permutation tests + bootstrap CIs (NOT t-tests, <500 samples)
4. Compare against baseline: 86.9% neutral, ~15% accuracy, 9.9% crypto
5. If V3 meets minimum targets (neutral <50%, accuracy >33%): switch CONSENSUS_VERSION=v3

### P1: Asset Page Inventory
Create comprehensive list of every feature/section on the asset detail page at /v2/assets/[symbol]. User needs this to plan improvements.

### P2: Fix 5 crypto crowd_wisdom fallbacks
MATIC, BNB, HBAR, CRV, PEPE still falling back. CRV missing from MANIFOLD_SEARCH_TERMS in shared/external/manifold_client.py.

### P2: Evaluate new data sources
Funding rates (Binance), open interest (Coinglass), DEX volume (DefiLlama), whale transactions (Whale Alert), economic calendar — all identified but not integrated.

## Key Files
- Backend entry: function_app.py
- LLM engine: shared/rotation/llm_prediction.py
- Intelligence: shared/intelligence/ (8 modules)
- External APIs: shared/external/ (Kalshi, Polymarket, Manifold)
- V3 monitor: scripts/monitor_v3_shadow.py
- System truth: docs/SYSTEM_TRUTH.md
- Status: .claude/status.json
- Plan: ~/.claude/plans/shimmering-marinating-deer.md

## Critical Rules
- Schema-first: query information_schema before SQL
- Never bulk-delete from shared/ (one file per commit)
- Explore agent dead code detection: 87% false positive rate
- After deploy: verify function count > 0
- Permutation tests for <500 samples, NOT t-tests
- V1 paths: imports from shared/, NOT sentimark-v2/backend/shared/

Read CLAUDE.md and docs/SYSTEM_TRUTH.md for full context.
```
