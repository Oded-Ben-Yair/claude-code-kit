# Real-Time Sales Call Monitor

## Project Overview
Real-time Arabic → Hebrew sales call transcription and monitoring tool for Sagiv (sales manager).
Captures live VoiceSpin calls, transcribes Arabic speech, translates to Hebrew, displays with speaker separation.

## Architecture
```
Path A: Local Agent (future dual-channel)
[VoiceSpin on PC] → [Local Audio Agent] → [Backend API] → [Frontend Web UI]
                         │                      │
                    System audio           ElevenLabs Scribe 2
                    WASAPI loopback        + LLM Translation
                                           + AI Evaluator (Step 2)

Path B: Browser Capture (current MVP)
[Browser Mic] → [AudioWorklet] → [/ws/audio] → [Backend API] → [Frontend Web UI]
                    │                                │
               48kHz→16kHz resample           ElevenLabs Scribe 2
               Float32→Int16 PCM              + LLM Translation
               100ms buffered chunks
```

### Components
1. **local-agent/** — Python, runs on Sagiv's Windows PC, captures system audio via loopback, streams PCM to backend (kept for future dual-channel investigation)
2. **backend/** — Python FastAPI, deployed on Azure App Service, handles ElevenLabs WebSocket, translation, evaluation
3. **frontend/** — React 19/TypeScript, Azure Static Web App, real-time Hebrew transcript display + browser mic capture via AudioWorklet

## Key APIs
| Service | Endpoint | Purpose |
|---------|----------|---------|
| ElevenLabs Scribe 2 | `wss://api.elevenlabs.io/v1/speech-to-text/realtime` | Real-time Arabic transcription |
| Azure AI Foundry | gemini-2.5-flash (primary, 2s timeout) / GPT-5.2 (fallback, 5s timeout) | Arabic → Hebrew translation |
| Azure Key Vault | `kv-seekapa-apps` | API keys and secrets |

## Database
None (Step 1). Step 2 may add session storage for call history/evaluations.

## Tech Stack
- **Backend**: Python 3.12, FastAPI, websockets, httpx
- **Frontend**: React 19, TypeScript, Vite 6, TailwindCSS 3.4, Zustand, react-virtuoso
- **Local Agent**: Python 3.12, pyaudiowpatch (WASAPI loopback), soxr (resampling), websockets
- **Infra**: Azure App Service (backend), Azure Static Web Apps (frontend)

## Conventions
- All WebSocket communication uses JSON messages (except /ws/audio which accepts binary PCM frames)
- Browser audio capture: AudioWorklet in `public/audio-processor.worklet.js` (not bundled by Vite)
- Dual auth on /ws/audio: JWT (local agent) OR session cookie (browser)
- Speaker labels: `rep` and `customer` — v1 launches WITHOUT diarization (Scribe v2 Realtime has no speaker_id). Investigate dual-channel audio from VoiceSpin for v1.1
- Hebrew text direction: RTL in frontend (light mode default)
- Error messages: Hebrew for UI, English for logs
- Translation prompts: use `%%PLACEHOLDER%%` + `.replace()`, NEVER Python `.format()` on user text

## Production URLs
| Component | URL | Status |
|-----------|-----|--------|
| Backend API | https://app-realtime-monitor.azurewebsites.net | Deployed |
| Frontend SWA | https://brave-bay-048da2703.2.azurestaticapps.net | Deployed |
| Health Check | https://app-realtime-monitor.azurewebsites.net/health | Working |

## Key Vault Secrets
| Secret Name | Purpose |
|-------------|---------|
| ElevenLabs-ApiKey | Scribe v2 real-time transcription (raw WebSocket, NOT SDK) |
| RealTime-AgentApiKey | Local agent authentication |
| RealTime-JwtSecret | JWT signing for session tokens |
| AzureAIFoundry-Endpoint | Azure AI Foundry base URL for translation/evaluation |
| AzureAIFoundry-ApiKey | Azure AI Foundry API key |

## Git Remote
Azure DevOps — `Corp-AI/real-time-monitor`
