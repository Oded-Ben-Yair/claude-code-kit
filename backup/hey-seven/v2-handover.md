# Hey Seven v2 — Session Handover

**Prepared**: 2026-02-17
**For**: Next session (v2 brainstorming with Oded's interview insights)
**Tag**: v1.0.0 (frozen, do not modify)

---

## Session Goal

Oded just came back from the interview with Brett (CTO) and Neta (R&D Site Manager).
He believes he will pass. The goal is to:

1. **Listen** to everything Oded was told in the interview about the product, vision, and team
2. **Brainstorm** v2 architecture incorporating their feedback and product direction
3. **Plan** the real product build (not just an assignment demo)

---

## v1 State Summary

### What We Built
- Custom 8-node LangGraph StateGraph for Mohegan Sun Q&A
- 5 deterministic pre-LLM guardrails (56 patterns, 3 languages)
- RAG with RRF reranking and idempotent ingestion
- SSE streaming with real-time graph trace panel
- FastAPI backend with 6 pure ASGI middleware
- Branded single-page frontend (gold/dark/cream casino theme)
- Docker + Cloud Build CI/CD → Cloud Run deployment

### Key Stats
- 382 tests | 95.9/100 review score (5 LLMs) | 31 commits
- Live: https://hey-seven-180574405300.us-central1.run.app
- GitHub: Oded-Ben-Yair/hey-seven (tagged v1.0.0)

### Known Issues / v2 Gaps
1. **Demo stuck bug**: No SSE heartbeat between LLM calls, no client timeout, cold start triggers RAG ingestion
2. **No persistence**: MemorySaver + ChromaDB = lost on restart
3. **Single property**: Hardcoded to Mohegan Sun
4. **Read-only**: Cannot take actions (bookings, reservations)
5. **Single-file frontend**: 1163-line HTML, not scalable
6. **No monitoring**: Structured logging only, no LangSmith

---

## Demo Bug Analysis (CTO Said It Got Stuck)

**Root causes identified** (see `.claude/v1-learnings.md` for full details):

| Cause | Severity | Fix |
|-------|----------|-----|
| Cold start triggers RAG ingestion | HIGH | Pre-warm endpoint, cache embeddings in image |
| No SSE heartbeat between LLM calls (3-10s silence) | HIGH | Send keepalive events every 2-3 seconds |
| No client-side timeout | MEDIUM | Add 30s timeout with auto-retry in frontend |
| Gemini API latency × 4+ LLM calls | MEDIUM | Optimize pipeline (parallel where possible) |

---

## Architecture Decisions (Preserved from v1)

All in `.claude/decisions.log` (34 decisions). Key ones for v2:

- LangGraph as primary framework (CTO preference)
- GCP stack (Cloud Run, Firestore, Vertex AI)
- Gemini as primary LLM
- Custom StateGraph > create_react_agent (validation loops, guardrails)
- SSE for streaming (not WebSocket)
- Pre-LLM deterministic guardrails (defense-in-depth)

---

## Files Map

### Source Code (v1 — frozen at tag)
```
src/agent/graph.py       — 8-node StateGraph + streaming
src/agent/nodes.py       — All 8 nodes + routing logic
src/agent/guardrails.py  — 5 guardrail layers (56 patterns)
src/agent/state.py       — PropertyQAState + Pydantic models
src/agent/prompts.py     — System prompts (concierge, router, validator)
src/agent/circuit_breaker.py — LLM failure protection
src/agent/tools.py       — RAG search tools
src/rag/pipeline.py      — Ingest + retrieve with RRF reranking
src/rag/embeddings.py    — Google embeddings wrapper
src/api/app.py           — FastAPI app, SSE streaming
src/api/middleware.py     — 6 ASGI middleware
src/api/models.py        — Pydantic schemas
src/config.py            — 31 settings via pydantic-settings
static/index.html        — Branded chat UI
data/mohegan_sun.json    — 79 items, 7 categories
```

### Project State Files
```
.claude/status.json       — Current project state
.claude/decisions.log     — 34 architectural decisions
.claude/v1-learnings.md   — Full retrospective
.claude/v2-handover.md    — THIS FILE
```

### Research (Preserved)
```
research/brand-design.md           — Hey Seven visual identity
research/casino-domain.md          — Casino host operations
research/company-intel.md          — Hey Seven company intel
research/langgraph-gcp.md          — LangGraph + GCP patterns
research/langgraph-latest.md       — LangGraph 1.0.8 latest
research/frontend-latest.md        — React 19, Next.js 15/16, Tailwind 4
research/perplexity-deep/          — Deep research (regulations, market, psychology)
research/personas/                 — LinkedIn profiles (Neta, etc.)
```

### Assignment Prep (gitignored, local only)
```
assignment/architecture.md         — v9.0 architecture doc (3539 lines, 10 dimensions)
assignment/requirements.md         — Parsed assignment requirements
assignment/flashcards.html         — 66 interactive flashcards
assignment/interview-study-guide.pdf — Print study guide
assignment/salary-research.md      — Salary research
```

---

## What To Ask Oded (Next Session)

When Oded starts the next session, the brainstorming should cover:

### About the Interview
1. What did Brett (CTO) say about the product direction?
2. What's the actual architecture they're building? (Multi-agent? Single agent? Microservices?)
3. What properties are they targeting first?
4. What channels? (Chat only? Voice? SMS? WhatsApp?)
5. What did they think of the demo? What impressed them? What didn't?
6. Did they mention specific technical challenges they're facing?
7. What's the team structure? Who would Oded work with?
8. Any technology preferences beyond LangGraph/GCP? (Specific databases, services, tools?)
9. Timeline — when do they need the product?
10. What's their definition of MVP?

### About v2 Direction
11. Multi-property architecture — how do they envision switching between casinos?
12. Action capabilities — what actions should the agent take? (reservations, comp offers, player tracking?)
13. Integration points — PMS (property management system), CRM, loyalty programs?
14. Compliance requirements — state-by-state differences, audit logging?
15. User authentication — guest identification, loyalty tier detection?
16. Real-time data — event schedules, restaurant wait times, room availability?
17. Escalation — when should the AI hand off to a human host?

---

## Environment State

- **Branch**: main (clean, up to date with origin)
- **Tag**: v1.0.0 pushed to GitHub
- **Cloud Run**: Live and healthy
- **Tests**: 382 collected (pass with API key)
- **No uncommitted changes**
- **gcloud CLI**: Not installed on WSL (use browser for Cloud Run logs)

---

## Prompt for Next Session

```
I'm back from the Hey Seven interview! Here's what I learned:

[Oded fills in interview insights here]

Let's brainstorm v2 based on what they told me.
```
