---
name: team-deploy
description: Repeatable Agent Teams deployment with context preparation, template selection, task generation, shared memory, and graceful shutdown. Triggers on "create a team", "spawn a team", "agent team for", "parallel agents", "/team-deploy".
argument-hint: [project-type] [--template=NAME] [--teammates=N]
allowed-tools: Read, Write, Bash, Glob, Grep, Task, TaskCreate, TaskUpdate, TaskList, TeamCreate, SendMessage
metadata:
  version: 1.0.0
  author: odedbe
---

# Team Deploy - Repeatable Agent Teams Deployment

**Purpose**: Standardized process for spinning up Agent Teams with proper context, task generation, shared memory, and shutdown protocol. Prevents ad-hoc team creation that leads to wasted context and poor coordination.

**Flow**: Context Prep -> Template Select -> Team Create -> Task Generate -> Shared Memory -> Monitor -> Shutdown

---

## Quick Reference

| Mode | Behavior | Use When |
|------|----------|----------|
| Default | Full 6-step deployment | Normal team creation |
| `--template=NAME` | Skip selection, use named template | Known team type |
| `--teammates=N` | Override template teammate count | Smaller/larger team needed |

---

## Step 1: Context Preparation [15 seconds]

Generate a team-context.md briefing from the current session state.

### 1.1 Gather Context

Read all relevant sources in parallel:

```bash
# Project state
cat "$(pwd)/.claude/status.json" 2>/dev/null
git branch --show-current 2>/dev/null
git status -s 2>/dev/null | wc -l

# Recent session
ls -t ~/.claude/session-index.json 2>/dev/null
```

### 1.2 Generate team-context.md

Use the template from `references/context-template.md` to create:

```
~/.claude/teams/{team-name}/team-context.md
```

Fill in:
- **Goal**: What the team needs to accomplish (from user request)
- **Current State**: Git branch, uncommitted changes, test status
- **Key Files**: Files relevant to the task (from Grep/Glob)
- **Decisions Made**: Architectural decisions from this session
- **Constraints**: File ownership boundaries, no shared file edits, Rule 13 (Opus 4.6)

### 1.3 Validate Context

Before proceeding, verify:
- [ ] Goal is specific and measurable
- [ ] Key files are listed (not "TBD")
- [ ] Constraints include file ownership boundaries

**FAIL MODE**: If context is too vague, ask user for clarification. Do NOT proceed with incomplete context.

---

## Step 2: Template Selection [5 seconds]

Pick the right team composition from `~/.claude/rules/team-templates.md`.

### 2.1 Match Project Type

| Project Type | Template | Teammate Count |
|--------------|----------|----------------|
| Pipeline/processing | QC Analyzer: Pipeline Team | 4 |
| Research + build | Sentimark: Research + Implement | 3 |
| Content/compliance | Compliance: Review Team | 3 |
| UI/frontend | Frontend: Design + Build | 3 |
| Debugging/investigation | General: Parallel Investigation | 3 |
| LLM/chatbot/RAG | LLM Agent App: Build Team | 3 |

### 2.2 Customize Template

Adapt the template to the specific task:
- Remove unnecessary teammates (stay under max 4)
- Assign specific file ownership (no overlap)
- Map MCP tools to actual needs
- Ensure all teammates use Opus 4.6 (Rule 13)

### 2.3 Present for Approval

```markdown
## Proposed Team: {team-name}

| Teammate | Role | Owns | MCP Tools |
|----------|------|------|-----------|
| {name} | {role} | {files} | {tools} |

**Template base**: {template-name}
**Customizations**: {what changed}

Approve? [Yes / Modify / Cancel]
```

**MANDATORY**: Wait for user approval before creating the team.

---

## Step 3: Team Creation [10 seconds]

Spawn the team with prepared context.

### 3.1 Create Team Directory

```bash
mkdir -p ~/.claude/teams/{team-name}
```

### 3.2 Write Context File

Copy the generated `team-context.md` into the team directory.

### 3.3 Spawn Teammates

For each teammate in the approved composition:
- Include team-context.md content in their initial prompt
- Specify file ownership boundaries
- Reference relevant patterns from the codebase
- Enforce Rule 13: "Use Opus 4.6 for all work"

### 3.4 Verify Spawn

Confirm each teammate is active and has acknowledged their assignment.

---

## Step 4: Task Generation [10 seconds]

Create 5-6 tasks per teammate (Anthropic best practice for Agent Teams).

### 4.1 Decompose Work

For each teammate, break their assignment into 5-6 discrete tasks:

```
TaskCreate for each:
- subject: Clear, imperative action ("Implement X in file Y")
- description: Acceptance criteria, file paths, patterns to follow
- activeForm: Present continuous ("Implementing X")
```

### 4.2 Set Dependencies

Use `addBlockedBy` / `addBlocks` for sequential dependencies:
- Planning tasks block implementation tasks
- Implementation tasks block review tasks
- Shared module changes block consumers

### 4.3 Assign Ownership

```
TaskUpdate for each:
- owner: {teammate-name}
- status: pending (first task per teammate can be in_progress)
```

### 4.4 Task Quality Check

Each task must have:
- [ ] Specific file(s) to modify
- [ ] Clear acceptance criteria
- [ ] No file overlap with other teammates' tasks
- [ ] Reasonable scope (completable in one focused session)

---

## Step 5: Shared Memory Setup [5 seconds]

Create the team's shared memory file for cross-teammate coordination.

### 5.1 Create Shared Memory

```bash
# Create team memory file
cat > ~/.claude/teams/{team-name}/team-memory.md << 'EOF'
# Team Memory: {team-name}

Created: {ISO timestamp}
Goal: {team goal from context}

## Shared Decisions

<!-- Each agent appends decisions here -->

## Agent: {teammate-1-name}

<!-- Findings and progress appended at checkpoints and shutdown -->

## Agent: {teammate-2-name}

<!-- Findings and progress appended at checkpoints and shutdown -->

## Agent: {teammate-3-name}

<!-- Findings and progress appended at checkpoints and shutdown -->
EOF
```

### 5.2 Instruct Teammates

Each teammate should be told:
- Read `~/.claude/teams/{team-name}/team-memory.md` at startup
- Append findings to their `## Agent: {name}` section at checkpoints
- Write final summary at shutdown
- Check "Shared Decisions" section before making architectural choices

---

## Step 6: Graceful Shutdown Protocol

Follow `references/shutdown-protocol.md` when the team's work is complete.

### 6.1 Trigger Conditions

Shutdown when:
- All tasks are marked completed
- Lead decides work is sufficient
- User requests team shutdown
- Rate limit or cost threshold reached

### 6.2 Shutdown Sequence

1. **Notify all teammates** — broadcast shutdown intent
2. **Wait for acknowledgment** — each teammate writes final findings to team-memory.md
3. **Collect artifacts** — gather all files created/modified by each teammate
4. **Merge findings** — lead synthesizes team-memory.md into actionable summary
5. **Update project state** — write findings to project `status.json` and `decisions.log`
6. **Archive team directory** — team-memory.md persists for future reference
7. **Send shutdown requests** — use `shutdown_request` for each teammate

### 6.3 Post-Team Handover

After shutdown, the lead must:
- Update `{project}/.claude/status.json` with team findings
- Append decisions to `{project}/.claude/decisions.log`
- Include team summary in next `/end-of-session` handover

---

## Error Recovery

| Failure | Recovery |
|---------|----------|
| Teammate fails to spawn | Redistribute their tasks to remaining teammates |
| Task stuck > 15 min | Lead investigates, reassigns or simplifies |
| File conflict between teammates | Immediately reassign file ownership, one teammate yields |
| Rate limit hit | Pause lowest-priority teammate, continue with others |
| Context too large | Summarize team-memory.md, prune old entries |

---

## Integration

| Skill/Rule | Connection |
|------------|------------|
| `team-templates.md` | Source of team compositions (Step 2) |
| `orchestration-patterns.md` | Parallel execution rules, iteration limits |
| `/end-of-session` | Team findings flow into session handover |
| `/go` | Previous team findings available via team-memory.md |
| `status.json` | Updated with team results at shutdown |
| `decisions.log` | Architectural decisions from team appended |
| `google-developer-knowledge` | GCP/Firebase docs for research teammates |

---

## Rule Enforcement

- **Rule 1**: No mock data — teammates use real files and real test results
- **Rule 2**: No claiming "done" without proof — TaskCompleted hook enforces
- **Rule 12**: Present team composition for approval before spawning
- **Rule 13**: ALL teammates use Opus 4.6 — enforced in spawn instructions

---

## Anti-Patterns

1. **Don't create teams for simple tasks** — single-file changes don't need 3 agents
2. **Don't skip context preparation** — vague context = wasted agent turns
3. **Don't let teammates share files** — file conflicts waste tokens resolving merges
4. **Don't create more than 4 teammates** — cost and rate limits degrade performance
5. **Don't skip the shutdown protocol** — orphaned agents waste resources
6. **Don't nest teams** — teammates cannot spawn their own teams
