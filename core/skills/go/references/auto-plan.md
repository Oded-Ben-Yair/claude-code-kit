# Auto-Plan Generation + User Gate (Phases 6-7)

Detailed instructions for auto-plan generation, user approval gate, and documentation.

---

## Phase 6: Auto-Plan Generation [15 seconds]

**Skip if `--skip-plan` was passed.**

Take the P0/P1 next steps and generate a full orchestrated action plan.

### 6.1 Task Decomposition

For each P0/P1 task:
1. Assess complexity (files affected, risk level)
2. Determine if orchestration needed (3+ files = yes)
3. Identify optimal agent/skill/MCP for each subtask

### 6.2 Agent Team Composition

Based on the task type, propose a team from the templates in `~/.claude/rules/team-templates.md`:

```markdown
## Proposed Team

| Teammate | Role | Owns | Tools |
|----------|------|------|-------|
| {name} | {role} | {files} | {MCP tools} |
| ... | ... | ... | ... |

**Why this composition:** {rationale}
**Alternative:** {simpler approach if team is overkill}
```

### 6.3 Orchestration Plan

Follow the 3-Specialist Pattern from `~/.claude/rules/orchestration-patterns.md`:

```markdown
## Action Plan

### Pre-Flight
- Files affected: {estimate}
- Risk level: {Low/Medium/High}
- Tests required: {Yes/No}
- Pre-mortem needed: {Yes if High risk}

### Steps

| # | Step | Agent/Tool | Files | Acceptance Criteria |
|---|------|-----------|-------|---------------------|
| 1 | {step} | {agent} | {files} | {criteria} |
| 2 | {step} | {agent} | {files} | {criteria} |
| ... | ... | ... | ... | ... |

### Parallel Opportunities
- Steps {X} and {Y} can run in parallel (no shared files)

### Verification Plan
- [ ] {test to run}
- [ ] {visual check if UI}
- [ ] {pipeline check if deploy}

### Skills to Invoke
- {/skill-name} for {reason}

### MCP Tools Needed
- {mcp_tool} for {reason}

### Estimated Phases
1. Planning: {architect-planner}
2. Implementation: {code-worker / team}
3. Verification: {code-judge}
```

### 6.4 Alternative: User-Directed Mode

If the P0 tasks are unclear or the user might want something different:

```markdown
## Suggested Next Steps (Choose One)

**Option A: Continue from handover P0**
{P0 task with plan}

**Option B: Address blockers first**
{Blocker resolution plan}

**Option C: Something else**
Tell me what you'd like to work on instead.
```

---

## Phase 7: User Gate + Documentation [Wait for Input]

### 7.1 Present Plan for Approval

**MANDATORY**: Do NOT proceed without explicit user approval.

Present the briefing (Phase 5) and plan (Phase 6) together. Then ask:

```markdown
Ready to execute this plan?

1. **Approve** - Execute the plan as proposed
2. **Modify** - Tell me what to change
3. **Replace** - Ignore the plan, I'll tell you what I want
4. **Skip plan** - Just give me the briefing, I'll direct manually
```

### 7.2 Document the Plan

Regardless of user choice, save the session context:

**Update status.json:**
```bash
# If project has status.json, update it
jq --arg date "$(date -Iseconds)" \
   --arg prev_session "{session_id}" \
   --arg plan "{chosen_direction}" \
   '.sessionNotes.lastResumedFrom = $prev_session | .sessionNotes.currentPlan = $plan | .sessionNotes.lastSessionDate = ($date | split("T")[0])' \
   "$(pwd)/.claude/status.json" > "$(pwd)/.claude/status.json.tmp" && \
   mv "$(pwd)/.claude/status.json.tmp" "$(pwd)/.claude/status.json"
```

**Persist to Memory MCP:**
```
mcp__memory__add_observations:
  entityName: "{previous_session_id}"
  contents: ["Resumed in new session on {date}. Direction: {user_choice}"]
```

### 7.3 If User Provides Different Task

If the user says "I want to do X instead":
1. Acknowledge the pivot
2. Run the same orchestration planning (Phase 6) on the NEW task
3. Present the new plan for approval
4. Document: add observation to Memory MCP noting the pivot

---

## Example Output

```
=== SESSION RESUME BRIEFING ===

Previous Session: qc-call-analyzer-session-20260208-a1b2c3
Date: 2026-02-08 | Health: 85/100 (Good)
Project: qc-call-analyzer (~/projects/qc-call-analyzer)

--- WHAT WE DID ---
1. Fix Arabic speaker detection - COMPLETE (100%)
2. Add duration guard for long calls - COMPLETE (100%)
3. Deploy V7.1 to production - PARTIAL (80%) - pipeline pending

--- WHAT WE LEARNED ---
+ Language-aware text processing branches work (pattern-010)
+ Duration guard prevents timeout failures (pattern-009)
! Watch for: format string crashes on Arabic text (anti-006)

--- WHERE WE STAND ---
Git: main | 0 uncommitted | Last push: synced
Tests: 42/42 | Build: OK
Blockers: 0 active

--- WHAT'S NEXT ---
P0: Verify V7.1 pipeline completed and test production endpoint
P1: Add regression tests for Arabic 2-speaker calls
P2: Monitor V7.1 production for 24h

--- PROPOSED PLAN ---

Pre-Flight: Low risk, 2-3 files, tests required

| # | Step | Agent/Tool | Acceptance |
|---|------|-----------|------------|
| 1 | Check pipeline status | Bash (gh workflow) | Status: succeeded |
| 2 | Test production endpoint | code-worker | Real call processed correctly |
| 3 | Write regression tests | code-worker | 3+ Arabic test cases pass |
| 4 | Review test quality | code-judge | Coverage adequate |

No team needed - sequential steps, low complexity.

Ready to execute? [Approve / Modify / Replace / Skip]
```
