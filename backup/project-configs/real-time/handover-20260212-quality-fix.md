# Session Handover: Quality Fix — Duplication + VAD + Fragments
**Date**: 2026-02-12 | **Session ID**: real-time-session-20260212-quality-fix | **Health**: 95/100

## What Was Done

Implemented Steps 1-5 of the quality fix plan. User reported "everything is duplicated and Hebrew doesn't make sense." Three root causes identified and fixed:

### 1. 2x Duplication (P0)
- **Root cause**: `elevenlabs.py:198` processed BOTH `committed_transcript` AND `committed_transcript_with_timestamps` for every utterance
- **Fix**: Process only `committed_transcript_with_timestamps` (has word-level timing), skip the other
- **Safety net**: Text-based dedup — track last texts in 5s sliding window
- **Evidence**: 44 with-timestamps + 59 without-timestamps = 103 total events. Now only 44 processed.

### 2. Fragmented Segments
- **Root cause**: VAD `silence_threshold_secs=0.8` too aggressive for Arabic (natural pauses mid-sentence)
- **Fix**: 0.8→1.5s (ElevenLabs default), `vad_threshold` 0.4→0.5
- **Evidence**: Avg segment went from single-word fragments to 33.8 words

### 3. Garbage Translations
- **Root cause**: No minimum text filter — single-char fragments triggered full LLM calls
- **Fix**: Skip `<2 words AND <5 chars`, skip text without Arabic letters
- **Evidence**: 2 fragments correctly filtered, 0 garbage in output

### 4. Gunicorn Timeout
- **Fix**: 120→600s to support 532s test file

## Files Modified
| File | Commit | Changes |
|------|--------|---------|
| `backend/app/services/elevenlabs.py` | `681f838` | Skip committed_transcript, dedup, VAD params |
| `backend/app/services/translation.py` | `681f838` | Fragment filter, Arabic char check |
| `backend/startup.sh` | `681f838` | Timeout 120→600 |

## E2E Test Results (532s Arabic Audio)
| Metric | Value |
|--------|-------|
| Committed segments | 44 |
| Avg words/segment | 33.8 |
| Total translations | 35 |
| Clean Hebrew | 34 (97%) |
| Empty translations | 1 (GPT-5 fallback on 123-word segment) |
| Mixed-script | 0 |
| Duplicates | 0 |
| Primary model | gpt-5.2 (34/35 = 97%) |
| Avg latency | 2,038ms |

## What's Next (Step 6: A/B Tuning)
1. **VAD threshold sweep**: Try 1.5, 2.0, 2.5s — compare segment coherence
2. **Context window**: Try sizes 3, 5, 7 — larger may help coherence
3. **Translation model**: Compare GPT-5.2 vs Gemini-2.5-Flash
4. **previous_text param**: Pass to ElevenLabs for better transcription continuity
5. **Long segment handling**: Investigate empty translation on 123-word segment (GPT-5 fallback)

**Method**: One variable at a time. Redeploy + upload 532s test file + compare logs.

## Learnings Persisted (Memory MCP)
- `RealTime-ElevenLabs-Duplication-Fix`: Both event types fire per utterance
- `RealTime-VAD-Arabic-Tuning`: Arabic needs 1.5s+ silence threshold
- `RealTime-Translation-Filters`: Fragment filters save context window quality
- `RealTime-GPT52-Translation-Quality`: 97% clean at ~2s latency
- `RealTime-Gunicorn-Timeout`: 600s for long file uploads

## Known Issues
- GPT-5 fallback returned empty for 123-word segment (needs investigation)
- Pipeline CI/CD still broken (RBAC)
- 2 single-word segments still passed VAD (correctly filtered by translation.py)
