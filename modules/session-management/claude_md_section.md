## Session Management

### Session Lifecycle

```
Start ──> Work ──> [Compact] ──> End
  |                   |            |
  session-start   pre-compact   /end-of-session
  hook            save hook     skill + handover
  /go skill       post-compact
                  recover hook
```

### Skills

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `/go` | "go", "continue", "where were we" | Full context recovery + auto-plan from previous session |
| `/end-of-session` | "end session", "wrap up", "done for today" | Persist state to Memory MCP, generate handover, update session index |

### Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| `session-start-enhanced.sh` | SessionStart | Inject git context, previous session info, project status, health alerts |
| `pre-compact-save.sh` | PreCompact | Save critical state (git, plans, todos, project status) before context compaction |
| `post-compact-recover.sh` | SessionStart (compact) | Re-inject pre-compact snapshot after context compaction |

### Cross-Session Persistence

- **Memory MCP**: Searchable session entities with goals, decisions, learnings
- **Session Index**: `~/.claude/session-index.json` — find any session by project/date/health
- **Handover Files**: `{project}/.claude/handover-*.md` — detailed context for `/go` recovery
- **Pre-Compact Snapshots**: `~/.claude/session-memory/pre-compact-*.md` — crash recovery

### Session State Files

Each project maintains in `{project}/.claude/`:
- `status.json` — current state, blockers, next steps
- `decisions.log` — append-only architectural decision log
