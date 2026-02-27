# Orchestration Patterns (Extracted from Orchestrator Skill)

Load when: complex task, multi-step, orchestrate, plan and implement

## 3-Specialist Pattern: Planner → Implementer → Verifier

### Pre-Flight Analysis [5 sec]

Before planning, assess:
- Files likely affected (estimate)
- Risk level: Low/Medium/High
- Tests required: Yes/No
- Potential blockers

Skip orchestration for: single-file changes, pure bug fixes, config updates, "quick fix"/"#urgent" tasks.

### Flow

1. **Context Gathering**: Use Grep/Glob/Read to understand the relevant codebase before planning. Search for patterns, read key files, trace dependencies.
2. **Planner** (architect-planner): Decompose into max 7 steps, identify files, define acceptance criteria
2. **GATE**: Present plan to user — do NOT proceed without explicit approval
3. **Implementer** (code-worker): Execute each step following existing patterns, NO mock data
4. **Verifier** (code-judge): Check acceptance criteria, tests, security, patterns
5. **Iteration**: If FAIL/NEEDS_CHANGES → back to Implementer (max 3 retries)
6. **Escalation**: After 3 failures → human decision point

### With Agent Teams (Preferred)

```
"Create a team: architect plans while researcher investigates. After planning,
 2 code-workers implement in parallel. code-judge reviews at the end."
```

Teammates can work in parallel on independent steps (no shared files, no data dependencies).

### Checkpoint Protocol

Write to `status.json` after each step:
- `checkpoint.step_index`: Current step
- `checkpoint.total_steps`: Total steps
- `checkpoint.phase`: planning/implementing/verifying
- `checkpoint.resumable`: true

At session start, check for incomplete checkpoints and offer resume.

### Iteration Limits

- Max 3 retries per step before human escalation
- Max 3 escalations per step to specialist agents
- Max 10 escalations per orchestration
- Max 5 parallel agents for independent steps

### Parallel Execution Rules

Steps are independent if:
- No shared files
- No data dependencies
- No sequential ordering requirement

If merge conflicts during parallel work → revert to sequential.

### Telemetry

Log to `~/.claude/telemetry/orchestration-{date}.jsonl`:
- Step start/complete
- Escalations
- Verification results
- Errors/retries

### NEVER

- Proceed without user approval at plan gates
- Skip pre-mortem for High/Critical risk
- Allow scope creep during implementation (use /ship-it)
- Trust "it works in dev" for production changes
- Declare "complete" without proof
- Use mock data in any phase

## Team Shared Memory Protocol

### Location

```
~/.claude/teams/{team-name}/team-memory.md
```

Created by the lead during team deployment (see `/team-deploy` skill, Step 5).

### Structure

Each agent appends findings under their own section header:

```markdown
# Team Memory: {team-name}

Created: {ISO timestamp}
Goal: {team goal}

## Shared Decisions

<!-- Cross-team decisions that affect multiple teammates -->
- [{timestamp}] DECISION: {description} — by {agent-name}

## Agent: researcher

### Findings
- {finding 1}
- {finding 2}

### Files Modified
- `{path}`: {description}

## Agent: implementer

### Findings
- {finding 1}

### Files Modified
- `{path}`: {description}

## Agent: reviewer

### Findings
- {finding 1}
```

### Read/Write Protocol

- **Read at startup**: Each teammate reads team-memory.md before starting work to understand what others have found.
- **Write at checkpoints**: After completing each major subtask, append progress to your section.
- **Write at shutdown**: Final report with all completed work, files modified, and remaining items.
- **Shared Decisions**: Any architectural choice that affects other teammates goes in the top-level "Shared Decisions" section, not individual agent sections.

### Persistence

- Team-memory.md persists in `~/.claude/teams/{team-name}/` after team shutdown.
- Future sessions can reference past team findings via `/go` context recovery.
- The lead synthesizes team-memory.md into `status.json` and `decisions.log` during shutdown.

### Conflict Prevention

- Each agent only writes to their own `## Agent: {name}` section.
- Only the lead writes to the `## Shared Decisions` section.
- If two agents discover conflicting information, the lead resolves via the Shared Decisions section.
