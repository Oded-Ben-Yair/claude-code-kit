# Sentimark - Project Configuration

**Last Verified**: February 23, 2026 08:00 UTC
**Status**: **CATEGORY-SPECIFIC GROK CALIBRATION IMPLEMENTED (Feb 23)** — Global 0.6 insufficient (25.8% bullish). Root cause: stocks 38.4% bullish is multi-LLM consensus, not Grok-only. Fix: commodities=1.0, forex=1.0, global=0.6. Code+tests done, Azure env vars set. Awaiting deploy.

**GUIDING DOCUMENT**: `docs/IRON_DOME_IMPLEMENTATION_PLAN.md` — ALL sessions must reference this plan. 35 tasks across 5 phases.
**Architecture**: `docs/ARCHITECTURE_CURRENT.md` v2.0 (9.5+/10 all dimensions, multi-LLM validated)
**Decision**: `docs/ARCHITECTURE_DECISION.md` (6-model council, unanimous Iron Dome approval)

---

## Persona (Auto-Activated)

You are a **Senior Data Scientist and Analytics Engineer** specializing in market analysis and prediction systems. You automatically:
- Ensure statistical validity and reproducibility
- Track data quality and lineage
- Optimize for large dataset performance
- Document methodologies clearly
- Generate actionable insights from data

---

## Current System State (Verified 2026-02-22 10:00 UTC)

| Component | Status | Evidence |
|-----------|--------|----------|
| **Frontend** | ✅ ONLINE | Rendering at live URL |
| **Backend API** | ✅ ONLINE | **180 functions**, health 200 |
| **Predictions** | ⚠️ **69.3% NEUTRAL** | Feb 23 (n=1,600 so far). Bullish 25.8%, Bearish 4.9%. |
| **V2 Accuracy** | ⚠️ **41.4% (7-day)** | Paper trade TRADE: 43.9% (n=8,690), value add +4.9% |
| **Category Accuracy** | Mixed | Forex **52.1%** TRADE, Indices 46.9%, Crypto 36.2%, Stocks 27.7%, Commodities 23.9% |
| **Weekend Skip** | ✅ **VERIFIED Feb 22** | Stocks/indices 0 on Sat. 3 WTI midnight-boundary leak (negligible). |
| **Grok Calibration** | ⚠️ **CATEGORY-SPECIFIC** | Global 0.6 insufficient (25.8% bull). commodities=1.0, forex=1.0, global=0.6. Awaiting deploy. |
| **Confidence** | ✅ **CALIBRATED Feb 10** | Pocket-based calibration wired into consensus. Uses historical base rates per category+direction. |
| **Intelligence Sources** | ✅ **8/8 healthy** | All 0% fallback |
| **LLM Ensemble** | ✅ **4 of 4** | GPT-5 Pro (20%), Grok (40%), **Claude (25%)**, Perplexity (15%) |
| **Perplexity** | ✅ **FIXED Feb 9** | Was 60% failure (sonar-reasoning-pro), now sonar-pro + retry + fallback |
| **V3 Consensus** | ⚠️ **SHADOW MODE** | k_threshold lowered 0.50→0.25 Feb 10. Forex neutral_band 0.15→0.10. |
| **Evaluator** | ✅ **WORKING** | V2: 4,183 evaluated, V3: 1,498 evaluated (backlog flushed Feb 10) |
| **Migrations** | ✅ **055-062 APPLIED** | Latest: 062 (paper_trade_log). All applied. |
| **Edge Gate v1** | ⚠️ **GP3 IN SHADOW (Feb 14)** | GP3 retrained: WF-AUC 0.582, TRADE 57.6%, 216 distinct probs. Rule gate primary: forex 69.0% (n=303). GO/NO-GO #4: CONDITIONAL GO. |
| **Paper Trade** | ✅ **ACTIVE** | Rule gate: TRADE 46.1% (n=753), NO_TRADE 33.2% (n=669). Forex 69.0%. |

### Accuracy Timeline

| Date | Event | Neutral Rate | Accuracy | n |
|------|-------|-------------|----------|---|
| Feb 3 | Coherence bug fix | 42.1% | 25.0% | 64 |
| Feb 4 | P0 baseline | 42.1% | 25.0% | 64 |
| Feb 5 | Context deploy | 53.7% | — | — |
| Feb 6 | Claude integration | **79.4%** | — | — |
| Feb 7 | Consensus fix deploy | 71.7% | — | — |
| Feb 8 | Phase 0 deploy | 67-72% | 35.5% | 2,373 |
| Feb 9 | Perplexity fix + Phase 1 | 73.5% | — | — |
| **Feb 10** | **GO/NO-GO #1** | **75.8%** | **41.9%** | **4,183** |
| **Feb 10** | **Perfection Sprint** | 74.7% | **41.1%** | **4,733** |
| **Feb 10** | **GO/NO-GO #2** | — | WF-AUC 0.6342 | NO-GO (Conditional) |
| **Feb 11** | **GO/NO-GO #3** | 71.5% | TRADE 45.1% (n=122) | **DEFINITIVE NO-GO** |
| **Feb 12** | **GP1+GP2+GP4 verified** | 64-76% | Features flowing | Distinct probs 6→35 |
| **Feb 14** | **GP3 retrained + GO/NO-GO #4** | — | ML: WF 57.6%, Rule: 46.1% | CONDITIONAL GO |
| **Feb 16** | **3 accuracy fixes deployed** | 72.9% | Bullish 22.3% (-3.5pp) | 336 (post-deploy) |
| **Feb 22** | **Weekend verify + 1-week eval** | 71.8% avg | Forex 60.5%, Bullish 24.0% | 4,127 (6 days) |
| **Feb 23** | **Category-specific calibration** | 69.3% | Bullish 25.8% (factor 0.6) | 1,600 (5.5h Mon) |

**Key finding (Feb 23 — Grok calibration 0.6 evaluation)**: Factor 0.6 INSUFFICIENT — bullish 25.8% (target <22%), worse than 24.7% with 0.7. Root cause: stocks 38.4% bullish is multi-LLM consensus, not Grok-only bias. Category breakdown: forex 1.5% bull (great), crypto 19.5%, commodities 17.9% (improved from ~0% at 0.7), stocks 38.4%, indices 33.6%. FIX: category-specific calibration — commodities=1.0, forex=1.0, global=0.6. Code+tests done, Azure env vars set, awaiting deploy. Paper trade (30-day): TRADE 43.9% win rate (n=8,690), value add +4.9% vs no-gate.

**Key finding (Feb 22 — 1-week evaluation)**: Weekend skip VERIFIED. Grok calibration 0.7 PARTIAL: bullish 24.7% avg. Post-deploy: forex 60.5% (up), commodities 23.2% (down — global dampening caused it).

- **Full reports**: `docs/GONOGO4_VERDICT.md`, `docs/GONOGO3_VERDICT.md`, `docs/GOLDEN_PIECES.md`
- **NEXT**: Deploy category-specific calibration code, monitor 24h. Evaluate if stocks need a separate approach (not Grok bias, but genuine multi-LLM bullish consensus).

### Recent Changes (Feb 23)

**Feb 23 — Category-Specific Grok Calibration** (CODE CHANGE, awaiting deploy)
- **Global 0.6 evaluated**: Bullish 25.8% (n=1,600, 5.5h Monday). INSUFFICIENT — target <22%.
- **Root cause identified**: Stocks 38.4% bullish driven by multi-LLM consensus, NOT Grok-only bias. Global dampening can't fix multi-LLM agreement.
- **Category-specific implemented**: `GROK_CALIBRATION_FACTOR_<CATEGORY>` env vars override global factor. Commodities=1.0, Forex=1.0, global=0.6.
- **Rationale**: Commodities accuracy collapsed 38.3%→23.2% because global dampening pushed neutral to 93.4% while market was highly volatile (only 21.4% actually neutral). Forex is best category (52.1% TRADE win rate), no dampening needed.
- **Files modified**: `shared/rotation/llm_prediction.py`, `tests/unit/test_grok_calibration.py`
- **Tests**: 19/19 pass (5 new category-specific tests)
- **Azure env vars**: `GROK_CALIBRATION_FACTOR_COMMODITIES=1.0`, `GROK_CALIBRATION_FACTOR_FOREX=1.0` set

### Recent Changes (Feb 22)

**Feb 22 — Weekend Skip Verification + 1-Week Evaluation** (DATA ANALYSIS ONLY, no code changes)
- **Weekend skip VERIFIED**: Stocks 0, indices 0 predictions on Sat Feb 21. 3 WTI commodity leaked at midnight boundary (negligible race condition).
- **Grok calibration 0.7 PARTIAL**: Weekday bullish avg 24.7% (23.4-25.9%), target <22% not fully met.
- **Grok calibration LOWERED 0.7→0.6** via Azure App Settings (no code deploy).

### Recent Changes (Feb 16)

**Feb 16 — 3 Accuracy Fixes** (DEPLOYED, pipeline #10466, commit `e5ec1fc`)
- **Weekend skip**: Stocks/indices/commodities predictions skipped on weekends (markets closed)
- **Grok calibration factor 0.7→0.6→category-specific**: Initial 0.7 (Feb 16), lowered to 0.6 (Feb 22), then category-specific (Feb 23): commodities=1.0, forex=1.0, global=0.6
- **Stocks bearish gate rule**: Pocket threshold 0.950 for stocks bearish predictions (`ENABLE_STOCKS_BEARISH_TRADE=true` env var)
- Files: `shared/rotation/llm_prediction.py`, `shared/rotation/asset_rotation.py`, `shared/ml/gate_rules.py`
- Post-deploy (36h, n=336): Bullish 25.8%→22.3% (-3.5pp), Neutral 72.9%, Bearish 4.8%
- GP5 indices conditional filter: bullish BLOCKED (10.3% acc), neutral TRADE (60.4%), bearish TRADE (46.7%)
- Weekend skip: INCONCLUSIVE (deployed after Saturday — verify Feb 21-22)
- **Portfolio validation**: All 3 portfolios (Conservative $99,666, Moderate $99,484, Aggressive $99,310) visually validated + DB cross-checked. One intermittent P2 position loading timeout.

### Recent Changes (Feb 5-8)

**Feb 5 — Diversified LLM Context** (READY, NOT ENABLED)
- Feature flag: `DIVERSIFIED_CONTEXT=false` — each LLM gets specialized context to reduce correlated errors
- Strategy: Perplexity (News+Social), GPT-5 (Fundamentals), Grok (Technical+Social), Claude (Macro)
- Enable: Set `DIVERSIFIED_CONTEXT=true` in Azure App Settings

**Feb 6 — Claude Opus 4.6 Integration** (DEPLOYED, ACTIVE)
- `ENABLE_CLAUDE_LLM=true` in Azure App Settings
- Claude replaces Gemini as "Strategic Synthesis Analyst" — macro context focus
- Key Vault: `Sentimark-AnthropicApiKey` → `ANTHROPIC_API_KEY` env var
- Files: `shared/llm_clients/claude_client.py`, `shared/rotation/context_builder.py`
- Cost: ~$225/month at 3,000 predictions/month
- Deployed via pipeline #10344 (commit `db693ef`)

**Feb 7 — Consensus Fix + Weight Rebalance** (DEPLOYED, commit `0ae9b86`)
- `base_threshold` lowered 0.15 → 0.08, floor 0.10 → 0.05
- Contrarian bullish→neutral override **DISABLED** (bullish was 75% correct)
- Mixed signals gate softened 0.35 → 0.50
- Static weights rebalanced: Grok 40%, Claude 25%, GPT-5 20%, Perplexity 15%
- All weight dicts use 'claude' keys natively (not 'gemini')
- `_adapt_weights_for_claude()` only remaps legacy 'gemini' keys from bandit DB
- Static/dynamic blend shifted 70/30 → 60/40 (more bandit influence)
- Migration 059: claude rows in bandit_state_v2 (replaced gemini rows)
- Pipeline #10344 succeeded, 180 functions

**Feb 7 — Additional Fixes** (commits `b6842ab`, `b761433`, `75749bd`)
- GPT-5 API version fix (was returning 404)
- llm_raw_outputs now populated from V3 breakdown format
- V3 evaluator fix + confidence dampening raised 0.4 → 0.7

### Verification Query (Run After Changes)
```sql
-- Check intelligence source health (should show 0% fallback)
SELECT * FROM source_health_summary;

-- Check real intelligence scores (not all 50)
SELECT symbol, geopolitical_score, political_score, social_score,
       geopolitical_is_fallback, political_is_fallback
FROM asset_profile WHERE updated_at > NOW() - INTERVAL '10 minutes';
```

---

## Quick Start

```bash
# V2 Frontend
cd ~/projects/sentimark/sentimark-v2/frontend
npm run dev          # http://localhost:3001

# Backend Deploy
git push azure master
# Or manually: func azure functionapp publish func-sentimark-prod --python

# Frontend Deploy (NO pipeline — manual Kudu zip deploy)
cd ~/projects/sentimark/sentimark-v2/frontend
rm -rf .next && npm run build
# Then package standalone + static + public into zip and deploy:
# curl -X POST -u '$sentimark-v2-frontend:<pass>' --data-binary @deploy.zip \
#   https://sentimark-v2-frontend.scm.azurewebsites.net/api/zipdeploy
# Get password: az webapp deployment list-publishing-profiles -g AZAI_group -n sentimark-v2-frontend
```

**Live Site**: https://sentimark-v2-frontend.azurewebsites.net/v2

---

## Architecture (Current - Feb 8, 2026)

```
asset_rotation_timer (every 2 min)
    └── For Tier-1 assets (up to 3 per cycle):
        └── LLMPredictionEngine.generate_predictions()
            ├── Grok (40%) - ✅ WORKING (highest accuracy: 53.3%)
            ├── Claude Opus 4.6 (25%) - ✅ ACTIVE (replaced Gemini)
            ├── GPT-5 Pro (20%) - ✅ WORKING
            └── Perplexity (15%) - ✅ FIXED (sonar-pro + retry + fallback)
        └── Intelligence gathering - ✅ ALL 8 WORKING
            ├── fear_greed, technical, social_sentiment
            ├── geopolitical, political, financial
            ├── crowd_wisdom, ai_consensus
        └── V2 consensus (weighted average, threshold 0.08)
        └── V3 consensus (shadow mode, 1498 evaluated)
        └── Store to prediction_history + llm_raw_outputs
        └── Edge Gate v1 (if ENABLE_EDGE_GATE=true)
            ├── Extract 25 features (disagreement, category, intelligence scores)
            ├── XGBoost predict P(correct) → TRADE/NO_TRADE
            ├── Bearish crypto bypass (73.9% accuracy)
            ├── Kill-switch (auto-disable if accuracy <50%)
            └── Log to gate_monitoring_log (shadow or live)
```

### Core Tables
| Table | Purpose | Status |
|-------|---------|--------|
| `prediction_history` | V2 predictions | ✅ ACTIVE |
| `asset_profile` | Asset master data + intelligence scores | ✅ ACTIVE |
| `virtual_portfolios` | Portfolio tracking | ✅ ACTIVE |
| `llm_raw_outputs` | LLM response log | ✅ ACTIVE (fixed Feb 5) |
| `gate_monitoring_log` | Edge Gate decisions | ✅ ACTIVE (migration 060, 264+ new-code decisions) |

---

## Deployment URLs

| Service | URL |
|---------|-----|
| V2 Frontend | https://sentimark-v2-frontend.azurewebsites.net/v2 |
| Backend API | https://func-sentimark-prod.azurewebsites.net/api |
| Source Health | https://func-sentimark-prod.azurewebsites.net/api/v2/admin/source-health |
| Prediction Health | https://func-sentimark-prod.azurewebsites.net/api/v2/admin/prediction-health |

---

## Database

**Server**: `postgres-seekapatraining-prod.postgres.database.azure.com`
**Database**: `polymarket_analyzer`
**User**: `sentimark_app_user`
**Credentials**: Key Vault `Sentimark-DbConnectionString`

### Important Columns (Migration 033)
```
*_is_fallback columns track when sources return fallback vs real data:
- geopolitical_is_fallback, political_is_fallback, social_is_fallback
- crowd_wisdom_is_fallback, fear_greed_is_fallback, technical_is_fallback
- financial_is_fallback, ai_consensus_is_fallback
```

---

## Iron Dome Implementation — Current Phase

**Master Plan**: `docs/IRON_DOME_IMPLEMENTATION_PLAN.md` (35 tasks, 5 phases, multi-LLM validated)

### Completed: Pre-Phase 0 + Phase 0 (Tasks 0.1-0.5)

| Task | Status | Result |
|------|--------|--------|
| **P0.0** Merge Smart Gate v1 | ✅ DONE | Merged at `4c384f0`, 80 tests |
| **P0.1** Apply migration 060 | ✅ DONE | `gate_monitoring_log` — 10 columns verified |
| **P0.2** Deploy merged master | ✅ DONE | Shadow mode active, 795+ decisions logged |
| **P0.3** Enable shadow mode | ✅ DONE | `ENABLE_EDGE_GATE=true`, `EDGE_GATE_SHADOW=true` |
| **0.1** Compliance framework | ✅ DONE | `shared/compliance/disclaimers.py`, migration 061 applied |
| **0.2** Evaluation harness | ✅ DONE | `scripts/evaluation_harness.py`, AUC=0.73, Brier=0.13, ECE=0.09 |
| **0.3** Imbalance metrics | ✅ DONE | `imbalance_metrics.py`, `calibration_curve.py`, `regime_slicer.py` |
| **0.4** Gate debiasing + pocket mining | ✅ DONE | `pocket_thresholds.py` + `POCKET_MINING_REPORT.md`, 7 pockets |
| **0.5** Paper-trade integration | ✅ DONE | `paper_trade.py`, migration 062 applied, `/api/v2/gate/paper-trade` |

### Active: Task 0.6 (Flip Shadow → Live) — **GP3 Shadow Evaluation**

**GP1-GP5 COMPLETE** (Feb 16). Current status:
1. ~~**GP1**: Fix V3 key mismatch~~ ✅ DONE — distinct probs 6→35
2. ~~**GP2**: Rule-based gate~~ ✅ DONE — forex 69.0% (n=303)
3. ~~**GP3**: Retrain model~~ ✅ DONE — WF-AUC 0.582, TRADE 57.6%, 216 distinct probs
4. ~~**GP4**: Block stocks/commodities~~ ✅ DONE
5. ~~**GP5**: Indices conditional filter~~ ✅ DONE — bullish BLOCKED, neutral/bearish TRADE
6. ~~**GO/NO-GO #4**~~ ✅ CONDITIONAL GO — GP3 shadow, rule gate primary
7. ~~**Accuracy fixes**~~ ✅ DEPLOYED — weekend skip + Grok calibration 0.7 + stocks bearish gate (pipeline #10466)
8. ⏳ Verify weekend skip effectiveness (Feb 21-22) + evaluate Grok calibration at 1-week mark

### Upcoming: Phase 1 (Weeks 3-8)

| Task | Summary |
|------|---------|
| 1.1 | Regime Radar (RegimeClassification model) |
| 1.2 | Gate alert system (`/api/v2/gate-alerts`) |
| 1.3 | Confidence API v2 (calibrated, category-specific) |
| 1.4 | Do-Not-Trade signals (market events) |
| 1.5 | LunarCrush reactivation (crypto sentiment) |
| 1.6 | Frontend integration (gate status UI) |

### Legacy Remaining Items (Lower Priority)

| Item | Priority | Status | Notes |
|------|----------|--------|-------|
| Enable DIVERSIFIED_CONTEXT | P1 (Phase 3.6) | READY | Part of Iron Dome Phase 3 |
| Fix Perplexity 60% failure rate | P1 | ✅ DONE Feb 9 | Switched sonar-reasoning-pro→sonar-pro + retry + fallback chain |
| Recalibrate confidence scoring | P1 (Phase 1.5) | ✅ DONE Feb 10 | Pocket-based calibration wired into consensus return path |
| AccuracyCalculator wrong table | P2 | NOT STARTED | `shared/accuracy/calculator.py` queries deprecated `prediction_daily` |
| V3 abstention thresholds | P2 | ✅ DONE Feb 10 | k_threshold 0.50→0.25 (all 15 entries), forex neutral_band 0.15→0.10 |
| Source health API endpoint | P2 | ✅ DONE Feb 10 | Endpoint working (HTTP 200, valid JSON). Was failing due to missing `--compressed` flag in curl test. |
| Duplicate ticker cleanup | P3 | NOT STARTED | EURUSD/EURUSD=X, DJI/^DJI, VIX/^VIX |
| Portfolio total_return_pct | P3 | ✅ DONE Feb 10 | Fixed 3 SQL queries to compute `((current_value/NULLIF(starting_value,0))-1)*100` instead of reading stuck column |

### Completed Items (Feb 2-8)

| Date | Fix | Commit | Result |
|------|-----|--------|--------|
| Feb 2 | Symbol purge (23 deactivated) | `242bb7d` | 111 symbols rotating |
| Feb 2 | Category-aware weights | `242bb7d` | 5 categories × 3 horizons |
| Feb 3 | **Coherence bug fix** | `0c8c74a` | Neutral 86.9% → 42.1% |
| Feb 5 | llm_raw_outputs fix | `b761433` | 4 rows/prediction populated |
| Feb 6 | **Claude Opus 4.6 deployed** | `db693ef` | Replaced Gemini, 57+ predictions confirmed |
| Feb 7 | GPT-5 API fix | `b6842ab` | 404 resolved |
| Feb 7 | V3 eval + confidence fix | `75749bd` | 1,498 V3 evaluated, dampening 0.4→0.7 |
| Feb 7 | **Consensus fix + weights** | `0ae9b86` | Threshold 0.15→0.08, Grok 40%, blend 60/40 |
| Feb 8 | **NO-GO verdict** | — | 36.0% accuracy, Cohen's h=0.059, negligible effect size |
| Feb 8 | **Smart Gate v1 implemented** | `8a8f366` | XGBoost meta-classifier, 80 tests, `feature/smart-gate` branch |
| Feb 8 | **Architecture doc validated** | — | 9.5+/10 all 10 dimensions, 4 LLMs (Claude, Gemini, GPT-5, DeepSeek) |
| Feb 8 | **Iron Dome plan created** | — | 35 tasks, 5 phases, multi-LLM validated (15/15 fixes, 4 validators PASS) |
| Feb 8 | **Phase 0 implemented** | `1b77408` | 18 files, 1910 insertions: compliance, eval harness, pocket mining, paper trade |
| Feb 8 | **Migrations 061+062 applied** | — | `compliance_audit_log` + `paper_trade_log` tables in production |
| Feb 8 | **Evaluation harness run** | — | AUC=0.73, Brier=0.13, ECE=0.09, n=2,864 |
| Feb 9 | **Phase 1 backend COMPLETE** | `25dcdbb` | Tasks 1.1-1.7 all implemented (302 tests passing) |
| Feb 9 | **Frontend UI updates** | `926a586` | Corrected LLM model count, weights, prediction display |
| Feb 9 | **Perplexity 60% failure fixed** | `ee4b831` | Switched sonar-reasoning-pro→sonar-pro, added retry+fallback |
| Feb 9 | **27 hydration errors fixed** | `d059e64` | suppressHydrationWarning on dynamic content across 27 components |
| Feb 9 | **6 remaining hydration errors** | `724d252` | ComparisonDrawer typeof window→mounted pattern, 0 errors in prod |
| Feb 9 | **7 stale screenshots cleaned** | `c7929ff` | Removed 850KB of validation PNGs |
| Feb 9 | **Frontend deployed** | — | sentimark-v2-frontend HTTP 200, 0 console errors verified |
| Feb 10 | **Task 0.6 GO/NO-GO #1** | — | CONDITIONAL NO-GO. WF-AUC=0.5976, TRADE acc 69.2% (n=13), paper trade +2.21% |
| Feb 10 | **EDGE_GATE_THRESHOLD=0.35 set** | — | Was missing (model used 0.83 default). TRADE rate 1.5%→8.0% |
| Feb 10 | **Backlog flushed** | — | 3,623 V2 predictions evaluated. 472 paper trades evaluated. |
| Feb 10 | **min_threshold fix** | `c27c031` | Lowered floor 0.40→0.25 in pocket_thresholds.py. Pipeline #10388. |
| Feb 10 | **Prevention Rules #19-#20** | — | min_threshold verification + post-deploy shadow check |
| Feb 10 | **XGBoost retrained** | — | WF-AUC 0.5976→0.7419 (n=4,286). TRADE precision 90.7%, coverage 11.1%. Eval harness AUC=0.8519. |
| Feb 10 | **Consensus tuned** | — | Mixed signals gate 0.50→0.65 + min 2 dissenters. V3 k_threshold 0.50→0.25. Forex neutral_band 0.15→0.10. |
| Feb 10 | **Confidence calibrator wired** | — | `calibrate_confidence_without_gate()` called in `_calculate_consensus()` with category param. Pocket base rates anchoring. |
| Feb 10 | **total_return_pct fixed** | — | 3 SQL queries in function_app.py now compute formula instead of reading stuck column. |
| Feb 10 | **Source health endpoint verified** | — | Endpoint returning HTTP 200 with valid JSON. |
| Feb 10 | **Train/serve skew fix** | `c3edc60` | gate_decision.py + asset_rotation.py imports fixed v1.0→v1.1 (25→27 features). Pipeline #10408. |
| Feb 10 | **GO/NO-GO #2** | — | NO-GO (Conditional). WF-AUC 0.6342 < 0.70. TRADE precision 89.1%. Need 24h+ post-fix data. |
| Feb 10 | **Prevention Rule #21** | — | gate_schema version matching between train and serve. |
| Feb 11 | **GO/NO-GO #3 DEFINITIVE NO-GO** | — | V3 key mismatch root cause found. 14 distinct probabilities. Simple rule beats ML. See `docs/GONOGO3_VERDICT.md`. |
| Feb 11 | **GOLDEN_PIECES.md created** | — | 5 golden pieces: GP1 (key fix), GP2 (rule gate), GP3 (retrain), GP4 (block stocks), GP5 (indices). |
| Feb 11 | **Prevention Rule #22** | — | After CONSENSUS_VERSION change, verify all downstream consumers read new breakdown keys. |
| Feb 12 | **GP1+GP2+GP4 deployed** | `485c03f` | V3 key mismatch fix + rule gate + stocks/commodities block. Pipeline #10430. |
| Feb 12 | **Post-deploy verification PASSED** | — | Features flowing: score_spread 0→0.33, distinct probs 6→35. Rule gate: forex TRADE (60), crypto-bearish TRADE (1). Old code rotated out 07:15 UTC. |
| Feb 12 | **6 portfolio bugs fixed** | `babdaef` | Stale prices (vpp.current_price), weekly history wiring, monitoring.py columns, leaderboard periods, total_return_pct, previous_regime. |
| Feb 12 | **Pipeline #10433 failed (504→400)** | — | Kudu zipdeploy isAsync=false timeout. Retry #10434 succeeded. Prevention Rule #23. |
| Feb 14 | **GP3 retrained** | `1cd4ade` | 11,045 rows, 27 features, WF-AUC 0.582, TRADE 57.6%, 216 distinct probs. Batch query 30min→8s. |
| Feb 14 | **GO/NO-GO #4: CONDITIONAL GO** | — | ML gate shadow, rule gate primary. Forex 69.0% (n=303). See `docs/GONOGO4_VERDICT.md`. |
| Feb 14 | **Frontend wiring** | `1cd4ade` | Accuracy page, portfolio real data, asset detail enrichment, nav updated. 17 files, +1002 lines. |
| Feb 14 | **Backend + frontend deployed** | — | Pipeline #10453 + deploy.sh. Both verified healthy. |
| Feb 14 | **1909 tests passing** | `1cd4ade` | Fixed DNT + crash sentinel schema imports (gate_schema→gate_schema_v1_1). |
| Feb 16 | **Weekend skip deployed** | `e5ec1fc` | Stocks/indices/commodities skip weekends. Pipeline #10466. |
| Feb 16 | **Grok calibration factor 0.7** | `e5ec1fc` | Bullish rate 25.8%→22.3% (-3.5pp). Target <22% (borderline). |
| Feb 16 | **Stocks bearish gate rule** | `e5ec1fc` | Pocket threshold 0.950 for stocks bearish. |
| Feb 16 | **GP5 indices conditional filter** | `918d8d9` | Bullish BLOCKED (10.3%), neutral TRADE (60.4%), bearish TRADE (46.7%). |
| Feb 16 | **Asymmetric bullish threshold** | `3537474` | Category-specific Grok weight reduction for consensus. |
| Feb 16 | **Diagrams migrated to D2** | `ebe53fd` | 4 D2 sources + SVG/PNG outputs in docs/diagrams/. |
| Feb 16 | **Portfolio visual validation** | — | All 3 portfolios validated (screenshots + DB cross-check). P2: intermittent position timeout. |
| Feb 22 | **Weekend skip VERIFIED** | — | Stocks/indices 0 on Sat. 3 WTI midnight leak (race condition, negligible). |
| Feb 22 | **Grok calibration 1-week eval** | — | Bullish 24.7% avg (target <22%). Partial improvement. Consider factor 0.6. |
| Feb 22 | **Post-deploy accuracy (6 days)** | — | Forex 60.5% (best, +4.9pp). Commodities 23.2% (worst, -15.1pp). n=4,127 evaluated. |

### Verification Queries (Updated Feb 12)
```sql
-- 1. Overall accuracy (Feb 8 result: 35.5%, n=2373)
SELECT COUNT(*) as total,
  SUM(CASE WHEN direction_correct THEN 1 ELSE 0 END) as correct,
  ROUND(100.0 * SUM(CASE WHEN direction_correct THEN 1 ELSE 0 END) / COUNT(*), 1) as accuracy_pct
FROM prediction_history
WHERE created_at > '2026-02-03 09:00:00' AND status = 'evaluated' AND model_version = 'v2';

-- 2. Accuracy by direction
SELECT direction, COUNT(*) as total,
  SUM(CASE WHEN direction_correct THEN 1 ELSE 0 END) as correct,
  ROUND(100.0 * SUM(CASE WHEN direction_correct THEN 1 ELSE 0 END) / COUNT(*), 1) as accuracy_pct
FROM prediction_history
WHERE created_at > '2026-02-03 09:00:00' AND status = 'evaluated' AND model_version = 'v2'
GROUP BY direction;

-- 3. Accuracy by category
SELECT ap.category, COUNT(*) as total,
  SUM(CASE WHEN ph.direction_correct THEN 1 ELSE 0 END) as correct,
  ROUND(100.0 * SUM(CASE WHEN ph.direction_correct THEN 1 ELSE 0 END) / COUNT(*), 1) as accuracy_pct
FROM prediction_history ph JOIN asset_profile ap ON ph.symbol = ap.symbol
WHERE ph.created_at > '2026-02-03 09:00:00' AND ph.status = 'evaluated' AND ph.model_version = 'v2'
GROUP BY ap.category ORDER BY 4 DESC;

-- 4. Daily neutral rate trend
SELECT DATE(created_at) as day, COUNT(*) as total,
  ROUND(100.0 * SUM(CASE WHEN direction = 'neutral' THEN 1 ELSE 0 END) / COUNT(*), 1) as neutral_pct
FROM prediction_history
WHERE created_at > '2026-02-03 09:00:00' AND model_version = 'v2'
GROUP BY 1 ORDER BY 1;
```

---

## Key Files

| Purpose | Location |
|---------|----------|
| Backend entry | `function_app.py` |
| LLM engine + consensus | `shared/rotation/llm_prediction.py` |
| Asset rotation + bandits | `shared/rotation/asset_rotation.py` |
| Context builder | `shared/rotation/context_builder.py` |
| Intelligence sources | `shared/intelligence/` |
| Claude client | `shared/llm_clients/claude_client.py` |
| External API clients | `shared/external/` |
| System truth | `docs/SYSTEM_TRUTH.md` |
| Edge Gate schema | `shared/ml/gate_schema.py` |
| Edge Gate features | `shared/ml/gate_features.py` |
| Edge Gate trainer | `shared/ml/gate_trainer.py` |
| Edge Gate decision | `shared/ml/gate_decision.py` |
| Edge Gate monitor | `shared/ml/gate_monitor.py` |
| Migrations | `migrations/` (latest: 062, gate_monitoring_log + compliance + paper_trade) |

---

## What Was Fixed (Jan 22, 2026)

| Issue | Root Cause | Fix |
|-------|------------|-----|
| Intelligence sources dead | Perplexity model deprecated | Changed to `sonar` |
| Timestamps not updating | Missing `is_fallback=False` | Added flag on API success |
| Silent UPDATE failures | Migration 033 not applied | Applied DB migration |
| Gemini not working | Model quota exhausted | Changed to `gemini-2.5-pro` |

---

## Prevention Rules

1. **Check docs/SYSTEM_TRUTH.md** - Single source of truth
2. **Verify source health endpoint** - Don't assume working
3. **Check `*_is_fallback` columns** - Real data vs fallback
4. **Run migrations** - Check all are applied
5. **NEVER bulk-delete from shared/** - One file per commit, verify pipeline + function count between each (Origin: 2026-02-01 outage)
6. **After any deploy, verify function count > 0** - `az functionapp function list -g AZAI_group -n func-sentimark-prod --query "length(@)"`
7. **Explore agent dead code detection is unreliable** - 87% false positive rate; never trust without manual __init__.py and dynamic import verification
8. **Frontend deploy is MANUAL — ALWAYS use deploy.sh** — No CI/CD pipeline. Run `sentimark-v2/frontend/deploy.sh` for all frontend deployments. NEVER use raw `curl` to Kudu zipdeploy API — apps with `WEBSITE_RUN_FROM_PACKAGE=1` require `az webapp deploy --type zip` (which deploy.sh uses). Manual curl causes 503. (Origin: 2026-02-03 outage — curl deploy returned 200 but app was down)
9. **DDL migrations require seekapaadmin** — App user `sentimark_app_user` lacks ALTER/CREATE permissions. Use Key Vault `PostgreSQL-AdminPassword`. Always GRANT SELECT on new views to app user after creation.
10. **Hex colors must use chart-colors.ts** — Custom ESLint rule `sentimark/no-hardcoded-colors` blocks builds with inline hex. Add colors to `lib/chart-colors.ts` and import.
11. **When removing a feature, grep for ALL references** — Removing a feature (e.g., coherence check) requires removing comment + code + result dict + log lines. Leaving stale references causes silent `NameError` caught by broad `except Exception`. (Origin: 2026-02-03 coherence bug — 2 weeks of dead predictions)
12. **Broad `except Exception` hides critical bugs** — The prediction try/except at `llm_prediction.py:962` silently swallowed `NameError` for weeks. Consider logging exception type or narrowing catch scope.
13. **After accuracy changes, verify prediction distribution** — Query `SELECT direction, COUNT(*) FROM prediction_history WHERE created_at > NOW() - INTERVAL '1 hour' GROUP BY 1` to confirm predictions aren't all neutral (>70% neutral = placeholder fallback).
14. **Azure Functions consumption plan: old instances persist 12+ hours** — Don't verify accuracy changes until T+24h minimum. At T+13h, 53% of predictions were still from pre-deploy code. This is platform behavior, not a bug.
15. **Weight dict keys must match LLM names** — When replacing an LLM (e.g., Gemini→Claude), update ALL weight dicts AND bandit_state_v2 rows. Key mismatch causes silent fallback to equal weights, spiking neutral rate. (Origin: Feb 6 — neutral rate jumped to 79.4% after Claude integration due to gemini keys in weight dicts)
16. **Search for existing deploy scripts before crafting commands** — `ls *deploy*.sh` and `grep -r 'az webapp deploy' *.sh` before ANY deployment. Existing scripts encode edge-case knowledge (WEBSITE_RUN_FROM_PACKAGE, async flags, zip structure) that ad-hoc commands miss. (Origin: 2026-02-03 — deploy.sh existed but was bypassed in favor of manual curl, causing 503)
17. **Next.js builds require 4GB heap** — Always use `NODE_OPTIONS='--max-old-space-size=4096'` before `npx next build`. Without it, builds fail with cryptic `ENOENT pages-manifest.json` (actually OOM). Also kill dev server before build — concurrent access corrupts `.next` cache. (Origin: 2026-02-09 — 3 build failures before discovering OOM)
18. **ML gate deployment checklist (MANDATORY)** — Before flipping any ML gate from shadow to live: (1) Verify `EDGE_GATE_THRESHOLD` env var is explicitly set (model internal default 0.83 ≠ intended 0.35), (2) Confirm 24h shadow data with correct threshold, (3) Run evaluation harness on fresh data, (4) Verify paper trade evaluator producing >0% evaluated, (5) Human GO/NO-GO approval. (Origin: 2026-02-09 — threshold env var missing caused model to use internal 0.83 instead of 0.35)
19. **Verify min_threshold floor <= base threshold** — After any `EDGE_GATE_THRESHOLD` change, confirm `pocket_thresholds.py` `min_threshold` doesn't clamp best pockets. Run `python3 -c "from shared.ml.pocket_thresholds import adjust_threshold; ..."` to verify per-pocket effective thresholds match intent. (Origin: 2026-02-10 — `min_threshold=0.40` negated `base=0.35` for forex_neutral, limiting TRADE rate to 8% instead of 35-45%)
20. **Post-deploy shadow mode verification (MANDATORY)** — After any pipeline deploy while Edge Gate is in shadow phase, verify `EDGE_GATE_SHADOW=true` via `az functionapp config appsettings list -g AZAI_group -n func-sentimark-prod --query "[?name=='EDGE_GATE_SHADOW']"`. (Origin: 2026-02-10 — gate was unintentionally LIVE for 6h on Feb 9, blocking 601 predictions without operator awareness)
21. **Verify gate_schema version matches between training and serving (MANDATORY)** — After any model retrain, confirm `gate_decision.py` and `asset_rotation.py` both import from the same schema version as `train_gate_v1.py`. Run `grep -n 'gate_schema' shared/ml/gate_decision.py shared/rotation/asset_rotation.py scripts/train_gate_v1.py` to verify all three reference the same module. Mismatch causes silent PASS_THROUGH on every prediction (feature shape mismatch). (Origin: 2026-02-10 — model trained on v1.1 (27 features) but serving used v1.0 (25 features), 585 decisions were PASS_THROUGH for ~5h)
22. **After CONSENSUS_VERSION change, verify all breakdown consumers (MANDATORY)** — When changing `CONSENSUS_VERSION` (v2→v3 or vice versa), search ALL code that reads from `llm_breakdown` dicts: `grep -rn "d.get('score'" shared/ *.py` and `grep -rn "d.get('confidence'" shared/ *.py`. V2 uses `'score'`/`'confidence'` keys, V3 uses `'p_up'`/`'raw_confidence'`. Add fallbacks: `d.get('score', d.get('p_up', 0.0))`. (Origin: 2026-02-11 — `CONSENSUS_VERSION=v3` in production but gate read `'score'`/`'confidence'` keys → all LLM features defaulted to 0.0/0.5, collapsing model to 14 distinct probability values for months)
23. **Kudu zipdeploy 504 = server still building, NOT a clean failure (MANDATORY)** — When `azure-pipelines.yml` Kudu deploy returns HTTP 504, the server-side Oryx build is likely **still running**. Do NOT retry within 30s — the next attempt will get 400/409 (deployment slot locked). Wait at least **5 minutes** before retrying, or switch to `isAsync=true` + polling. The pipeline's retry logic treats 400 as non-retryable, causing premature failure after only 2 of 4 attempts. Root cause: `isAsync=false` (line 289) makes curl wait synchronously, but Azure Front Door gateway times out at ~240s for large apps (18K LOC). (Origin: 2026-02-12 — Pipeline #10433 failed with 504→400 sequence. Retry #10434 succeeded 15 min later after lingering deploy finished.)
24. **After adding a backend API endpoint, verify at least one frontend consumer calls it (MANDATORY)** — Search frontend for the endpoint URL or client function name: `grep -rn "endpointName\|/api/path" sentimark-v2/frontend/`. Zero matches = half-wired feature that will never be visible to users. Also check that TypeScript types are imported, not just defined. (Origin: 2026-02-12 — `getWeeklyPortfolioHistory()` existed in v2-client.ts for months with types defined but no component ever called it)
25. **API read queries must use the same table the background writer updates (MANDATORY)** — When a stored function/timer updates a table (e.g., `virtual_portfolio_positions.current_price`), the API endpoint serving that data MUST read from the same table, not a different one (e.g., `asset_profile.current_price`). Verify: `grep -n 'current_price' function_app.py` and confirm all JOINs reference the writer's target table. Different update cadences between tables cause stale data even when the writer is correct. (Origin: 2026-02-12 — `update_virtual_portfolio_values()` wrote to `vpp.current_price` every 5 min, but detail endpoint read from `asset_profile.current_price` with different update timing)
26. **After applying an inline SQL formula fix to any endpoint, grep ALL endpoints for the old pattern (MANDATORY)** — Run `grep -n 'column_name' function_app.py | wc -l` to find every read site. If the fix replaces a column read with a computed expression (e.g., `total_return_pct` column → `((current_value/NULLIF(starting_value,0))-1)*100`), apply it to ALL matching endpoints, not just the ones you noticed. (Origin: 2026-02-12 — `total_return_pct` inline fix applied to 4 endpoints but missed the main listing and daily history endpoints)
27. **Sentimark API returns percentages (0-100), NOT decimals (0-1) (MANDATORY)** — When consuming accuracy/percentage endpoints, NEVER multiply by 100. The API already returns percentage values (e.g., `overall: 34.4` means 34.4%). (Origin: 2026-02-16 — 100x multiplier applied to already-percentage values caused impossible >1000% display)

---

## Repository

**Azure DevOps**: https://dev.azure.com/Corp-domain/Corp-AI/_git/sentimark

```bash
git push azure <branch>
```

---

### Consensus Algorithm Parameters (Current)

| Parameter | Value | Changed | Old Value |
|-----------|-------|---------|-----------|
| `base_threshold` | 0.08 | Feb 7 | 0.15 |
| `threshold_floor` | 0.05 | Feb 7 | 0.10 |
| Contrarian override | **DISABLED** | Feb 7 | Active (bullish→neutral) |
| Mixed signals gate | 0.50 | Feb 7 | 0.35 |
| Static/dynamic blend | 60/40 | Feb 7 | 70/30 |
| Grok weight (24h) | 40% | Feb 7 | 20-35% |
| Claude weight | 25% | Feb 7 | N/A (was Gemini 24.4%) |
| GPT-5 weight (24h) | 20% | Feb 7 | 25.6% |
| Perplexity weight | 15% | Feb 7 | 30% |

### Edge Gate Feature Flags (Smart Gate v1)

| Flag | Default | Purpose |
|------|---------|---------|
| `ENABLE_EDGE_GATE` | `false` | Enable gate decision engine |
| `EDGE_GATE_SHADOW` | `true` | Log decisions without blocking (shadow mode) |
| `EDGE_GATE_MODEL_PATH` | — | Path to trained XGBoost model file |
| `GROK_CALIBRATION_FACTOR` | `0.6` | Dampens Grok bullish bias — global default (Feb 23) |
| `GROK_CALIBRATION_FACTOR_COMMODITIES` | `1.0` | No dampening for commodities (Feb 23) |
| `GROK_CALIBRATION_FACTOR_FOREX` | `1.0` | No dampening for forex (Feb 23) |
| `ENABLE_STOCKS_BEARISH_TRADE` | `true` | Stocks bearish pocket gate rule (Feb 16) |

### Key Findings (Feb 6-8)

1. **Consensus destroys value**: Grok alone 53.3% → ensemble 35.5%. Weighted average + threshold produces too many neutrals.
2. **Neutral predictions are worst**: Wrong 64.2% of time, but ensemble produces 67-72% neutral.
3. **Claude integration caused neutral spike**: Weight mismatch (gemini keys vs claude LLM) → 79.4% neutral on Feb 6.
4. **Perplexity unreliable**: 60% failure rate (44 outputs vs 111 for others). Drags down signal quality.
5. **Azure consumption plan warm instances**: Old code persists 12+ hours after deploy. 53% still on old code 13h post-deploy.
6. **Per-LLM raw accuracy misleading**: sentiment_score in DB doesn't cleanly map to direction — near 0% for all LLMs.
7. **Forex is best category**: 54.7% accuracy vs 30% for others. Category-specific strategies may help.

---

## Session History

See `docs/SYSTEM_TRUTH.md` for latest verified state.
Last verification: February 22, 2026 10:00 UTC (weekend skip verified, Grok calibration 1-week eval)
Last deploy: February 16, 2026 04:35 UTC (pipeline #10466 — weekend skip + Grok calibration + stocks bearish gate)
Previous deploy: February 14, 2026 20:42 UTC (pipeline #10453 backend + deploy.sh frontend)
Claude Opus 4.6 active: February 6, 2026
V3 consensus shadow mode active: February 1, 2026
P0/P1/P2 Recovery completed: January 22, 2026
