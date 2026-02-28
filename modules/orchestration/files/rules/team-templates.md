# Agent Teams Templates

Project-specific team compositions for common workflows. These are starting points — the lead adapts based on the actual task.

## General: Parallel Investigation

| Teammate | Role | Owns |
|----------|------|------|
| hypothesis-a | Test approach A | Branch/files for approach A |
| hypothesis-b | Test approach B | Branch/files for approach B |
| evidence-gatherer | Research & data collection | Research notes |

**When**: Competing implementation approaches, debugging with multiple hypotheses, architecture exploration.

**Context Requirements**: Problem statement with reproduction steps, relevant error logs, list of hypothesis branches/files.
**Task Count**: 5-6 tasks per teammate.
**Shared Memory**: `~/.claude/teams/{team-name}/team-memory.md`

## Frontend: Design + Build

| Teammate | Role | Owns |
|----------|------|------|
| design-analyst | Design research, mockup analysis | Design specs, reference screenshots |
| component-builder | React/TS implementation | Component files, styles |
| visual-verifier | Screenshot validation, accessibility | Test screenshots, validation reports |

**When**: New UI features, design system changes, visual redesigns.

**Context Requirements**: Design mockups/screenshots, component library docs, accessibility requirements, brand guidelines.
**Task Count**: 5-6 tasks per teammate.
**Shared Memory**: `~/.claude/teams/{team-name}/team-memory.md`

## LLM Agent App: Build Team

| Teammate | Role | Owns |
|----------|------|------|
| agent-architect | Agent core, tools, RAG | src/agent/, src/rag/ |
| api-builder | API framework, deployment | src/api/, Docker, CI/CD |
| ui-designer | Frontend with branding | src/frontend/, static/ |

**When**: New LLM agent applications, chatbot builds, RAG pipeline projects, AI assistant implementations.

**Context Requirements**: Agent architecture (state, tools, prompts), RAG data sources, API framework choice, deployment target.
**Task Count**: 5-6 tasks per teammate.
**Shared Memory**: `~/.claude/teams/{team-name}/team-memory.md`

## Research + Implement

| Teammate | Role | Owns |
|----------|------|------|
| researcher | Research, API investigation | Research docs, data sources |
| implementer | Core implementation | Source code, models |
| tester | Test coverage, edge cases | Test files, fixtures |

**When**: New features requiring research, data integration, algorithm development.

**Context Requirements**: Current architecture, relevant APIs, existing test fixtures.
**Task Count**: 5-6 tasks per teammate.
**Shared Memory**: `~/.claude/teams/{team-name}/team-memory.md`

## Rules for All Teams

1. **Max 4 teammates** per team (cost + rate limit control)
2. **No file overlap** — each teammate owns distinct files
3. **Lead uses delegate mode** for 3+ teammates (Shift+Tab)
4. **Plan approval required** for shared/ or database schema changes
5. **Teams don't persist** across sessions — capture findings in handover
6. **NEVER use `code-judge` for file-writing tasks** — it only has Read/Grep/Glob (no Write). Use `general-purpose` for review rounds that write findings to files.
7. **Wave-based parallelism** — for multi-dimension improvement sprints, organize into waves with strict file ownership. No two waves edit the same file. Code waves before doc waves when they share data. Each wave that adds new behavior MUST include tests.

Origin: Production agent projects — code-judge reviewers completed analysis but couldn't write output files. Re-launched as general-purpose agents. Wave-based parallelism with strict file ownership per wave enables efficient sprint execution.

## Agent Teams Known Limitations

1. **No session resumption with in-process teammates** — if the session ends or crashes, teammates and their in-progress work are lost. Always checkpoint to team-memory.md frequently.
2. **Task status can lag** — TaskList may not reflect real-time teammate progress. Check their session directly before reassigning.
3. **One team per session** — clean up the current team before starting a new one. Overlapping teams cause file ownership conflicts.
4. **No nested teams** — teammates cannot spawn their own teams. Request the lead to create subtasks instead.
5. **Lead is fixed for lifetime of team** — the agent that creates the team remains lead until shutdown.
6. **Lazy-loaded MCP tools may be unavailable** — verify tool availability before delegating MCP-dependent work.
7. **Max context per teammate** — each teammate has an independent context window. Large codebases may require focused file subsets rather than broad exploration.
