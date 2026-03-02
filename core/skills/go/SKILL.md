---
name: go
description: Resume from last session with full context recovery, status briefing, and auto-planned action plan. Triggers on "go", "let's go", "where were we", "continue", "/go".
argument-hint: [project-name] [--skip-plan] [--session-id=ID]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(ls:*), Bash(jq:*), Bash(basename:*), Bash(date:*), Bash(wc:*), mcp__memory__*
metadata:
  version: "1.1.0"
  author: odedbe
---

# Go — Full Context Recovery + Auto-Plan

**The counterpart to `/end-of-session`.** This skill recovers ALL context from the previous session and auto-generates an orchestrated action plan for the next steps.

**Flow**: Recover Context -> Briefing -> Auto-Plan -> User Gate -> Document

---

## Quick Reference

| Mode | Behavior | Use When |
|------|----------|----------|
| Default | Full 7-phase recovery + auto-plan | Normal session start |
| `--skip-plan` | Phases 1-5 only (briefing, no plan) | Just want status, will direct manually |
| `--session-id=ID` | Resume specific session | Not the most recent one |
| `[project-name]` | Resume specific project | Working across multiple projects |

---

## Phase 1: Locate Previous Session [5 seconds]

Find the most recent session to resume from.

### 1.1 Determine Target

**If `--session-id=ID` provided:**
- Use that specific session ID

**If `[project-name]` provided:**
- Filter session-index.json for that project, take most recent

**If no arguments (default):**
- Check current directory for project match
- Fall back to most recent session in index

### 1.2 Read Session Index

**IMPORTANT: Use the Read tool to read `~/.claude/session-index.json` directly — NEVER use `cat | python3` (file is 80KB+, python one-liners fail on it).**

Use the **Read tool** to read `~/.claude/session-index.json`, then parse the JSON yourself to find:
- The most recent session matching the target project
- Sort by `.date` descending, take first match

If you need to filter by project, use jq via Bash:
```bash
jq -r --arg proj "PROJECT_NAME" '.sessions | map(select(.project == $proj)) | sort_by(.date) | reverse | .[0]' ~/.claude/session-index.json
```

Extract from the session entry:
- `session_id` - for Memory MCP lookup
- `handover_path` - for detailed handover
- `project_path` - for navigation
- `health_score` - for health context
- `p0_next` - for immediate priority

### 1.3 Find Handover File

Use **Glob tool** to find handover files (not `ls`):
1. Pattern: `{project_path}/.claude/handover-*.md` (project-specific)
2. Pattern: `~/.claude/handover-*.md` (global)
3. Fall back to `handover_path` from session index entry

**FAIL MODE:** If no handover found, search Memory MCP directly. If neither exists, inform user and ask for manual context.

---

## Phases 2-4: Context Recovery, Learning Review, Health Assessment

Read `references/recovery-phases.md` for the full details of:
- **Phase 2**: Context Recovery [10 seconds] -- Read handover, Memory MCP, project status, active plans, git state
- **Phase 3**: Learning Review [10 seconds] -- Review success/failure patterns, routing calibration, extract learnings
- **Phase 4**: Health Assessment [3 seconds] -- Previous session health, current environment health, overall readiness

---

## Phase 5: Status Briefing [Present to User]

**Output a clear, simple briefing:**

```markdown
=== SESSION RESUME BRIEFING ===

Previous Session: {session_id}
Date: {date} | Health: {score}/100 ({level})
Project: {project_name} ({project_path})

--- WHAT WE DID ---
1. [Goal 1] - COMPLETE (100%)
2. [Goal 2] - PARTIAL (60%) - {reason}
3. [Goal 3] - BLOCKED - {blocker}

--- WHAT WE LEARNED ---
+ [Key success/discovery from last session]
+ [Another learning]
! [Anti-pattern to watch for]

--- WHERE WE STAND ---
Git: {branch} | {uncommitted} uncommitted | Last push: {status}
Tests: {pass}/{total} | Build: {status}
Blockers: {count} active

--- WHAT'S NEXT (from handover) ---
P0: {highest priority task}
P1: {second priority}
P2: {nice to have}

--- ENVIRONMENT ---
MCP Servers: {loaded list}
Active Plans: {plan names if any}
Health Alerts: {from session startup hook}
```

**IMPORTANT:** This briefing is presented BEFORE the auto-plan. User reads this first.

---

## Phases 6-7: Auto-Plan Generation + User Gate

Read `references/auto-plan.md` for the full details of:
- **Phase 6**: Auto-Plan Generation [15 seconds] -- Task decomposition, team composition, orchestration plan
- **Phase 7**: User Gate + Documentation -- Present plan for approval, document the plan, handle pivots

**Skip Phase 6-7 if `--skip-plan` was passed.**

---

## Graceful Degradation

| Phase | Failure | Recovery |
|-------|---------|----------|
| Phase 1 | No session index | Search for handover files by glob |
| Phase 1 | No handover files | Search Memory MCP for any SessionSummary entities |
| Phase 1 | Nothing found | Ask user for context manually |
| Phase 2 | Memory MCP down | Rely on handover file only |
| Phase 2 | No project status | Skip, note in briefing |
| Phase 3 | No pattern files | Skip learning review |
| Phase 4 | Not a git repo | Skip git checks |
| Phase 6 | Task too vague | Present options instead of plan |
| Phase 7 | status.json missing | Create it |

---

## Integration with Other Skills

| Skill | How It Connects |
|-------|----------------|
| `/end-of-session` | **Produces** the handover, memory entity, and session index that this skill **consumes** |
| `/learning-loop` | **Produces** the pattern files that Phase 3 reviews |
| `/session-prime` | This skill REPLACES session-prime for returning users. Use session-prime only for first-time project onboarding |
| `/pre-mortem` | Auto-triggered in Phase 6 if risk is High |
| `/fix-pipeline` | Referenced in plan if pipeline issues detected |
| `/multi-model-debate` | Referenced in plan if major architectural decision needed |

---

## Rule Enforcement

This skill enforces ALL rules from CLAUDE.md:

- **Rule 1**: NO mock data in briefing - all data from real sources
- **Rule 2**: NO claiming "ready" without reading actual files
- **Rule 11**: Understand before changing - read everything before planning
- **Rule 12**: Generate options, human decides - Phase 7 gate is mandatory
- **Rule 13**: ALL agents in plan use Opus 4.6

---

## Safety Rules

1. **Never auto-execute** - Always wait for user approval at Phase 7
2. **Never fabricate context** - Only report what's actually in handover/memory/files
3. **Never skip the briefing** - Even with `--skip-plan`, Phase 5 always runs
4. **Never modify code during resume** - This skill is READ-ONLY until user approves a plan
5. **Always document** - Even if user pivots, log the context recovery to Memory MCP

---

*Counterpart to `/end-of-session` v2. Together they form the session lifecycle.*
