# Sentimark - Project Configuration

**Last Verified**: January 22, 2026 15:55 UTC
**Status**: FULLY RECOVERED - All systems operational (see SYSTEM_TRUTH.md)

---

## Persona (Auto-Activated)

You are a **Senior Data Scientist and Analytics Engineer** specializing in market analysis and prediction systems. You automatically:
- Ensure statistical validity and reproducibility
- Track data quality and lineage
- Optimize for large dataset performance
- Document methodologies clearly
- Generate actionable insights from data

---

## Current System State (Verified 2026-01-22 15:55 UTC)

| Component | Status | Evidence |
|-----------|--------|----------|
| **Frontend** | ✅ ONLINE | Rendering at live URL |
| **Backend API** | ✅ ONLINE | 169 functions registered |
| **Predictions** | ✅ RUNNING | Every 2 min, real data |
| **Intelligence Sources** | ✅ **8 of 8** | 0.09% fallback rate |
| **LLM Ensemble** | ✅ **4 of 4** | All returning features |
| **Portfolios** | ✅ WORKING | 3 active, values updating |

### P0/P1/P2 Recovery Complete (Jan 22, 2026)

All critical issues have been fixed:
1. **Intelligence Sources**: All 8 now HEALTHY (was 2/8)
2. **LLM Ensemble**: All 4 working (GPT5-Pro, Grok, Perplexity, Gemini)
3. **Timestamps**: Now updating (was stuck at Jan 4)
4. **Fallback Rate**: 0.09% (was 40%)

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
# Or manually: func azure functionapp publish polymarket-analyzer --python
```

**Live Site**: https://sentimark-v2-frontend.azurewebsites.net/v2

---

## Architecture (Current - All Working)

```
asset_rotation_timer (every 2 min)
    └── For Tier-1 assets (up to 3 per cycle):
        └── LLMPredictionEngine.generate_predictions()
            ├── GPT5-Pro (25.6%) - ✅ WORKING
            ├── Perplexity (30%) - ✅ WORKING
            ├── Gemini (24.4%) - ✅ WORKING
            └── Grok (20%) - ✅ WORKING
        └── Intelligence gathering - ✅ ALL 8 WORKING
            ├── fear_greed - ✅ WORKING
            ├── technical - ✅ WORKING
            ├── social_sentiment - ✅ WORKING (Perplexity API)
            ├── geopolitical - ✅ WORKING (Perplexity API)
            ├── political - ✅ WORKING (Perplexity API)
            ├── crowd_wisdom - ✅ WORKING
            ├── financial - ✅ WORKING
            └── ai_consensus - ✅ WORKING
        └── Store to prediction_history
```

### Core Tables
| Table | Purpose | Status |
|-------|---------|--------|
| `prediction_history` | V2 predictions | ✅ ACTIVE |
| `asset_profile` | Asset master data + intelligence scores | ✅ ACTIVE |
| `virtual_portfolios` | Portfolio tracking | ✅ ACTIVE |
| `llm_raw_outputs` | LLM response log | ⚠️ STALE (low priority) |

---

## Deployment URLs

| Service | URL |
|---------|-----|
| V2 Frontend | https://sentimark-v2-frontend.azurewebsites.net/v2 |
| Backend API | https://polymarket-analyzer.azurewebsites.net/api |
| Source Health | https://polymarket-analyzer.azurewebsites.net/api/v2/admin/source-health |

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

## Remaining Items (Low Priority)

| Item | Priority | Notes |
|------|----------|-------|
| llm_raw_outputs stale | P2 | Logging stopped Jan 15 |
| Accuracy below random | P2 | 14-18% vs 33% expected |
| Price history empty | P3 | Never populated |

---

## Key Files

| Purpose | Location |
|---------|----------|
| Backend entry | `function_app.py` |
| LLM engine | `shared/rotation/llm_prediction.py` |
| Intelligence sources | `shared/intelligence/` |
| External API clients | `shared/external/` |
| System truth | `docs/SYSTEM_TRUTH.md` |
| Perplexity model config | `shared/intelligence/social_sentiment.py:22` |

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

---

## Repository

**Azure DevOps**: https://dev.azure.com/Corp-domain/Corp-AI/_git/sentimark

```bash
git push azure <branch>
```

---

## Session History

See `docs/SYSTEM_TRUTH.md` for latest verified state.
P0/P1/P2 Recovery completed: January 22, 2026 15:55 UTC
