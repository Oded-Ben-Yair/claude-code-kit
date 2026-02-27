# Team Shutdown Protocol

Checklist for gracefully shutting down an Agent Team and preserving all findings.

---

## Pre-Shutdown Checklist

Before initiating shutdown, verify:

- [ ] All critical tasks are completed (check TaskList)
- [ ] No teammate is mid-edit on a file
- [ ] Test results are captured (pass/fail counts)
- [ ] No uncommitted changes in any teammate's files

---

## Shutdown Sequence

### 1. Broadcast Intent [1 minute]

```
SendMessage type: broadcast
content: "Team shutdown initiated. All teammates: write final findings to team-memory.md within 2 minutes."
```

### 2. Collect Final Findings [2 minutes]

Each teammate must append to `~/.claude/teams/{team-name}/team-memory.md`:

```markdown
## Agent: {name} - Final Report

### Completed
- {Task 1}: {outcome}
- {Task 2}: {outcome}

### Files Created/Modified
- `{file-path}`: {change description}

### Test Results
- {X} tests passing, {Y} failing

### Unfinished Work
- {Task/subtask}: {what remains, how to continue}

### Discoveries
- {Anything learned that affects other teammates or future work}
```

### 3. Verify Completeness [1 minute]

Lead checks team-memory.md has entries from ALL teammates:

```bash
grep "## Agent:" ~/.claude/teams/{team-name}/team-memory.md | wc -l
# Must match teammate count
```

### 4. Send Shutdown Requests [30 seconds]

For each teammate:

```
SendMessage type: shutdown_request
recipient: {teammate-name}
content: "Work complete. Please approve shutdown."
```

Wait for each teammate to respond with `shutdown_response approve: true`.

### 5. Synthesize Findings [2 minutes]

Lead creates a summary from team-memory.md:

```markdown
## Team Summary: {team-name}

### Goal
{Original goal from team-context.md}

### Outcome
{ACHIEVED / PARTIAL / BLOCKED}

### Key Results
1. {Result 1}
2. {Result 2}
3. {Result 3}

### Files Changed
| File | Teammate | Change |
|------|----------|--------|
| {path} | {name} | {description} |

### Decisions Made
- {Decision}: {rationale}

### Remaining Work
- {What's left, if anything}

### Learnings
- {What worked well in team coordination}
- {What to do differently next time}
```

### 6. Update Project State [1 minute]

```bash
# Update status.json
jq --arg summary "{team summary}" \
   --arg date "$(date -Iseconds)" \
   '.currentState.summary = $summary | .currentState.lastModified = $date' \
   "$(pwd)/.claude/status.json" > "$(pwd)/.claude/status.json.tmp" && \
   mv "$(pwd)/.claude/status.json.tmp" "$(pwd)/.claude/status.json"
```

Append to decisions.log:
```
[{date}] TEAM: {team-name} — {goal}. Outcome: {ACHIEVED/PARTIAL/BLOCKED}. Key decisions: {list}.
```

### 7. Archive [30 seconds]

The team directory `~/.claude/teams/{team-name}/` persists after shutdown:
- `team-context.md` — original context
- `team-memory.md` — all findings and final reports

These are available for future sessions via `/go` context recovery.

---

## Emergency Shutdown

When a team must stop immediately (rate limit, user abort, critical error):

1. Skip steps 1-2 (no time for final findings)
2. Send `shutdown_request` to all teammates immediately
3. Save whatever is in team-memory.md as-is
4. Note in status.json: "Emergency shutdown — team-memory.md may be incomplete"
5. List all uncommitted changes for manual review

---

## Post-Shutdown Verification

After all teammates confirm shutdown:

- [ ] All `shutdown_response` received with `approve: true`
- [ ] team-memory.md has entries from all teammates
- [ ] status.json updated with team results
- [ ] decisions.log has team entry
- [ ] No orphaned background processes
- [ ] Git status clean (all teammate changes committed)
