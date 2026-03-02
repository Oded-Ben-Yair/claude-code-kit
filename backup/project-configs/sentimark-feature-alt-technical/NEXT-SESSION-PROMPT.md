# Sentimark - Next Session Optimal Prompt

**Created**: 2026-01-26 16:30 UTC
**Session**: #668 Learning Loop Output

---

## Copy This Prompt to Start Next Session

```
## Context

Sentimark market intelligence platform. Session #668 completed P0 fixes.

### Current State (verified 2026-01-26)
- **145 assets** in database
- **145/145 return HTTP 200** (no 404s)
- **125/145 have fresh data** (< 1 hour)
- **59/145 have predictions** (only 41%)
- **86 assets have NO predictions in 24h**

### Root Cause
The `asset_rotation` timer is tiered:
- Tier-1 (flagship): Every 2 min, up to 3 assets per cycle
- Tier-2/3: Less frequent or on-demand
- 86 assets are in lower tiers and rarely get predictions

### Problem to Solve
All 145 assets should have:
1. Fresh intelligence data (< 1 hour old)
2. Predictions generated regularly (at least daily)
3. Auto-updating without manual intervention

---

## Task: Fix Asset Data Coverage

### Goals
1. **100% prediction coverage**: All 145 assets should have predictions within 24h
2. **Fresh data for all**: All assets updated at least hourly
3. **Sustainable**: Timer handles load without overwhelming LLM APIs

### Investigation Needed
1. Read `shared/rotation/asset_rotation.py` - understand tier logic
2. Read `shared/rotation/llm_prediction.py` - understand prediction generation
3. Check `asset_registry` table for `priority`, `is_flagship`, `tier` columns
4. Identify bottleneck: Is it tier filtering? Rate limiting? API costs?

### Potential Solutions
1. **Adjust tier assignments**: Move more assets to Tier-1/2
2. **Increase batch size**: Process more than 3 assets per cycle
3. **Add catch-up logic**: Process assets with stale data first
4. **Separate timers**: Different timers for intelligence vs predictions
5. **Priority queue**: Newly added assets get processed first

### Verification
After changes:
```sql
-- All assets should have recent predictions
SELECT COUNT(*) as total,
       COUNT(CASE WHEN latest_pred > NOW() - INTERVAL '24 hours' THEN 1 END) as has_recent
FROM (
    SELECT symbol, MAX(created_at) as latest_pred
    FROM prediction_history
    GROUP BY symbol
) sub;
-- Target: total = has_recent = 145

-- All assets should have fresh intelligence
SELECT COUNT(*) as total,
       COUNT(CASE WHEN updated_at > NOW() - INTERVAL '1 hour' THEN 1 END) as fresh
FROM asset_profile;
-- Target: total = fresh = 145
```

---

## Key Files to Read First
1. `shared/rotation/asset_rotation.py` - Timer logic
2. `shared/rotation/llm_prediction.py` - Prediction generation
3. `shared/rotation/intelligence_rotation.py` - Intelligence gathering
4. `function_app.py` - Timer trigger configuration

## Database Connection
```
Host: postgres-seekapatraining-prod.postgres.database.azure.com
DB: polymarket_analyzer
User: sentimark_app_user
```

## Don't Forget
- Use PR → Pipeline for deployment (never direct `func publish`)
- Verify with database queries, not just API responses
- GME (74% health) proves the system works when asset is processed
```

---

## Quick Copy (Minimal Version)

```
Sentimark: 86/145 assets have NO predictions. Root cause: asset_rotation timer only processes Tier-1 (3 assets/2min). Fix so all 145 assets get predictions within 24h and fresh intelligence data hourly. Start by reading shared/rotation/asset_rotation.py to understand tier logic.
```

---

## Memory MCP Entities

Search for these to get full context:
- `sentimark-session-20260126-668` - This session summary
- `sentimark-architecture-prediction-tier` - Tier architecture
- `sentimark-next-session-priority` - Priority list
