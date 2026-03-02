# Bootstrap Prompt for New Claude Code Environment

## Quick Start

Copy-paste this into a fresh Claude Code session on your new machine:

---

### Step 1: Clone and Install

```
I need you to set up my Claude Code development environment from my GitHub kit.

1. Clone: git clone https://github.com/Oded-Ben-Yair/claude-code-kit.git ~/claude-code-kit
2. Run: chmod +x ~/claude-code-kit/install.sh && ~/claude-code-kit/install.sh
3. This installs to ~/.claude/ — skills, agents, hooks, rules, docs, scripts, templates

After install, restart Claude Code so it loads the new CLAUDE.md and settings.
```

### Step 2: Restore Memory MCP Knowledge Graph

```
My knowledge graph backup is at ~/claude-code-kit/backup/memory-mcp/knowledge-graph-full-dump.json

Read this file and restore ALL entities and relations into Memory MCP using mcp__memory__create_entities and mcp__memory__create_relations. This contains all my cross-session architectural decisions, patterns, and learnings from 80+ sessions across multiple projects.

The file is a JSON array with entities (name, entityType, observations) and relations. Process it in batches.
```

### Step 3: Configure MCP Servers

```
I need to set up these MCP servers. Read ~/claude-code-kit/backup/global-config/dot-claude.json for the structure, but I need new API keys:

1. Memory MCP — built-in, should work automatically
2. Perplexity — I need a new PERPLEXITY_API_KEY from perplexity.ai
3. Gemini — built-in, needs GOOGLE_API_KEY
4. Grok — needs XAI_API_KEY from x.ai
5. Playwright — needs Edge browser, see ~/.claude/mcp-servers/playwright-cdp/start-edge-mcp.sh
6. Context7 — built-in, no key needed

For cloud AI (replacing Azure AI Foundry), set up based on whatever cloud I'm using:
- GCP: Vertex AI (see ~/claude-code-kit/mcp-servers/multi-provider-ai/)
- Azure: Azure AI Foundry (same pattern as before)
- AWS: Bedrock

Update ~/.claude.json with the MCP server configs and new API keys.
```

### Step 4: Verify Everything Works

```
Run these checks:
1. List available skills — should see /go, /end-of-session, /frontend, /pre-mortem, etc.
2. Test Memory MCP — search for "langgraph" entities
3. Test a hook — session-start should show context
4. Read ~/.claude/CLAUDE.md — verify 13 hard rules are loaded
5. Read ~/.claude/rules/ — verify all rule files (code-quality, langgraph-patterns, rag-production, etc.)
```

---

## What's In The Kit

### Core Development Infrastructure
- **CLAUDE.md** — Master instructions (13 hard rules, bug fix protocol, deployment safety)
- **22 hooks** — Auto-router, schema verify, quality validation, deploy gate, etc.
- **9 active agents** — architect-planner, code-worker, code-judge, gemini-specialist, etc.
- **30+ skills** — /go, /end-of-session, /frontend, /pre-mortem, /ship-it, /create-diagram, etc.
- **11 rule files** — code-quality, db-safety, langgraph-patterns, rag-production, etc.
- **15+ doc files** — LangGraph safety/scalability/testing/domain, FastAPI streaming, ML production, etc.

### Hey Seven Knowledge (LangGraph AI Agent Patterns)
- **langgraph-patterns.md** (330 lines) — Custom StateGraph, validation loops, structured routing, guardrails, state reducers, specialist DRY extraction, feature flags, priority ordering
- **langgraph-safety.md** — Fail-closed/open, degraded pass, crisis handling, compliance gates
- **langgraph-scalability.md** — Circuit breaker, Redis, TTL, SSE streaming, async locks, backpressure
- **langgraph-testing.md** — Conftest patterns, E2E, mock LLM, behavioral scenarios
- **langgraph-domain.md** — Multi-tenant, sentiment, sarcasm, slang, extraction, guardrail wiring
- **rag-production.md** (188 lines) — Per-item chunking, RRF reranking, idempotent ingestion, version-stamp purging
- **hostile-review-protocol.md** (262 lines) — 3-tier evaluation, multi-model gate, ICC measurement, 95+ checklist
- **code-quality.md** — 50+ anti-patterns from 80+ review rounds
- **hey-seven/CLAUDE.md** — Full project architecture reference
- **hey-seven/decisions.log** — All architectural decisions
- **45 handover docs** — Complete session history with context

### Agent Teams Architecture
- **team-templates.md** — Pre-built team compositions for common workflows
- **orchestration-patterns.md** — 3-specialist pattern, parallel execution, shared memory protocol
- Team hooks (idle verify, task completed, subagent stop tracker)

### Memory MCP Knowledge Graph (378K chars)
- All cross-session entities, relations, observations
- ElevenLabs voice agent tuning patterns
- Browser automation / Playwright MCP patterns
- Review sprint learnings (R1-R76)
- Project-specific architectural decisions

---

## Key Concepts to Know

1. **Skills** are invoked with `/skill-name` — they load specialized instructions
2. **Hooks** run automatically on events (pre-tool, post-tool, session start/stop)
3. **Agents** are specialized subagent types (architect, worker, judge, specialist)
4. **Agent Teams** enable parallel work with 2-4 teammates on complex tasks
5. **Memory MCP** persists knowledge across sessions
6. **Rules** are always-loaded instructions in `~/.claude/rules/`
7. **Docs** are on-demand loaded by trigger words (see CLAUDE.md On-Demand Docs table)

## Architecture Philosophy

- **Understand before changing** — always read code before modifying
- **No mock data** — show real errors or "NOT CONNECTED"
- **Proof before done** — tests, screenshots, real API responses
- **Human decides** — generate 2-3 options for architectural choices
- **Opus 4.6 everywhere** — never use haiku or sonnet for subagents
