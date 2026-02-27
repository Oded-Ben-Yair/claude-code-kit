---
name: end-of-session
description: Perfect session continuation - Memory MCP persistence, session index, validation gate, and bulletproof handover. Ensures next session can resume with 100% context. Triggers on "end session", "close session", "wrap up", "done for today", "/end-of-session".
argument-hint: [--mode=quick|full|force] [--skip-git] [--skip-validation]
allowed-tools: Bash(git:*), Bash(ls:*), Bash(az:*), Bash(jq:*), Read, Write, Glob, Grep, mcp__memory__*
metadata:
  version: "1.0.0"
  author: odedbe
---

# End-of-Session v2 - Perfect Session Continuation

This skill ensures the next session can resume with **100% context** by:
1. Persisting session state to Memory MCP (searchable forever)
2. Generating a perfect handover with copy-paste ready next session prompt
3. Maintaining a session index for finding any session
4. Validating all persistence succeeded before closing

---

## Quick Reference

| Mode | Behavior | Use When |
|------|----------|----------|
| `--mode=full` | All 7 phases, validation gate | Normal session end (DEFAULT) |
| `--mode=quick` | Skip git push, minimal validation | Quick exit needed |
| `--mode=force` | Skip validation gate | "Just close, skip validation" |
| `--skip-git` | Skip Phase 5 | Known git issues |
| `--skip-validation` | Skip Phase 7 | Known MCP issues |

---

## Phase Execution (Follow In Order)

### Phase 1: Session Identity [2 seconds]

Generate unique session ID and capture metadata.

**Actions:**
1. Detect project from current directory
2. Generate session ID: `[project]-session-[YYYYMMDD]-[6-char-hash]`
3. Capture: current time, estimate duration from conversation

**Generate ID:**
```bash
# Get project name from directory
PROJECT_NAME=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
DATE_STR=$(date '+%Y%m%d')
HASH=$(echo "$$-$(date +%s)" | md5sum | cut -c1-6)
SESSION_ID="${PROJECT_NAME}-session-${DATE_STR}-${HASH}"
echo "Session ID: $SESSION_ID"
```

**FAIL MODE:** Generate minimal ID using timestamp only, continue.

---

### Phase 2: State Assessment [10 seconds]

Collect current technical state.

**Git State:**
```bash
# Branch and status
git branch --show-current
git status -s | wc -l  # uncommitted count
git log --oneline -1   # latest commit
git remote get-url azure 2>/dev/null || git remote get-url origin 2>/dev/null

# Remote status
git fetch --dry-run 2>&1 | head -5
```

**Technical State:**
- Check if tests exist and last run status
- Check build status if applicable
- Note any API limits encountered during session

**Files Modified:**
```bash
git diff --name-only HEAD~5 2>/dev/null | head -20
```

**Agent Teams State:**
```bash
# Check if Agent Teams were active this session
if [[ -n "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-}" ]]; then
    echo "Agent Teams: ENABLED"
    # Note: Teams don't persist across sessions — capture state for handover
fi
```

**FAIL MODE:** Skip missing items, note "Unable to assess [item]" in report.

---

### Phase 3: Achievement Analysis [15 seconds]

Extract goals and progress from conversation context.

**Actions:**
1. Review conversation for stated goals (user requests)
2. Identify completed vs incomplete items
3. Calculate completion percentage per goal
4. Extract blockers encountered
5. Identify key learnings/decisions

**Output Format:**
```
Goals Identified:
1. [Goal description] - [COMPLETE/PARTIAL/BLOCKED] ([X]%)
2. [Goal description] - [COMPLETE/PARTIAL/BLOCKED] ([X]%)

Blockers:
- [Blocker if any]

Learnings:
- [Key insight from session]

Agent Teams:
- Team composition: [list teammates if teams were used]
- Each teammate: [what they accomplished]
- Coordination notes: [any issues or successes in team coordination]
```

**FAIL MODE:** Prompt user: "Please summarize your main goals and what was accomplished."

---

### Phase 3.5: Learning Loop Integration [10 seconds] - NEW

Extract learnings and update pattern files for continuous improvement.

**Actions:**

1. **Extract Session Learnings:**
```markdown
## Session Learnings

### What Worked Well
- [Pattern/approach that succeeded]
- [Tool/MCP that was particularly effective]

### What Failed
- [Pattern/approach that failed]
- [Why it failed]
- [How to avoid next time]

### Decisions Made
- [Key decision]
- [Rationale]

### Patterns Discovered
- [New pattern worth capturing]
```

2. **Update Success Patterns** (`~/.claude/patterns/success_patterns.json`):
   - If a pattern was used successfully, increment `usageCount`
   - If a new success pattern discovered, propose adding it
   - Use script: `python ~/.claude/scripts/update-patterns.py increment --type success --id [pattern-id]`

3. **Update Failure Patterns** (`~/.claude/patterns/failure_patterns.json`):
   - If an anti-pattern occurred, increment `occurrenceCount`
   - If a new failure pattern discovered, propose adding it
   - Use script: `python ~/.claude/scripts/update-patterns.py increment --type failure --id [anti-id]`

4. **Update Project Status** (if project has `.claude/status.json`):
```bash
PROJECT_STATUS="$(pwd)/.claude/status.json"
if [ -f "$PROJECT_STATUS" ]; then
    # Update with current state using jq
    jq --arg date "$(date -Iseconds)" \
       --arg health "$HEALTH_SCORE" \
       '.lastUpdated = $date | .healthHistory += [($health | tonumber)]' \
       "$PROJECT_STATUS" > "$PROJECT_STATUS.tmp" && mv "$PROJECT_STATUS.tmp" "$PROJECT_STATUS"
fi
```

5. **Propose Policy Updates** (Human-Gated):
   - If success pattern used 10+ times, propose promotion to rules
   - If failure pattern occurred 5+ times, propose warning in rules
   - **NEVER auto-apply** - always present for user approval

**Example Pattern Update Proposal:**
```markdown
### Proposed Policy Update

Based on session learnings, I recommend:

**Success Pattern Promotion** (pattern-001: Pattern-First Development)
- Usage count: 12 times
- Success rate: 100%
- Propose: Add to `~/.claude/rules/code-quality.md`

**Approve?** [User must confirm]
```

**FAIL MODE:** Skip pattern updates, continue with Memory MCP persistence.

---

### Phase 4: Memory MCP Persistence [5 seconds] - CRITICAL

Persist session state to Memory MCP for cross-session retrieval.

**Create Session Entity:**
```
Use mcp__memory__create_entities with:

Entity Name: [session_id]
Entity Type: SessionSummary
Observations (array of strings):
- "Session Date: [ISO timestamp]"
- "Project: [project_name]"
- "Project Path: [absolute_path]"
- "Duration: [X] minutes (estimated)"
- "Health Score: [calculated]/100 ([level])"
- "Goal 1: [description] - [STATUS]"
- "Goal 2: [description] - [STATUS]"
- ... (all goals)
- "Files Modified: [file1], [file2], ..."
- "Blocker: [blocker description]" (if any)
- "Learning: [key insight]" (if any)
- "Decision: [decision summary] (linked: [entity-name])" (if any)
- "Success Pattern Used: [pattern-id] - [pattern-name]" (if any)
- "Failure Pattern Avoided: [anti-id] - [anti-name]" (if any)
- "New Learning: [what was learned this session]" (if any)
- "P0 Next: [highest priority next step]"
- "P1 Next: [second priority]" (if any)
- "Handover: [handover_file_path]"
```

**Link to Existing Decisions:**
If architectural decisions were made during session, create relations:
```
mcp__memory__create_relations linking session to decision entities
```

**FAIL MODE:**
1. Save to local file: `~/.claude/session-memory/pending-[session_id].json`
2. Log: "Memory MCP unavailable - saved locally for retry"
3. Continue with remaining phases

---

### Phase 5: Git Operations [30 seconds max] - OPTIONAL

Commit and push changes to GitHub.

**Pre-check:**
```bash
# Check for uncommitted changes
UNCOMMITTED=$(git status -s | wc -l)
if [ "$UNCOMMITTED" -eq 0 ]; then
    echo "No uncommitted changes"
    # Skip to Phase 6
fi
```

**If changes exist:**
1. Show diff summary to user
2. Ask for commit confirmation
3. Create commit:
```bash
git add --all -- ':!.env' ':!.env.*' ':!*.key' ':!*.pem' ':!.secrets' ':!credentials*'
git commit -m "$(cat <<'EOF'
chore: session [session_id] - [brief summary]

Goals: [completed_count]/[total_count] completed
Health: [score]/100

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```

4. Push to GitHub:
```bash
git push azure $(git branch --show-current) --timeout=30
```

**IMPORTANT:**
- Never push to GitHub - GitHub only
- Verify remote is azure before pushing
- Timeout after 30 seconds

**FAIL MODE:** Log failure, continue, add "Git push pending - run `git push azure [branch]`" to handover.

---

### Phase 6: Handover Generation [5 seconds]

Generate perfect handover file from template.

**File Location:** `[project]/.claude/handover-[YYYYMMDD]-[hash].md`

**Template:** Use `~/.claude/skills/end-of-session/templates/handover-v2.md`

**Required Sections:**
1. Session Identity (ID, date, duration, health score)
2. Memory MCP Reference (entity name for retrieval)
3. Goals & Achievement (with % completion)
4. Technical State (git, tests, build)
5. Key Files Modified
6. Blockers & Risks
7. Agent Teams Summary (if teams were active: composition, task ownership, findings)
8. P0/P1/P2 Next Steps
9. **Next Session Prompt** (CRITICAL - copy-paste ready)

**Create project .claude directory if needed:**
```bash
mkdir -p "$(pwd)/.claude"
```

**FAIL MODE:** Output full handover content to console instead of file.

---

### Phase 7: Validation Gate [3 seconds] - CRITICAL

Verify all persistence succeeded before allowing close.

**Validation Checks:**
1. **Memory MCP Entity Exists:**
   - Search for session_id in Memory MCP
   - Must find entity with matching name

2. **Handover File Readable:**
   - File exists at expected path
   - File is not empty

3. **Session Index Updated:**
   - `~/.claude/session-index.json` contains new entry
   - Entry has all required fields

**Update Session Index:**
```bash
# Read existing or create new
INDEX_FILE="$HOME/.claude/session-index.json"
if [ ! -f "$INDEX_FILE" ]; then
    echo '{"version":"1.0.0","sessions":[],"stats":{"total_sessions":0,"avg_health_score":0}}' > "$INDEX_FILE"
fi

# Add new session entry using jq
jq --arg id "$SESSION_ID" \
   --arg date "$(date -Iseconds)" \
   --arg project "$PROJECT_NAME" \
   --arg path "$(pwd)" \
   --arg handover "$HANDOVER_PATH" \
   --arg health "$HEALTH_SCORE" \
   --arg p0 "$P0_NEXT" \
   '.sessions += [{
     "session_id": $id,
     "date": $date,
     "project": $project,
     "project_path": $path,
     "handover_path": $handover,
     "memory_entity": $id,
     "health_score": ($health | tonumber),
     "p0_next": $p0
   }] | .stats.total_sessions += 1' "$INDEX_FILE" > "$INDEX_FILE.tmp" && mv "$INDEX_FILE.tmp" "$INDEX_FILE"
```

**Generate Session Close Receipt:**
```
=== Session Close Receipt ===

[x] Memory MCP entity created: [session_id]
[x] Handover file written: [handover_path]
[x] Session index updated: [total] sessions
[x/!] Git pushed: [YES/NO/PENDING]

Validation: [PASSED/FAILED]

Session [session_id] closed at [timestamp]
```

**FAIL MODE:**
- If any check fails AND mode is NOT `--force`:
  - Display which checks failed
  - Provide remediation steps
  - BLOCK session close
- If `--force` mode: Log failures, close anyway

---

## Health Score Calculation

Calculate session health score (0-100):

| Criterion | Points | Condition |
|-----------|--------|-----------|
| Base | 50 | Starting score |
| Goal achieved | +10 | Per completed goal |
| Clean git | +10 | All changes committed & pushed |
| Tests passing | +5 | No failing tests |
| Build OK | +5 | No build errors |
| No blockers | +5 | Session ended without blockers |
| Memory persisted | +5 | Entity created successfully |
| Goal incomplete | -5 | Per incomplete goal |
| Uncommitted | -10 | Dirty git state |
| Push failed | -5 | Changes not on remote |
| Tests failing | -10 | Failing tests remain |
| Build broken | -15 | Build errors at end |

**Health Levels:**
| Score | Level | Meaning |
|-------|-------|---------|
| 90-100 | Excellent | Session completed perfectly |
| 75-89 | Good | Minor issues, safe to continue |
| 60-74 | Acceptable | Some gaps, review before next session |
| 40-59 | Needs Attention | Significant issues to address |
| 0-39 | Critical | Session ended poorly, prioritize fixes |

---

## Graceful Degradation

| Phase | Failure | Recovery Action |
|-------|---------|-----------------|
| Phase 1 | Can't detect project | Use "unknown-session-[timestamp]" |
| Phase 2 | Git unavailable | Note "Not a git repo", continue |
| Phase 3 | Can't extract goals | Ask user for manual summary |
| Phase 3.5 | Pattern update fails | Skip learning loop, continue |
| Phase 4 | Memory MCP down | Save to local pending file |
| Phase 5 | Git push fails | Log and continue, note in handover |
| Phase 6 | File write fails | Output to console |
| Phase 7 | Validation fails | BLOCK unless --force |

---

## Output Example

```
=== End of Session Report ===

Session ID: automation-fabric-session-20260115-a1b2c3
Duration: 2h 25m | Health: 85/100 (Good)

Goals:
  [x] Implement Grok wrapper (100%)
  [x] Add unit tests (100%)
  [ ] Deploy to Azure (0%) - BLOCKED: Secret Manager access

Technical:
  Git: main | Pushed: YES | Clean: YES
  Tests: 35/35 | Build: OK

Persisted:
  Memory: automation-fabric-session-20260115-a1b2c3
  Handover: .claude/handover-20260115-a1b2c3.md
  Index: 48 total sessions

Validation: PASSED

Next Session P0: Get Secret Manager access from admin

Session closed successfully.
```

---

## Related Commands

- `/go` - **Counterpart**: Recover context + auto-plan at session start
- `/list-sessions` - Browse session index, filter by project/date/health
- `/session-health` - Check current session health mid-session

---

## Safety Rules

1. **Never auto-delete** - Only report issues, let user decide
2. **Never push to GitHub** - GitHub only
3. **Confirm before commits** - Show diff summary first
4. **Validate before close** - Block if persistence failed (unless --force)
5. **Graceful degradation** - Always produce some output even if phases fail
6. **Teams don't persist** - Agent Teams state is lost between sessions. Always capture team composition, task assignments, and findings in the handover document.
