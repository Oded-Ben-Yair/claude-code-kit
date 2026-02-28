## Orchestration

### Architect Planner Agent
- **Triggers**: plan, design, architect, decompose, scope, breakdown
- **Role**: Senior software architect — analyzes, plans, and decomposes tasks. Does NOT write code.
- **Tools**: Read, Glob, Grep (read-only)
- **Flow**: Context gathering -> Pattern mining -> Clarification -> Decomposition (max 7 subtasks) -> Structured handoff to code-worker
- **Output**: Architecture plan with risk assessment + structured JSON handoff

### Pre-Mortem Skill (`/pre-mortem`)
Risk assessment before implementation. Imagines failure to discover problems early.
- **Auto-triggers on**: tasks touching 3+ files, auth/secrets/crypto/infra, DB schema, PII, production deployments
- **Skip when**: "just do it", "quick fix", "#urgent"
- **Process**: Assume failure -> Reverse-engineer prevention -> Add safety gates -> Present to human for approval

### 3-Specialist Orchestration Pattern

```
User Request -> [Pre-Mortem] -> Planner -> GATE (human approval) -> Implementer -> Verifier -> Done
                                                                        ^              |
                                                                        +--- REVISE ---+  (max 3 retries)
```

Skip orchestration for: single-file changes, pure bug fixes, config updates, quick fixes.

### Agent Teams

**When to use Teams vs Subagents**:
- **Teams**: Multi-file parallel work, competing hypotheses, cross-layer changes
- **Subagents**: Quick focused tasks, fire-and-forget research, adversarial code review

**Team Rules**:
1. Max 4 teammates per team (cost + rate limit control)
2. No file overlap — each teammate owns distinct files
3. Lead uses delegate mode for 3+ teammates
4. Plan approval required for shared/ or database schema changes
5. Teams don't persist across sessions — capture findings in handover docs

### Team Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| teammate-idle-verify.sh | TeammateIdle | Prevents idle without proof of work. Role-aware: implementation teammates need test evidence, non-implementation roles (reviewer, analyst, planner) can idle freely. |
| task-completed-verify.sh | TaskCompleted | Quality gate on task completion. Checks task subject for trigger words (implement, fix, deploy) and requires matching evidence (tests, screenshots, pipeline status). |
| subagent-stop-tracker.sh | SubagentStop | Logs subagent duration and metadata to telemetry for performance tracking. |
| tool-failure-tracker.sh | PostToolUseFailure | Logs tool failures with error classification (timeout, permission, network, syntax) for debugging patterns. |
| config-change-audit.sh | ConfigChange | Logs settings changes, warns on security-relevant edits (permissions, hooks, MCP servers). |
| worktree-audit.sh | WorktreeCreate/Remove | Logs worktree creation/removal for audit trail. |

### Team Shared Memory Protocol

Location: `~/.claude/teams/{team-name}/team-memory.md`

- Each agent appends findings under their own `## Agent: {name}` section
- Shared decisions go in top-level `## Shared Decisions` section (lead only)
- Read at startup, write at checkpoints, final report at shutdown
- Lead synthesizes into project `status.json` and `decisions.log` during shutdown

### Plugin Skills (from superpowers)

The following workflows are available via the `superpowers` plugin:
- **brainstorming**: Structured ideation with convergence
- **writing-plans**: Create implementation plans with risk assessment
- **executing-plans**: Step-by-step plan execution with checkpoints
- **dispatching-parallel**: Fan-out independent tasks to parallel agents
- **subagent-driven**: Delegate focused tasks to specialized subagents
