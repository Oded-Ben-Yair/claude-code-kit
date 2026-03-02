# Agent Teams Templates

Project-specific team compositions for common workflows. These are starting points — the lead adapts based on the actual task.

## QC Analyzer: Pipeline Team

| Teammate | Role | Owns | MCP Tools |
|----------|------|------|-----------|
| transcription-worker | Transcription processing | `shared/transcription/`, whisper config | `gemini-query` (audio) |
| diarization-worker | Speaker detection & labeling | `shared/diarization/`, speaker models | `vertex_chat` |
| analysis-worker | Call quality scoring | `shared/analysis/`, scoring logic | `vertex_chat`, `perplexity_research` |
| quality-checker | End-to-end validation | Test files, output verification | `gemini-query` (vision for reports) |

**When**: Multi-stage pipeline changes, speaker detection fixes, output format changes.

**Context Requirements**: Transcription pipeline architecture, current speaker model config, test audio files for validation.
**Task Count**: 5-6 tasks per teammate.
**Shared Memory**: `~/.claude/teams/{team-name}/team-memory.md`
**Post-Team Handover**: Write pipeline findings to `{project}/.claude/status.json` + append to `{project}/.claude/decisions.log`.

## Sentimark: Research + Implement

| Teammate | Role | Owns | MCP Tools |
|----------|------|------|-----------|
| data-researcher | Market research, API investigation | Research docs, data sources | `perplexity_research`, `grok_search` |
| algorithm-dev | Prediction algorithms, ML models | `services/prediction/`, model code | `vertex_deepseek_reason`, `vertex_chat` |
| visualization-dev | Dashboard, charts, frontend | `frontend/`, visualization components | `gemini-query` (vision validation) |

**When**: New prediction features, dashboard redesigns, data source integration.

**Context Requirements**: Current prediction model architecture, data source APIs, frontend component structure.
**Task Count**: 5-6 tasks per teammate.
**Shared Memory**: `~/.claude/teams/{team-name}/team-memory.md`
**Post-Team Handover**: Write research findings and model decisions to `{project}/.claude/status.json` + append to `{project}/.claude/decisions.log`.

## Compliance: Review Team

| Teammate | Role | Owns | MCP Tools |
|----------|------|------|-----------|
| content-writer | Exam content, questions, translations | Content files, i18n | `vertex_chat`, `perplexity_research` |
| compliance-reviewer | Regulatory accuracy review | Review notes, compliance checks | `perplexity_reason` |
| test-writer | Test coverage, edge cases | Test files, fixtures | `vertex_chat` |

**When**: New exam modules, regulatory updates, content review cycles.

**Context Requirements**: Current exam structure, regulatory source documents, i18n setup, existing test fixtures.
**Task Count**: 5-6 tasks per teammate.
**Shared Memory**: `~/.claude/teams/{team-name}/team-memory.md`
**Post-Team Handover**: Write content review findings to `{project}/.claude/status.json` + append to `{project}/.claude/decisions.log`.

## Frontend: Design + Build

| Teammate | Role | Owns | MCP Tools |
|----------|------|------|-----------|
| design-analyst | Design research, mockup analysis | Design specs, reference screenshots | `gemini-query` (vision), `perplexity_research` |
| component-builder | React/TS implementation | Component files, styles | `grok_code`, `vertex_chat` |
| visual-verifier | Screenshot validation, accessibility | Test screenshots, validation reports | `playwright`, `gemini-analyze-image` |

**When**: New UI features, design system changes, visual redesigns.

**Context Requirements**: Design mockups/screenshots, component library docs, accessibility requirements, brand guidelines.
**Task Count**: 5-6 tasks per teammate.
**Shared Memory**: `~/.claude/teams/{team-name}/team-memory.md`
**Post-Team Handover**: Write design decisions and component inventory to `{project}/.claude/status.json` + append to `{project}/.claude/decisions.log`.

## General: Parallel Investigation

| Teammate | Role | Owns | MCP Tools |
|----------|------|------|-----------|
| hypothesis-a | Test approach A | Branch/files for approach A | Varies by task |
| hypothesis-b | Test approach B | Branch/files for approach B | Varies by task |
| evidence-gatherer | Research & data collection | Research notes | `perplexity_research`, `grok_search` |

**When**: Competing implementation approaches, debugging with multiple hypotheses, architecture exploration.

**Context Requirements**: Problem statement with reproduction steps, relevant error logs, list of hypothesis branches/files.
**Task Count**: 5-6 tasks per teammate.
**Shared Memory**: `~/.claude/teams/{team-name}/team-memory.md`
**Post-Team Handover**: Write winning hypothesis and evidence to `{project}/.claude/status.json` + append to `{project}/.claude/decisions.log`.

## LLM Agent App: Build Team

| Teammate | Role | Owns | MCP Tools |
|----------|------|------|-----------|
| agent-architect | LangGraph core, tools, RAG | src/agent/, src/rag/ | `gemini-query`, `vertex_chat` |
| api-builder | FastAPI, deployment | src/api/, Docker, CI/CD | `vertex_chat`, `grok_code` |
| ui-designer | Frontend with branding | src/frontend/, static/ | `gemini-query` (vision) |

**When**: New LLM agent applications, chatbot builds, RAG pipeline projects, AI assistant implementations.

**Context Requirements**: Agent architecture (LangGraph state, tools, prompts), RAG data sources, API framework choice, deployment target.
**Task Count**: 5-6 tasks per teammate.
**Shared Memory**: `~/.claude/teams/{team-name}/team-memory.md`
**Post-Team Handover**: Write agent architecture decisions and integration points to `{project}/.claude/status.json` + append to `{project}/.claude/decisions.log`.

## Rules for All Teams

1. **Max 4 teammates** per team (cost + rate limit control)
2. **No file overlap** — each teammate owns distinct files
3. **Lead uses delegate mode** for 3+ teammates (Shift+Tab)
4. **Plan approval required** for `shared/` or DB schema changes
5. **All teammates use Opus 4.6** (Rule 13)
6. **Teams don't persist** across sessions — capture findings in handover
7. **NEVER use `code-judge` for file-writing tasks** — it only has Read/Grep/Glob (no Write). Use `general-purpose` for review rounds that write findings to files.

8. **Wave-based parallelism** — for multi-dimension improvement sprints, organize into waves with strict file ownership. No two waves edit the same file. Code waves before doc waves when they share data (pattern counts, helpline numbers). Each wave that adds new behavior MUST include tests.

Origin: Hey Seven R18 (2026-02-22) — code-judge reviewers completed analysis but couldn't write output files. Re-launched as general-purpose agents. R68 (2026-02-26) — 6-wave parallel sprint (5 code + 1 review) completed in ~2 hours using strict file ownership per wave.

## Agent Teams Known Limitations

1. **No session resumption with in-process teammates** — if the session ends or crashes, teammates and their in-progress work are lost. Always checkpoint to team-memory.md frequently.
2. **Task status can lag** — TaskList may not reflect real-time teammate progress. If a teammate appears stuck, check their session directly (Enter on teammate) before reassigning.
3. **One team per session** — clean up the current team (full shutdown protocol) before starting a new one. Overlapping teams cause file ownership conflicts and context confusion.
4. **No nested teams** — teammates cannot spawn their own teams. If a teammate needs parallel work, they should request the lead to create subtasks instead.
5. **Lead is fixed for lifetime of team** — the agent that creates the team remains lead until shutdown. Lead role cannot be transferred mid-session.
6. **Lazy-loaded MCP tools may be unavailable** — Playwright, Gemini, Perplexity may not be loaded in teammate contexts. Verify tool availability before delegating MCP-dependent work, or load via ToolSearch in the lead first.
7. **Max context per teammate** — each teammate has an independent context window. Large codebases may require focused file subsets rather than broad exploration.
