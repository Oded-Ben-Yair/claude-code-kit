# Handover: Real-Time Arabic→Hebrew Sales Call Monitor
**Session ID**: real-time-session-20260209-8cec1c
**Date**: 2026-02-09T13:03:00Z
**Health Score**: 90/100
**Branch**: main | **Commit**: b0476cf
**Memory MCP**: `real-time-session-20260209-8cec1c`

---

## What Was Done This Session

1. **Execution Plan v1.0 created and APPROVED** — 5 implementation phases with acceptance criteria
   - Breaks architecture v2.2 into sequential, testable phases
   - Each phase has file-level ownership boundaries for parallel code-workers
   - Written to `docs/execution-plan.md`

2. **Status tracking established** — `.claude/status.json`, `.claude/decisions.log` initialized

3. **12 architectural decisions documented** in `.claude/decisions.log`:
   - ElevenLabs Scribe v2 raw WebSocket (NOT SDK)
   - Translation: openai SDK with Azure AI Foundry endpoint (Gemini Flash primary, GPT-5.2 fallback)
   - Auth: JWT for agent, session cookie for frontend
   - No diarization in v1 (Scribe v2 Realtime doesn't support it)
   - Azure App Service (NOT Functions — 10-min timeout incompatible with WS)
   - Audio capture: pyaudiowpatch + soxr resampling

4. **Initial commit** of all scaffold code + architecture + execution plan

---

## Current State

- **All code is scaffold-only** — empty `__init__.py`, minimal `main.py`, basic `App.tsx`
- **Architecture doc v2.2** (`docs/architecture.md`) is the master spec (~1200 lines, 16 sections)
- **Execution plan v1.0** (`docs/execution-plan.md`) defines exactly what to build and in what order
- **No remote yet** — Azure DevOps repo `Corp-AI/real-time-monitor` needs to be created (Phase 5)
- **Legal blocker**: Section 2 compliance blocks PRODUCTION deployment, NOT implementation

---

## Next Session Priority (P0)

**Phase 1: Implement backend auth + audio WebSocket + local audio agent**

### Recommended approach:
1. Create Agent Team with 3 code-workers:
   - **Worker A**: `backend/app/auth/` (JWT handler, session handler, dependencies, config)
   - **Worker B**: `backend/app/ws/` (audio WS handler, connection manager) + `backend/app/logging_config.py`
   - **Worker C**: `local-agent/` (audio_capture, resampler, ws_client, auth)
2. Each worker follows `docs/execution-plan.md` Phase 1 exactly
3. After implementation: `code-judge` hostile review
4. Acceptance criteria in execution plan Phase 1

### Key files to implement:
```
backend/app/auth/__init__.py          (new)
backend/app/auth/jwt_handler.py       (new)
backend/app/auth/session_handler.py   (new)
backend/app/auth/dependencies.py      (new)
backend/app/config.py                 (new)
backend/app/ws/audio.py               (new)
backend/app/ws/manager.py             (new)
backend/app/logging_config.py         (new)
backend/tests/test_auth.py            (new)
backend/tests/test_ws_audio.py        (new)
local-agent/audio_capture.py          (new)
local-agent/resampler.py              (new)
local-agent/ws_client.py              (new)
local-agent/auth.py                   (new)
local-agent/tests/test_resampler.py   (new)
local-agent/tests/test_ws_client.py   (new)
```

---

## Key Documents

| Document | Path | Purpose |
|----------|------|---------|
| Architecture v2.2 | `docs/architecture.md` | Master spec (16 sections, ~1200 lines) |
| Execution Plan v1.0 | `docs/execution-plan.md` | Implementation phases + acceptance criteria |
| Decisions Log | `.claude/decisions.log` | 12 architectural decisions with rationale |
| Status | `.claude/status.json` | Project state machine |
| Project CLAUDE.md | `CLAUDE.md` | Project conventions, Key Vault secrets, tech stack |

---

## Blockers

| Blocker | Severity | Impact |
|---------|----------|--------|
| Legal compliance (Arch Section 2) | Blocks production | Does NOT block implementation |
| Azure DevOps repo not created | Blocks push | Local development unaffected |
| VoiceSpin dual-channel investigation | Blocks diarization | v1 works without it (mono stream) |

---

## Patterns Established

- WebSocket for all real-time communication
- Three-tier: local-agent → backend → frontend
- Safe string templating: `%%PLACEHOLDER%%` + `.replace()`, never `.format()`
- CORS hardcoded allowlist, never wildcard
- JWT in Authorization header for agent, session cookie for frontend
- Code-judge hostile review after each implementation phase
- Event bus for internal pub/sub (transcript events)
- structlog with PII filter (never log transcript text or audio)

---

## Memory MCP Entity

Search for: `real-time-session-20260209-8cec1c`

---

## Next Session Prompt (Copy-Paste Ready)

```
Implement Phase 1 of the real-time Arabic→Hebrew sales call monitor.

Read these files first:
1. docs/execution-plan.md — Phase 1 section (the spec to implement)
2. docs/architecture.md — Sections 4, 5, 11 (audio capture, backend endpoints, auth)
3. .claude/decisions.log — 12 architectural decisions
4. CLAUDE.md — project conventions and Key Vault secrets

Phase 1 has 3 independent work streams (can run in parallel with Agent Teams):

Worker A — Backend Auth + Config:
- backend/app/config.py (structured settings from env/Key Vault)
- backend/app/auth/__init__.py
- backend/app/auth/jwt_handler.py (JWT creation, validation, 60s grace, refresh)
- backend/app/auth/session_handler.py (bcrypt password, HTTP-only Secure SameSite=Strict cookie)
- backend/app/auth/dependencies.py (FastAPI DI for both auth methods)
- Add endpoints to main.py: POST /api/auth/token, POST /api/auth/login, GET /api/auth/me
- backend/tests/test_auth.py

Worker B — Backend WebSocket + Logging:
- backend/app/ws/audio.py (WS /ws/audio, JWT auth on upgrade, Origin validation, binary PCM, rate limit 15/sec, 64KB max frame)
- backend/app/ws/manager.py (max 1 audio session, reject second)
- backend/app/logging_config.py (structlog JSON, PII filter: redact Arabic/Hebrew >20 chars, base64 >100 chars, API key patterns)
- backend/tests/test_ws_audio.py

Worker C — Local Audio Agent:
- local-agent/audio_capture.py (pyaudiowpatch WASAPI loopback, stereo→mono, device enumeration)
- local-agent/resampler.py (soxr streaming, device rate→16kHz, float32→int16)
- local-agent/ws_client.py (reconnection: 1s base, 2x, 30s cap, ±20% jitter, 10 max; ring buffer 10s; heartbeat 20s; 100ms chunks = 3200 bytes)
- local-agent/auth.py (JWT exchange via POST /api/auth/token, store, refresh)
- Update local-agent/config.py with auth config
- local-agent/tests/test_resampler.py, test_ws_client.py

After all 3 workers complete: run code-judge hostile review.

Acceptance criteria (all must pass):
- Agent captures audio from Windows default output via WASAPI loopback
- Agent authenticates with backend via JWT (API key → token exchange)
- Binary PCM streams over WS at 100ms intervals (3200 bytes/chunk)
- Backend logs audio chunk metadata (count, sequence, bytes — NOT content)
- Reconnection: kill backend, restart, agent reconnects with backoff
- Rate limit rejects >15 msg/sec
- Origin validation rejects unknown origins
- Max 1 audio session — second connection rejected
- All tests pass: pytest backend/tests/, pytest local-agent/tests/
- Frontend login endpoint returns session cookie (curl test)
```
