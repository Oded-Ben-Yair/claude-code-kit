# Hey Seven v1 — Learnings & Retrospective

**Tagged**: v1.0.0 (2026-02-17)
**Assignment**: Property-aware Q&A chatbot using LangGraph for Mohegan Sun casino resort
**Duration**: Feb 12-17, 2026 (5 days: 2 research, 3 build)
**Result**: 382 tests, 95.9 avg review score (5 LLMs), live on Cloud Run

---

## What Worked

### 1. Pre-Building Infrastructure Before Assignment
- Researched Hey Seven, casino domain, LangGraph patterns, and GCP deployment BEFORE the assignment arrived
- Built boilerplate: agent, API, RAG, frontend, Docker, CI/CD templates
- When the assignment dropped, we already had 80% of the code ready
- **Lesson**: Speed of delivery IS the wow factor for a startup interview

### 2. Custom StateGraph Over create_react_agent
- The assignment needed deterministic guardrails (responsible gaming, prompt injection) that must fire BEFORE the LLM
- `create_react_agent` can't do validation loops or conditional branches
- The 8-node custom graph gave full control: router → retrieve → generate → validate → respond/retry/fallback
- **5 review models unanimously praised this as the standout architectural decision**

### 3. Multi-LLM Hostile Review Rounds (12 rounds)
- Used 5 LLMs (Gemini, GPT-5.2, Grok, Perplexity, DeepSeek) as adversarial reviewers
- Score trajectory: 58 → 80 → 85 → 90 → 96
- Caught ~290 findings across 10 dimensions
- Each model found different issues (Gemini: architecture, GPT: code quality, Grok: security)
- **Lesson**: Multi-model review catches things single-model review misses

### 4. Per-Item Chunking for Structured Data
- Casino data (restaurants, entertainment, hotel) is highly structured
- Text splitters destroy structured boundaries — used per-item chunking instead
- Category-specific formatters produce richer embeddings than `json.dumps()`
- **All 5 review models praised this as "shows deep understanding of RAG"**

### 5. Deterministic Pre-LLM Guardrails
- 5 guardrail layers: prompt injection, responsible gaming, age verification, BSA/AML, patron privacy
- 56 regex patterns, 3 languages (EN, ES, ZH)
- Fire BEFORE any LLM call — cost-free, deterministic, no latency
- **Lesson**: In regulated industries, deterministic beats probabilistic for safety

### 6. Real-Time Graph Trace Panel
- SSE events include `graph_node` start/complete with timing and metadata
- Frontend shows live node execution: which nodes fired, how long, what they produced
- **Differentiator**: No other candidate likely showed LangGraph internals in the UI

### 7. SSE Streaming Architecture
- Pure ASGI middleware (BaseHTTPMiddleware breaks SSE — learned this the hard way)
- `astream_events` v2 with per-node event filtering
- Client disconnect detection (`request.is_disconnected()`) prevents resource waste
- **Lesson**: SSE > WebSocket for LLM streaming (unidirectional, auto-reconnect)

---

## What Didn't Work / Issues

### 1. Demo "Getting Stuck" (CTO reported)
Probable causes identified via code analysis:
- **Cold start**: First request triggers RAG ingestion during `lifespan()` — user sees nothing
- **No SSE heartbeat**: Silence between LLM calls (3-10s each, 4+ calls total) — load balancer or browser may drop connection
- **No client-side timeout**: Frontend stays in "Thinking..." forever if connection drops silently
- **Fix for v2**: Add keepalive/heartbeat events, client-side timeout + auto-retry, warm-up endpoint

### 2. Context Overflow During Reviews (Rounds 6-8)
- Review findings + fix edits consumed too much main context
- 3 context overflows forced session restarts
- **Fix**: Invented team swarm pattern — reviewers write to files, fixer reads files, main lead sees only 5-line summary
- **Lesson**: Long review sessions need output-to-file discipline

### 3. LangGraph Version Pinning Pain
- Pinned `langgraph==0.2.60` but `create_react_agent` API changed (`prompt=` vs `state_modifier=`)
- Cost a full agent restructuring in early phase
- **Lesson**: Pin exact versions AND test API compatibility before committing

### 4. Single-File Frontend Limitation
- index.html is 1163 lines — functional but unmaintainable at scale
- No component system, no build pipeline, no TypeScript
- **v2 need**: Real Next.js + React frontend (listed in job posting as nice-to-have)

### 5. InMemorySaver / ChromaDB for Demo
- MemorySaver loses all state on restart (every Cloud Run cold start)
- ChromaDB runs in-process, not production-grade
- **v2 need**: FirestoreSaver + Vertex AI Vector Search

---

## Architecture Trade-Offs (Documented)

| Decision | Trade-off | Why We Chose It |
|----------|-----------|-----------------|
| Custom StateGraph vs create_react_agent | More boilerplate code | Full control over validation loops and guardrails |
| Gemini 2.5 Flash vs Pro | Less capable model | GCP alignment, 10x cheaper, fast enough for Q&A |
| ChromaDB vs Vertex AI Vector Search | Not production-grade | Zero infrastructure for demo, easy local dev |
| Single HTML frontend vs Next.js | Not scalable | Ships with FastAPI, no build step, fast delivery |
| MemorySaver vs FirestoreSaver | Lost on restart | Demo doesn't need persistence, avoids GCP setup |
| 3 LLM calls per request vs 1 | Higher latency/cost | Defense-in-depth for regulated casino domain |
| Regex guardrails vs LLM-only | Maintenance burden | Deterministic, cost-free, no latency, no hallucination |
| RRF reranking vs single-query | Complexity | Better recall for proper noun queries |
| Template.safe_substitute vs .format | Slightly less readable | Prevents DoS via curly braces in user input |
| Pure ASGI middleware vs BaseHTTPMiddleware | More code | BaseHTTPMiddleware silently breaks SSE streaming |

---

## Key Patterns Extracted

These patterns are now in `~/.claude/rules/` for reuse across projects:

1. **LangGraph Patterns** (`langgraph-patterns.md`): StateGraph, validation loops, structured output routing, circuit breaker, SSE streaming, state design
2. **RAG Production** (`rag-production.md`): Per-item chunking, RRF reranking, SHA-256 dedup, multi-tenant safety, FakeEmbeddings for testing
3. **SSE Chat** (`sse-chat-patterns.md`): Pure ASGI middleware, heartbeat, disconnect detection, timeout

---

## By The Numbers

| Metric | Value |
|--------|-------|
| Git commits | 31 |
| Source files | ~15 Python + 1 HTML + configs |
| Source lines | ~3,000 |
| Tests | 382 (220 unit, 126 integration, 12 deterministic eval, 14 live eval) |
| Review rounds | 12 (5 LLMs each) |
| Findings fixed | ~290 |
| Final score | 95.9/100 avg (all dimensions 95+) |
| Guardrail patterns | 56 across 3 languages |
| LangGraph nodes | 8 |
| Config settings | 31 (all env-overridable) |
| Middleware classes | 6 (all pure ASGI) |
| Knowledge base items | 79 across 7 categories |
| Cost per request | ~$0.0014 |

---

## v2 Priorities (From Interview Insights)

*To be filled after Oded debriefs from the interview in next session.*

Placeholder areas based on v1 gaps:
- [ ] Demo stability (heartbeat, client timeout, warm-up)
- [ ] Production persistence (FirestoreSaver, Vertex AI Vector Search)
- [ ] Real frontend (Next.js + React 19)
- [ ] Multi-property support
- [ ] Action capabilities (bookings, reservations) — currently read-only
- [ ] Voice integration?
- [ ] LangSmith observability
- [ ] Load testing
