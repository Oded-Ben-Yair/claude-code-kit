# Recovery Phases (Phases 2-4)

Detailed instructions for context recovery, learning review, and health assessment.

---

## Phase 2: Context Recovery [10 seconds]

Read ALL context sources in parallel.

### 2.1 Read Handover File
Read the full handover markdown. Extract:
- Goals & achievement table
- Technical state (git, tests, build)
- Key files modified
- Blockers & risks
- P0/P1/P2 next steps
- Agent Teams summary (if any)
- Discoveries and decisions

### 2.2 Search Memory MCP

```
mcp__memory__search_nodes with query: "{session_id}"
```

Then open the entity:
```
mcp__memory__open_nodes with names: ["{session_id}"]
```

Extract all observations -- goals, learnings, decisions, patterns used.

### 2.3 Search for Related Decision Entities

```
mcp__memory__search_nodes with query: "{project_name}-decisions"
mcp__memory__search_nodes with query: "{project_name}-learnings"
```

### 2.4 Read Project Status

```bash
# Project-specific status
PROJECT_STATUS="$(pwd)/.claude/status.json"
if [ -f "$PROJECT_STATUS" ]; then
    cat "$PROJECT_STATUS"
fi
```

If in home directory (no specific project), check all projects:
```bash
for dir in ~/projects/*/; do
    if [ -f "$dir/.claude/status.json" ]; then
        echo "=== $(basename $dir) ==="
        jq '{project: .project, state: .currentState.summary, blockers: .blockers | length, p0: .nextSteps[0].description}' "$dir/.claude/status.json"
    fi
done
```

### 2.5 Check Active Plans

```bash
ls -t ~/.claude/plans/*.md 2>/dev/null | head -5
```

Read any active plans for incomplete work.

### 2.6 Git State (if in a repo)

```bash
git branch --show-current 2>/dev/null
git status -s 2>/dev/null | wc -l
git log --oneline -3 2>/dev/null
git stash list 2>/dev/null
```

**FAIL MODE:** Skip any source that fails, note it as unavailable.

---

## Phase 3: Learning Review [10 seconds]

Review what worked and what didn't from recent sessions.

### 3.1 Read Success Patterns

```bash
cat ~/.claude/patterns/success_patterns.json
```

Identify:
- Patterns with `usageCount >= 3` (proven)
- Recently added patterns (relevant to current work)
- Patterns relevant to the upcoming P0 task

### 3.2 Read Failure Patterns

```bash
cat ~/.claude/patterns/failure_patterns.json
```

Identify:
- Anti-patterns with `occurrenceCount >= 2` (recurring)
- Critical severity items (must avoid)
- Anti-patterns relevant to the upcoming P0 task

### 3.3 Check Routing Calibration

```bash
# Recent calibration changes
cat ~/.claude/routing/calibration-history.json 2>/dev/null | jq '.calibrations[-3:]'
```

### 3.4 Extract Learning Loop Output from Previous Session

From the handover file, pull the "Learnings" and "Discoveries" sections.
From Memory MCP observations, pull any entries starting with "Learning:" or "Decision:".

**Synthesize into:**
```markdown
## Recent Learnings (Last 3 Sessions)

### Apply This Session
- [Learning directly relevant to P0 task]
- [Anti-pattern to watch for]

### Good Habits to Continue
- [Proven pattern with high usage count]

### Mistakes to Avoid
- [Critical anti-pattern relevant to current context]
```

---

## Phase 4: Health Assessment [3 seconds]

Quick health check of the current state.

### 4.1 Previous Session Health

From handover: health score, level, and any warnings.

### 4.2 Current Environment Health

| Check | Method | Healthy |
|-------|--------|---------|
| Git clean | `git status -s \| wc -l` | 0 uncommitted |
| On correct branch | `git branch --show-current` | main or expected feature branch |
| No stale stashes | `git stash list` | Empty or documented |
| Tests passing | Last known test state from handover | All green |
| No blockers | From status.json | blockers = [] |
| MCP servers | Session startup hook output | All loaded |

### 4.3 Assess Overall Readiness

```
Ready: All checks pass, clear P0, no blockers
Caution: Minor issues (uncommitted files, stale stash)
Blocked: Active blockers, failing tests, broken build
```
