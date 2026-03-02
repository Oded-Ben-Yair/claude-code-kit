# Handover: Real-Time Sales Call Monitor
**Session**: `real-time-session-20260211-elevenlabs-fix`
**Date**: 2026-02-11
**Branch**: `main` (27 uncommitted files)
**Health**: 80/100 (Good — transcription works, translation broken)

---

## Goals & Results

| # | Goal | Status | Notes |
|---|------|--------|-------|
| 1 | Fix zero transcription in production | COMPLETE | Root cause: 3 missing required fields in ElevenLabs message |
| 2 | Fix deploy zip structure | COMPLETE | startup.sh + requirements.txt must be at zip root |
| 3 | Fix Arabic→Hebrew translation | NOT STARTED | Both AI models failing — P0 for next session |

---

## P0: FIX ARABIC→HEBREW TRANSLATION

### What's Broken
Arabic transcription works perfectly. But the translated Hebrew text never appears — Arabic text passes through untranslated.

### Production Log Evidence
```
{"model": "gemini-2.5-flash", "latency_ms": 636.3, "exc_info": true, "event": "translation_model_failed"}
{"model": "gpt-5.2", "latency_ms": 3.4, "exc_info": true, "event": "translation_model_failed"}
{"cooldown_seconds": 30.0, "event": "translation_circuit_breaker_activated"}
```
Both models fail → circuit breaker activates for 30s → all subsequent translations skipped.

### Where to Look

**File**: `backend/app/services/translation.py`
- Line 67-75: `_get_client()` — creates `AsyncOpenAI(base_url=settings.azure_ai_endpoint, api_key=settings.azure_ai_api_key)`
- Line 181-209: `_call_model()` — makes the actual API call. `except Exception` catches everything, logs as `translation_model_failed`

**File**: `backend/app/config.py`
- Line 22-23: `azure_ai_endpoint` and `azure_ai_api_key` — both `str | None`, read from env vars `AZURE_AI_ENDPOINT` and `AZURE_AI_API_KEY`

### Likely Root Causes (CHECK IN ORDER)
1. **Missing env vars**: `AZURE_AI_ENDPOINT` and `AZURE_AI_API_KEY` may not be set on the Azure App Service. Check:
   ```bash
   az webapp config appsettings list -n app-realtime-monitor -g AZAI_group --query "[?name=='AZURE_AI_ENDPOINT' || name=='AZURE_AI_API_KEY']"
   ```
2. **Wrong endpoint URL**: The endpoint must be an Azure AI Foundry (OpenAI-compatible) base URL like `https://<name>.openai.azure.com/v1` or the AI Foundry inference endpoint
3. **Wrong model names**: Azure AI Foundry deployment names may differ from `gemini-2.5-flash` / `gpt-5.2`. Check what deployments exist:
   ```bash
   az keyvault secret show --vault-name kv-seekapa-apps --name AzureAIFoundry-Endpoint
   az keyvault secret show --vault-name kv-seekapa-apps --name AzureAIFoundry-ApiKey
   ```
4. **Model not deployed in Azure AI Foundry**: The specific models may not exist. You can use ANY model available in Azure AI Foundry — just update `_PRIMARY_MODEL` and `_FALLBACK_MODEL` in `translation.py:36-38`

### How to Fix
1. Pull the actual exception from production logs (the `exc_info=True` should have stack traces):
   ```bash
   az webapp log download -n app-realtime-monitor -g AZAI_group --log-file /tmp/realtime-logs.zip
   ```
2. If env vars are missing, set them from Key Vault:
   ```bash
   ENDPOINT=$(az keyvault secret show --vault-name kv-seekapa-apps --name AzureAIFoundry-Endpoint --query value -o tsv)
   APIKEY=$(az keyvault secret show --vault-name kv-seekapa-apps --name AzureAIFoundry-ApiKey --query value -o tsv)
   az webapp config appsettings set -n app-realtime-monitor -g AZAI_group --settings AZURE_AI_ENDPOINT="$ENDPOINT" AZURE_AI_API_KEY="$APIKEY"
   ```
3. If model names are wrong, check available deployments and update `translation.py:36-38`
4. **Alternative**: Use the `azure-ai-foundry` MCP server to list available models:
   ```
   mcp__azure-ai-foundry__list_models
   ```
5. After fixing, redeploy and have user test with live Arabic audio

### DO NOT
- Skip user testing — "deploy succeeded" does not mean "translation works"
- Move to Part 2 (AI evaluator, persistence, speaker separation) until translation is confirmed working by the user
- Rewrite translation.py architecture — just fix the model endpoint/key connection

---

## Technical State

### What's Working
- Browser AudioWorklet captures mic audio (48kHz → 16kHz PCM, Float32→Int16)
- Frontend → Backend WebSocket streaming (3200-byte chunks every 100ms)
- Backend → ElevenLabs Scribe v2 Realtime WebSocket (Arabic transcription)
- ElevenLabs returns partial + committed transcripts
- Event bus: `transcript.committed` → translation service (but translation FAILS)
- Frontend displays Arabic text in real-time (RTL, Hebrew UI)

### What's Broken
- Translation service: `AsyncOpenAI` client fails on both `gemini-2.5-flash` and `gpt-5.2`
- Circuit breaker blocks all translation for 30s after both fail
- Frontend shows Arabic text instead of Hebrew translation

### Tests
- **158 tests passing** (all green)
- Translation tests use mocks — they pass but don't catch real API connection issues

### Deployment
- Backend: `https://app-realtime-monitor.azurewebsites.net` — healthy, deployed via `az webapp deploy`
- Frontend: `https://brave-bay-048da2703.2.azurestaticapps.net` — deployed via Azure Static Web Apps
- Deploy zip: built with `startup.sh` + `requirements.txt` at root, `backend/` nested

### Git State
- Branch: `main`
- 27 uncommitted files (19 modified + 5 new + 3 untracked)
- Should commit after translation is fixed

---

## Key Files

| File | Purpose | Lines to Know |
|------|---------|---------------|
| `backend/app/services/elevenlabs.py` | ElevenLabs WebSocket client | :111-128 send_audio, :93-101 disconnect commit |
| `backend/app/services/translation.py` | Arabic→Hebrew translation | :67-75 client init, :181-209 API call, :36-38 model names |
| `backend/app/config.py` | Env var config | :22-23 azure_ai_endpoint, azure_ai_api_key |
| `backend/app/services/event_bus.py` | Pub/sub for transcript events | Wires everything together |
| `backend/tests/test_elevenlabs.py` | ElevenLabs tests | All updated for new message format |
| `.claude/status.json` | Project state | Updated with current state |

---

## Critical Decisions (This Session)

1. **ElevenLabs Scribe v2 Realtime message format** — audio chunks MUST include `message_type`, `commit`, `sample_rate` alongside `audio_base_64`. Batch API has different field names. IRREVERSIBLE.
2. **Deploy zip root-level structure** — startup.sh and requirements.txt at zip root for Oryx build. IRREVERSIBLE.
3. **Translation safe templating** — Uses `%%PLACEHOLDER%%` + `.replace()`, never Python `.format()` on user text containing Arabic/Hebrew. ESTABLISHED PATTERN.

---

## Production URLs

| Service | URL |
|---------|-----|
| Backend | https://app-realtime-monitor.azurewebsites.net |
| Frontend | https://brave-bay-048da2703.2.azurestaticapps.net |
| Health | https://app-realtime-monitor.azurewebsites.net/health |

---

## Blockers

| ID | Blocker | Severity | Workaround |
|----|---------|----------|------------|
| translation-models | Both AI models (gemini-2.5-flash, gpt-5.2) fail | P0 | Fix env vars or model names |
| pipeline-rbac | Pipeline deploy needs Contributor role for mi-marketing-newsletter-devops | CI/CD | Manual `az webapp deploy` |
| legal-compliance | Legal prerequisites (Architecture Section 2) | Blocking production | Does not block implementation |

---

## Next Steps (Priority Order)

| # | Priority | Task |
|---|----------|------|
| 1 | P0 | **Fix translation** — debug why both models fail, fix env vars/endpoint/model names |
| 2 | P0 | Have user verify Hebrew translation appears in frontend |
| 3 | P1 | Git commit all 27 uncommitted files |
| 4 | P2 | Begin Part 2: AI evaluator, persistence, speaker separation |
| 5 | P3 | Get pipeline RBAC fixed (sysadmin sister) |

---

## Session Learnings

### What Worked
- Team-based hostile audit (api-researcher + code-auditor) found root cause in 10 min
- Production Docker logs revealed all issues — better than re-reading code
- Official API docs (4 sources) cross-validated confirmed exact message format

### What Failed
- Trusted LLM training data for ElevenLabs message format — was wrong
- Claimed "deployed successfully" without user testing production
- Nested startup.sh/requirements.txt in backend/ — Oryx silently ignores them

### Patterns Established
- `anti-026`: Never trust training data for third-party API formats
- `anti-027`: Azure deploy zip must have config files at root
- `anti-028`: "Deploy succeeded" != "Bug fixed" — always user-test
- `pattern-034`: Team audit for API protocol debugging
- `pattern-035`: Azure Oryx deploy zip structure
- `pattern-036`: Production logs before code re-read
