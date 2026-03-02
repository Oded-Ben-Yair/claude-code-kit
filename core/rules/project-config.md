# Project Configuration & Orchestration

## Project Directory Mapping

See CLAUDE.md Project Map (single source of truth).
Each project has: `.claude/status.json`, `.claude/decisions.log`

## Session Lifecycle

1. **Start**: `session-start-enhanced.sh` injects git context + previous session + project status
2. **Work**: Track via status.json, persist decisions to Memory MCP
3. **End**: `/end-of-session` skill -> handover doc + git sync + session-index.json update

## Skills Standards

- YAML frontmatter with `---` delimiters required
- `name` field must match directory name
- `description` under 1024 chars
- `metadata.version` for iteration tracking
- Directory structure: `SKILL.md` + optional `references/` subdirectory
- Heavy content (templates, schemas, sub-skills) goes in `references/`
- Skill iteration via `/learning-loop`
- Validate with `~/.claude/scripts/skill-audit.sh`

## Context Management

- Auto-compaction at ~65-75% context usage (transparent, infinite conversations)
- Save critical state to files before compaction for manual fallback
- Memory MCP persists architectural decisions cross-session

## FPF-Lite: First Principles Reasoning

**Auto-trigger when**: task touches 3+ files OR involves auth/secrets/crypto/infra/DB schema/PII
**Skip when**: user says "just fix it", "quick fix", "#urgent"
**Process**: Generate 2-3 hypotheses -> present options -> WAIT for human choice (non-negotiable)
**WLNK**: Confidence = min(all evidence), never average. Surface when < 0.5.

## Gemini Configuration (3.1 Pro — Feb 2026)

- **Models**: `gemini-3.1-pro-preview` (reasoning), `gemini-3-flash-preview` (fast), `gemini-3-pro-image-preview` (image gen)
- **Temperature**: ALWAYS 1.0 (lower causes looping/degradation)
- **Thinking**: `"low"` for simple, `"medium"` for balanced (NEW in 3.1 Pro — approx 3.0 Pro high at lower cost), `"high"` for deep reasoning (default)
- **Media resolution**: Images=HIGH (1120 tok), PDFs=MEDIUM (560), Video=LOW (70/frame)
- **Structured output**: For `with_structured_output()` on nested Pydantic models, use `method="json_schema"` (response_schema mode) — more reliable than default function calling. Gemini 2.5 Flash thinking model truncates structured output ~50% due to thinking budget consuming output tokens. Use `gemini-2.0-flash` for structured output tasks.

Origin: Hey Seven Phase 5 (2026-02-22) — LLM-as-judge with nested Pydantic model failed 50% with 2.5-flash. Switched to 2.0-flash + json_schema method.

## MCP Token Budget

| Always Active | ~Tokens | Lazy-Loaded | ~Tokens |
|---------------|---------|-------------|---------|
| Memory | ~6k | Perplexity | ~3k |
| Azure AI Foundry | ~4k | Gemini | ~4k |
| Grok | ~4k | Context7 | ~2k |
| | | Playwright | ~14k |

## Core Agents (Plan -> Implement -> Verify)

| Agent | Role | Triggers |
|-------|------|----------|
| architect-planner | Design plans | design, plan, architect |
| code-worker | Execute plans | implement, build, fix |
| code-judge | Review code | review, validate, check |

## Consolidated Specialists

| Agent | Replaces | Triggers |
|-------|----------|----------|
| gemini-specialist | 7 Gemini agents | PDF, image, vision, design-to-code |
| research-specialist | 4 Perplexity agents | research, investigate, SEC |
| realtime-specialist | 4 Grok agents | X/Twitter, trending, social |
| reasoning-specialist | 5 GPT/DeepSeek agents | brainstorm, algorithm, math |

## Key Skills

| Skill | When |
|-------|------|
| `/go` | Start of new session (context recovery + auto-plan) |
| `/end-of-session` | End of work session |
| `/multi-model-debate` | Major architectural decisions (6-model council) |
| `/frontend` | UI/frontend work, design-to-code |
| `/find-solution` | When stuck or looping |
| `/fix-pipeline` | Auto-diagnose and fix CI/CD failures |
| `/scrap-reimplement` | Destructive recovery after 3+ failed fixes |
| `/pre-mortem` | Risk assessment before risky tasks (3+ files, auth, crypto, infra) |
| `/ship-it` | Anti-perfectionism — declare "good enough", stop scope creep |
| `/clean-env` | Deep WSL + Windows cleanup — caches, zombies, memory |

## Project State Files (MANDATORY)

Each project must maintain these in `{project}/.claude/`:

### status.json Template
```json
{
  "project": "<project-name>",
  "currentState": {
    "summary": "Brief description of current state",
    "lastModified": "2026-02-03T12:00:00Z",
    "branch": "main",
    "commitHash": "abc1234"
  },
  "blockers": [],
  "nextSteps": [
    { "priority": 1, "description": "Highest priority next step" }
  ],
  "sessionNotes": {
    "lastSessionDate": "2026-02-03",
    "lastSessionId": "session-id"
  }
}
```

### decisions.log
Append-only log of architectural decisions:
```
[2026-02-03] DECISION: Chose X over Y because Z
[2026-02-03] DECISION: Using pattern A for feature B
```

Update status.json at session end. Append to decisions.log for every architectural choice.

## Quick Routing

Resume->/go | Research->perplexity | Social->grok | Visual->gemini | Code->code-worker | Quick fix->grok_code | Simplify->code-simplifier | Math->vertex_deepseek_reason | Decisions->/multi-model-debate | Pipeline fail->/fix-pipeline | Looping->/scrap-reimplement | Arch docs->/architecture-doc | Risky task->/pre-mortem | Scope creep->/ship-it | Slow/heavy/cleanup->/clean-env | Compliance audit->/azure-compliance | Understand code->Grep+Glob+Read
