---
name: orchestrator
description: Silent Kernel orchestration - Planner → Implementer → Verifier flow with iteration loops. Triggers on "orchestrate", "complex task", "plan and implement", "/orchestrator".
argument-hint: [task description]
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, mcp__memory__*
schemas:
  handoff: "~/.claude/schemas/agent-handoff.json"
  checkpoint: "~/.claude/schemas/execution-checkpoint.json"
  telemetry: "~/.claude/schemas/routing-telemetry.json"
version: "2.0.0"
---

# Silent Kernel Orchestrator

**Purpose**: Orchestrate complex tasks through the 3-specialist pattern with automatic iteration.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    ORCHESTRATOR (Claude)                     │
│  - Task analysis and routing                                │
│  - State management via Ledger (status.json)                │
│  - Iteration control (max 3 retries)                        │
└─────────────────────────┬───────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│   PLANNER     │ │  IMPLEMENTER  │ │   VERIFIER    │
│ (architect-   │ │ (code-worker) │ │ (code-judge)  │
│  planner)     │ │               │ │               │
│               │ │               │ │               │
│ - Decompose   │ │ - Write code  │ │ - Run tests   │
│ - Plan docs   │ │ - Edit files  │ │ - Code review │
│ - Clarify     │ │ - No mock!    │ │ - Simplify    │
└───────────────┘ └───────────────┘ └───────────────┘
```

---

## When to Use

- Complex tasks touching 3+ files
- New feature implementation
- Architecture changes
- Refactoring with test requirements

---

## Flow Protocol

### Step 1: Pre-Flight Analysis [5 sec]

**Shadow Verification** - Before planning, identify risks:

```markdown
## Pre-Flight Analysis

**Task**: [User's request]

**Complexity Assessment**:
- Files likely affected: [estimate]
- Risk level: [Low/Medium/High]
- Tests required: [Yes/No]

**Potential Blockers**:
- [Blocker 1 if any]

**Recommend Orchestration?** [Yes → proceed / No → direct implementation]
```

Skip orchestration for:
- Single-file changes
- Pure bug fixes
- Config updates
- Tasks with "quick fix" or "#urgent"

### Step 2: Planning Phase [PLANNER]

Invoke `architect-planner` agent:

```
Task: [User's request]

Requirements:
1. Decompose into steps (max 7)
2. Identify files to modify
3. Define acceptance criteria
4. Flag any clarification needs

Output Format:
{
  "plan_id": "plan-[timestamp]",
  "steps": [
    {
      "id": 1,
      "description": "...",
      "files": ["file1.ts", "file2.ts"],
      "acceptance": "...",
      "agent": "code-worker"
    }
  ],
  "clarifications_needed": []
}
```

**GATE**: If clarifications needed, ask user before proceeding.

### Step 3: Plan Approval

Present plan to user:

```markdown
## Proposed Plan

**Task**: [description]
**Steps**: [count]
**Files**: [list]
**Risk**: [level]

| # | Step | Files | Agent |
|---|------|-------|-------|
| 1 | ... | ... | ... |

**Approve this plan?** [Yes/Modify/Cancel]
```

**GATE**: Do NOT proceed without explicit approval.

### Step 4: Implementation Phase [IMPLEMENTER]

For each step in approved plan:

1. **Load Step Context**:
   - Read relevant files
   - Check for existing patterns
   - Load project status.json if exists

2. **Invoke `code-worker` agent**:
```
Step: [step description]
Files: [files to modify]
Acceptance Criteria: [from plan]

Rules:
- NO MOCK DATA - use real connections
- Follow existing patterns
- Write tests if acceptance requires
```

3. **Update Ledger**:
```json
// status.json update
{
  "currentState": {
    "stage": "implementing",
    "step": 1,
    "totalSteps": 5
  },
  "inProgress": ["step 1 description"]
}
```

### Step 5: Verification Phase [VERIFIER]

After each implementation step:

1. **Invoke `code-judge` agent**:
```
Review implementation of Step [N]:

Files changed: [list]
Acceptance criteria: [from plan]

Check:
1. Does it meet acceptance criteria?
2. Are there tests? Do they pass?
3. Any security issues?
4. Code quality (no smells)?
5. Does it follow existing patterns?

Output:
{
  "verdict": "PASS" | "FAIL" | "NEEDS_CHANGES",
  "issues": [],
  "suggestions": []
}
```

2. **Handle Verdict**:

**PASS** → Proceed to next step
**FAIL/NEEDS_CHANGES** → Iteration loop (max 3)

### Step 6: Iteration Loop

If verification fails:

```
Iteration [N] of 3

Issues identified:
1. [issue from verifier]
2. [issue from verifier]

Returning to Implementer with fixes required.
```

**Back to Step 4** with:
- Original step context
- Verifier feedback
- Previous attempt diff

**After 3 failed iterations**:
```markdown
## Iteration Limit Reached

Step [N] failed verification 3 times.

Issues:
1. [persistent issue]

**Options**:
1. Continue anyway (risky)
2. Modify plan
3. Get human help

**What would you like to do?**
```

### Step 7: Completion

When all steps pass verification:

1. **Final Summary**:
```markdown
## Task Complete

**Plan**: [plan_id]
**Steps**: [completed]/[total]
**Iterations**: [total retries used]

### Changes Made
| File | Change |
|------|--------|
| ... | ... |

### Tests
- [test results]

### Verification
- All steps passed code-judge review
- [any notes]
```

2. **Update Ledger**:
```json
{
  "currentState": {
    "stage": "complete",
    "completedAt": "2026-01-24T12:00:00Z"
  },
  "lastCompletedTask": "[task description]"
}
```

---

## Ledger Integration

The Ledger is the project's `.claude/status.json` file.

### Read Before Any Action
```bash
PROJECT_STATUS="$(pwd)/.claude/status.json"
if [ -f "$PROJECT_STATUS" ]; then
    cat "$PROJECT_STATUS"
fi
```

### Update After Each Step
Use jq to update specific fields without overwriting:
```bash
jq '.currentState.step = [N]' "$PROJECT_STATUS" > tmp && mv tmp "$PROJECT_STATUS"
```

### State Recovery
If session interrupted mid-task:
1. Read status.json
2. Find `currentState.step`
3. Resume from that step

---

## Quick Mode

For simpler tasks, skip to direct implementation:

```markdown
## Quick Mode

Task doesn't require full orchestration.
- Single file change
- Clear requirements
- Low risk

Proceeding with direct implementation...
```

Still applies:
- Verification after change
- Proof of working code
- Update status.json

---

## Error Handling

| Error | Recovery |
|-------|----------|
| Planner fails | Ask user to decompose manually |
| Implementer fails | Show error, ask for guidance |
| Verifier fails | Skip verification, warn user |
| Ledger unavailable | Continue without state tracking |
| Max iterations | Human decision point |

---

## NEVER

- Proceed without user approval at plan gates
- Skip pre-mortem for High/Critical risk tasks
- Implement more than 3 retries without human guidance
- Allow scope creep during implementation (use /ship-it)
- Trust "it works in dev" for production changes
- Parallelize steps with shared state or dependencies
- Ignore verifier FAIL verdicts
- Declare "complete" without proof (tests, screenshots, real data)
- Use mock data in any phase
- Skip Ledger (status.json) updates

---

## Escalation to Specialist Agents

When a step requires specialized capabilities, escalate to consolidated agents:

### Escalation Triggers

| Trigger Keywords | Escalate To | MCP |
|------------------|-------------|-----|
| PDF, image, vision, screenshot, design-to-code | `gemini-specialist` | gemini |
| research, find out, investigate, SEC, academic | `research-specialist` | perplexity |
| X/Twitter, trending, social, tweet, pulse | `realtime-specialist` | grok |
| brainstorm, prove, algorithm, reason, math | `reasoning-specialist` | azure-ai-foundry |
| pipeline failed, build error, CI failed, deployment error | `/fix-pipeline` skill | — |
| looping, 3rd attempt, stuck on same fix, start over | `/scrap-reimplement` skill | — |
| architecture doc, document codebase, dependency map | `/architecture-doc` skill | — |
| risky task, 3+ files, auth/crypto/infra, risk assessment | `/pre-mortem` skill | — |
| scope creep, perfectionism, is this done, good enough | `/ship-it` skill | — |

### Escalation Protocol

1. **Detect need**: During implementation, recognize specialized task
2. **Spawn specialist**:
```
Task tool with subagent_type: "gemini-specialist"
Prompt: "Analyze [file/image]. Return: findings summary, confidence score, recommendations."
```
3. **Receive condensed output**: Specialist returns 1-2k token summary (NOT full context)
4. **Integrate**: Incorporate findings into main workflow
5. **Log to telemetry**: Record escalation for routing calibration

### Escalation Limits
- Max 3 escalations per step
- Max 10 escalations per orchestration
- If exceeded, ask user for guidance

---

## Parallel Execution

When plan has independent steps, execute in parallel:

### Independence Check
Steps are independent if:
- [ ] No shared files
- [ ] No data dependencies
- [ ] No sequential ordering requirement

### Parallel Protocol

1. **Identify parallel candidates**: Group independent steps
2. **Launch concurrently**: Single message with multiple Task tool calls
```
[Task 1: step A] [Task 2: step B] [Task 3: step C]
```
3. **Collect results**: Wait for all to complete
4. **Verify batch**: Single code-judge review for all parallel changes
5. **Handle conflicts**: If merge conflicts, revert to sequential

### Parallel Limits
- Max 5 parallel agents
- Use for independent components only
- Never parallelize steps with shared state

---

## Checkpoint/Resume Protocol

For orchestrations spanning multiple sessions:

### Auto-Checkpoint Triggers
- After each step completion
- Before user approval gates
- After max iteration warning
- On explicit `/checkpoint` command

### Checkpoint Data
Write to `status.json`:
```json
{
  "checkpoint": {
    "checkpoint_id": "ckpt-{timestamp}",
    "task_id": "[task ID]",
    "phase": "implementing",
    "step_index": 2,
    "total_steps": 5,
    "iteration_count": 1,
    "resumable": true,
    "created_at": "[ISO timestamp]",
    "context_snapshot": {
      "original_request": "[user request]",
      "decisions": [...],
      "files_state": {...}
    }
  }
}
```

### Resume Protocol

At session start:
1. Check `status.json` for incomplete checkpoint
2. If found, present:
```markdown
## Incomplete Orchestration Detected

**Task**: [description]
**Progress**: Step [N] of [M]
**Checkpointed**: [timestamp]
**Age**: [hours/days ago]

**Options**:
1. Resume from checkpoint
2. Start fresh (discard checkpoint)
3. Review checkpoint details

**What would you like to do?**
```

3. On resume:
- Verify file hashes match (detect drift)
- Load decisions and context
- Continue from step N with `[Resuming from checkpoint]` context

### File Drift Detection
```python
# Compare file hashes at checkpoint vs current
for file, expected_hash in checkpoint.files_state.items():
    current_hash = hash_file(file)
    if current_hash != expected_hash:
        warn(f"File {file} changed since checkpoint")
```

If drift detected, warn user and ask whether to:
- Continue anyway
- Re-plan affected steps
- Start fresh

---

## Telemetry Integration

Log routing decisions for calibration:

### What to Log
```json
{
  "telemetry_id": "telem-{timestamp}",
  "trace_id": "[orchestration trace ID]",
  "event_type": "step_complete",
  "step_number": 2,
  "agent_used": "code-worker",
  "escalations": [
    { "to": "gemini-specialist", "reason": "PDF analysis" }
  ],
  "outcome": "success",
  "duration_ms": 45000,
  "retry_count": 1,
  "verification_passed": true
}
```

### When to Log
- Step start
- Step complete
- Escalation
- Verification result
- Error/retry
- Checkpoint created/resumed

### Telemetry Storage
Append to `~/.claude/telemetry/orchestration-{date}.jsonl`

---

## Integration with Learning Loop

After task completion:
1. Log success/failure patterns used
2. If new pattern discovered → Propose addition
3. Update patterns file via learning-loop skill
4. **Log telemetry for routing calibration**
5. If escalation was effective → Log positive signal
6. If route override occurred → Log calibration suggestion

---

## Example Flow

```
User: "Add user authentication to the API"

[Pre-Flight] High complexity, 5+ files, orchestration recommended

[Planner] Decomposes into 5 steps:
1. Create auth middleware
2. Add JWT token generation
3. Create login endpoint
4. Create protected route decorator
5. Add tests

[User Approval] Approved

[Step 1] Implementer creates middleware → Verifier: PASS
[Step 2] Implementer adds JWT → Verifier: NEEDS_CHANGES (hardcoded secret)
[Step 2 Retry] Implementer uses env var → Verifier: PASS
[Step 3] Implementer creates endpoint → Verifier: PASS
[Step 4] Implementer adds decorator → Verifier: PASS
[Step 5] Implementer writes tests → Verifier: PASS

[Complete] 5/5 steps, 1 iteration used
```

---

## Failed Approaches

*Document approaches that didn't work to prevent future sessions from repeating them.*

| Date | Task Type | Approach Tried | Why It Failed |
|------|-----------|----------------|---------------|
| — | — | — | — |

---

*Part of Silent Kernel Architecture v8.0*
