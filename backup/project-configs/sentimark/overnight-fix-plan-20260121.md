# Sentimark Overnight TDD-Loop Fix Plan

**Created**: January 21, 2026 18:40 UTC
**Status**: READY FOR EXECUTION
**Priority**: P0 - Critical System Recovery

---

## Executive Summary

The system has been degraded since Jan 4, 2026. Root cause: removal of mock fallbacks exposed broken API configurations. This plan fixes all issues using TDD methodology.

## Root Cause Analysis

### Timeline
1. **Before Jan 4**: Mock data provided fake values, system appeared working
2. **Jan 5 (d81905f)**: "Removed mock social sentiment fallback" - mock data removed
3. **Jan 5+**: Real APIs failed silently, returning fallback value=50 for 6/8 sources
4. **Jan 15**: llm_raw_outputs stopped logging (separate issue)

### API Test Results (Verified Jan 21, 2026)

| API | Status | Root Cause |
|-----|--------|------------|
| Perplexity | KEY VALID | **Model name outdated**: `llama-3.1-sonar-small-128k-online` → `sonar-pro` |
| LunarCrush | KEY VALID | API works, code may not call it properly |
| Fear & Greed | WORKING | No issues |
| Polymarket | WORKING | Returns data (needs better keyword matching) |
| Grok | MISCONFIGURED | Code reads `AZURE_OPENAI_KEY`, Azure has `GROK_API_KEY` |
| Gemini | KEY VAULT REF | `@Microsoft.KeyVault(...)` may not resolve in Azure Functions |

---

## Fix Phases

### Phase 1: Perplexity Model Fix (15 min)
**Impact**: Fixes social_sentiment, geopolitical, political sources

#### Files to Update
```
shared/intelligence/social_sentiment.py:90
shared/intelligence/geopolitical.py:115
shared/intelligence/political.py:125
```

#### Change
```python
# FROM:
"model": "llama-3.1-sonar-small-128k-online"

# TO:
"model": "sonar-pro"
```

#### TDD Tests
```bash
# Unit test: Mock Perplexity API response
pytest tests/unit/test_intelligence_sources.py -k "social_sentiment or geopolitical or political"

# Integration test: Call real API
PERPLEXITY_API_KEY=xxx pytest tests/integration/test_perplexity.py -v
```

#### Verification Query
```sql
-- After deployment, within 10 minutes:
SELECT symbol,
       external_sources->'social_sentiment'->>'value' as social,
       external_sources->'social_sentiment'->>'is_fallback' as fallback
FROM asset_profile
WHERE tier = 1
LIMIT 5;
-- Expected: is_fallback = false, value != 50
```

---

### Phase 2: Grok Env Var Fix (5 min)
**Impact**: Fixes Grok LLM returning "Analysis failed"

#### Option A: Update Azure env var (Recommended)
```bash
az functionapp config appsettings set \
  --name polymarket-analyzer \
  --resource-group AZAI_group \
  --settings "AZURE_OPENAI_KEY=REDACTED_AZURE_KEY"
```

#### Option B: Update code to read correct env var
```python
# In shared/llm_clients/grok_client.py line 33:
# FROM:
self.api_key = os.getenv("AZURE_OPENAI_KEY") or os.getenv("AZURE_AI_FOUNDRY_KEY")

# TO:
self.api_key = os.getenv("GROK_API_KEY") or os.getenv("AZURE_OPENAI_KEY") or os.getenv("AZURE_AI_FOUNDRY_KEY")
```

#### TDD Tests
```bash
# Unit test
pytest tests/unit/test_grok_client.py -v

# Integration test
GROK_API_KEY=xxx pytest tests/integration/test_llm_grok.py -v
```

#### Verification Query
```sql
-- Check Grok responses in predictions
SELECT symbol,
       llm_features->'grok'->>'score' as grok_score,
       llm_features->'grok'->>'reasoning' as grok_reasoning
FROM prediction_history
WHERE created_at > NOW() - INTERVAL '1 hour'
ORDER BY created_at DESC
LIMIT 5;
-- Expected: reasoning != "Analysis failed"
```

---

### Phase 3: Gemini Key Vault Fix (10 min)
**Impact**: Activates Gemini LLM (24.4% weight)

#### Issue
Key Vault reference may not resolve in Azure Functions runtime:
```
GEMINI_API_KEY=@Microsoft.KeyVault(VaultName=kv-seekapa-apps;SecretName=MarketingNewsletter-GeminiApiKey)
```

#### Solution: Fetch from Key Vault and set directly
```bash
# Get the actual key
GEMINI_KEY=$(az keyvault secret show \
  --vault-name kv-seekapa-apps \
  --name MarketingNewsletter-GeminiApiKey \
  --query value -o tsv)

# Set directly (not as Key Vault reference)
az functionapp config appsettings set \
  --name polymarket-analyzer \
  --resource-group AZAI_group \
  --settings "GEMINI_API_KEY=$GEMINI_KEY"
```

#### Verification
```bash
# Test Gemini API
curl -s "https://generativelanguage.googleapis.com/v1beta/models?key=$GEMINI_KEY" | head -c 200
```

---

### Phase 4: LunarCrush Integration (20 min)
**Impact**: Activates lunarcrush source

#### Current State
- API key valid (tested)
- Likely not being called from asset_rotation.py

#### Debug Steps
1. Add logging to trace the call chain
2. Verify `get_crypto_social_metrics()` is called for crypto assets
3. Check if staleness rules are preventing updates

#### Code Location
```python
# shared/rotation/asset_rotation.py:467-470
elif source == 'lunarcrush':
    result = await _fetch_lunarcrush(symbol)
    ...
```

#### TDD Tests
```bash
# Integration test with real API
LUNARCRUSH_API_KEY=xxx pytest tests/integration/test_lunarcrush.py -v
```

---

### Phase 5: Crowd Wisdom Fix (15 min)
**Impact**: Better Polymarket matching for crypto

#### Issue
Polymarket API returns data but keyword matching finds 0 crypto markets.

#### Fix
Update `CRYPTO_MARKET_KEYWORDS` in `shared/intelligence/crowd_wisdom.py`:
```python
CRYPTO_MARKET_KEYWORDS = {
    "BTC": ["bitcoin", "btc", "crypto", "cryptocurrency"],
    "ETH": ["ethereum", "eth", "crypto"],
    # Add more specific keywords based on actual Polymarket questions
}
```

---

### Phase 6: Deploy & Verify (15 min)

#### Deploy Backend
```bash
cd ~/projects/sentimark
func azure functionapp publish polymarket-analyzer --python
```

#### Full System Verification
```sql
-- 1. Predictions still generating
SELECT COUNT(*), AVG(llm_disagreement)
FROM prediction_history
WHERE created_at > NOW() - INTERVAL '1 hour';

-- 2. Intelligence sources no longer fallback
SELECT symbol,
       COUNT(*) FILTER (WHERE (external_sources->'lunarcrush'->>'is_fallback')::boolean = false) as lunarcrush_real,
       COUNT(*) FILTER (WHERE (external_sources->'social_sentiment'->>'is_fallback')::boolean = false) as social_real,
       COUNT(*) FILTER (WHERE (external_sources->'geopolitical'->>'is_fallback')::boolean = false) as geo_real
FROM asset_profile
WHERE tier = 1
GROUP BY symbol;

-- 3. LLMs contributing features
SELECT
    (llm_features->'gpt5_pro'->>'score') IS NOT NULL as gpt5_active,
    (llm_features->'grok'->>'score') IS NOT NULL as grok_active,
    (llm_features->'perplexity'->>'score') IS NOT NULL as perplexity_active,
    (llm_features->'gemini'->>'score') IS NOT NULL as gemini_active
FROM prediction_history
WHERE created_at > NOW() - INTERVAL '30 minutes'
LIMIT 1;
```

---

## TDD Loop Automation Script

Create `scripts/tdd-fix-loop.sh`:
```bash
#!/bin/bash
# TDD-Loop Fix Script for Sentimark P0 Recovery
# Run with: ./scripts/tdd-fix-loop.sh

set -e

echo "=== Phase 1: Perplexity Model Fix ==="
# Apply fix
sed -i 's/llama-3.1-sonar-small-128k-online/sonar-pro/g' \
    shared/intelligence/social_sentiment.py \
    shared/intelligence/geopolitical.py \
    shared/intelligence/political.py

# Run tests
pytest tests/unit/test_intelligence_sources.py -v --tb=short

echo "=== Phase 2: Grok Env Var Fix ==="
# Apply code fix
sed -i 's/os.getenv("AZURE_OPENAI_KEY")/os.getenv("GROK_API_KEY") or os.getenv("AZURE_OPENAI_KEY")/' \
    shared/llm_clients/grok_client.py

# Run tests
pytest tests/unit/test_grok_client.py -v --tb=short

echo "=== Phase 3: Deploy ==="
func azure functionapp publish polymarket-analyzer --python

echo "=== Phase 4: Verify ==="
sleep 120  # Wait for 2 rotation cycles

# Check database
psql "$DATABASE_URL" -c "
SELECT COUNT(*), AVG(llm_disagreement)
FROM prediction_history
WHERE created_at > NOW() - INTERVAL '5 minutes';
"

echo "=== Done! Check SYSTEM_TRUTH.md for updated status ==="
```

---

## Success Criteria

After all fixes deployed, verify:

- [ ] Predictions: 60+ per hour (up from 45-72)
- [ ] LLM Disagreement: > 0.15 (indicates multiple LLMs contributing)
- [ ] Intelligence sources: 6+ returning real data (not fallback)
- [ ] No "Analysis failed" in Grok responses
- [ ] Gemini features appearing in predictions

---

## Rollback Plan

If issues occur after deployment:
```bash
# Revert to previous deployment
func azure functionapp deployment source sync \
  --name polymarket-analyzer \
  --resource-group AZAI_group

# Or git revert
git revert HEAD
git push azure master
```

---

## Post-Fix Documentation

After successful fix, update:
1. `docs/SYSTEM_TRUTH.md` - Change status to OPERATIONAL
2. `CLAUDE.md` - Update component status table
3. Memory MCP - Create entity `sentimark-recovery-20260121`

---

**Estimated Total Time**: 60-90 minutes
**Risk Level**: Medium (changes are isolated, have rollback)
**Recommended**: Run during low-traffic period (overnight UTC)
