name: playbooks
description: Pre-defined agent chains for common development workflows. Orchestrates the flow between Planner, Worker, and Judge agents for different task types.

---

# Workflow Playbooks

## Purpose

Playbooks are pre-defined **agent chains** that orchestrate the Planner → Worker → Judge hierarchy for common development tasks. Instead of manually invoking each agent, playbooks automate the sequence.

## Available Playbooks

### Playbook: New Feature (`/feature`)

**Use when**: Adding new functionality to the codebase

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  /architect │ ──▶ │  /implement │ ──▶ │   /review   │ ──▶ │    /memo    │
│  (Planner)  │     │  (Worker)   │     │   (Judge)   │     │  (Learning) │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
   Design plan        Write code          Validate           Store learnings
   No code yet        With tests          Quality            For future
```

**Sequence**:
1. `/architect "Add feature X"` → Produces plan, identifies patterns
2. Human approves plan
3. `/implement` → Code Worker follows plan exactly
4. `/review` → Code Judge validates
5. If REVISE → back to step 3
6. If APPROVE → `/memo` to capture learnings

**Invoke**: `/feature "Add user profile editing"`

---

### Playbook: Bug Fix (`/bugfix`)

**Use when**: Fixing a reported bug with unknown root cause

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    /tdd     │ ──▶ │  /implement │ ──▶ │   /review   │ ──▶ │    /memo    │
│ (Regression)│     │    (Fix)    │     │  (Validate) │     │  (Learning) │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
  Write test that      Fix the bug        Verify fix         Prevent
  reproduces bug       minimally          is correct         recurrence
```

**Sequence**:
1. `/tdd:red "Bug: X happens when Y"` → Write failing test that reproduces
2. `/implement` → Fix with minimal change
3. `/review` → Judge validates fix doesn't break other things
4. `/memo "Root cause: Z"` → Document for future

**Invoke**: `/bugfix "Users can't login after password reset"`

---

### Playbook: Refactor (`/refactor`)

**Use when**: Improving code quality without changing behavior

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   /review   │ ──▶ │  /architect │ ──▶ │ /implement  │ ──▶ │   /review   │
│  (Analyze)  │     │  (Plan)     │     │ (Refactor)  │     │  (Verify)   │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
  Find problems        Plan changes       Execute with       Verify no
  and tech debt        step by step       tests green        regressions
```

**Sequence**:
1. `/review "src/module"` → Judge identifies issues
2. `/architect "Refactor to address [issues]"` → Plan the refactor
3. Human approves plan
4. `/implement` → Execute refactor, keeping tests green
5. `/review` → Verify improvements, no regressions

**Invoke**: `/refactor src/services/UserService.ts`

---

### Playbook: New Endpoint (`/endpoint`)

**Use when**: Adding a new REST API endpoint

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ /pattern-   │ ──▶ │  /architect │ ──▶ │    /tdd     │ ──▶ │   /review   │
│   first     │     │  (Design)   │     │  (Impl)     │     │  (Validate) │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
  Find existing       Design endpoint      TDD loop          Final
  API patterns        following pattern    implementation    validation
```

**Sequence**:
1. Find existing endpoint patterns in codebase
2. `/architect "Add GET /api/resource/:id"` → Design following patterns
3. Human approves
4. `/tdd` → Implement with test-first approach
5. `/review` → Validate security, patterns, tests

**Invoke**: `/endpoint "GET /api/users/:id/settings"`

---

### Playbook: Migration (`/migrate`)

**Use when**: Migrating from one pattern/library/version to another

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ /pr-genome  │ ──▶ │  /architect │ ──▶ │ /implement  │ ──▶ │   /review   │
│ (Research)  │     │ (Plan steps)│     │ (Step by)   │     │ (Validate)  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
  Learn from past      Plan migration     Execute in         Verify each
  migrations           incrementally      small PRs          step works
```

**Sequence**:
1. `/pr-genome` → Learn from past migration patterns
2. `/architect "Migrate from X to Y"` → Plan incremental steps
3. Human approves
4. For each step:
   - `/implement` → Execute migration step
   - `/review` → Validate step
   - Create checkpoint PR
5. `/memo` → Document migration patterns

**Invoke**: `/migrate "React 18 to React 19"`

---

### Playbook: Hotfix (`/hotfix`)

**Use when**: Critical production issue requiring immediate fix

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  /diagnose  │ ──▶ │  /tdd:red   │ ──▶ │  /implement │ ──▶ │ /review:fast│
│  (Find bug) │     │ (Reproduce) │     │   (Fix)     │     │  (Quick)    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
  Identify root       Write repro        Minimal fix         Fast security
  cause quickly       test ASAP          only                + correctness
```

**Sequence**:
1. Diagnose: Find the exact root cause
2. Reproduce: Write test that fails
3. Fix: Minimal change only
4. Quick review: Security + correctness focus
5. Deploy immediately

**Invoke**: `/hotfix "Production 500 errors on checkout"`

---

## Playbook Selection Guide

| Situation | Playbook | Why |
|-----------|----------|-----|
| Adding new functionality | `/feature` | Full design → implement → review cycle |
| Something is broken | `/bugfix` | TDD ensures fix is correct |
| Code smells/tech debt | `/refactor` | Analyze first, plan second |
| New API endpoint | `/endpoint` | Pattern-first + TDD for APIs |
| Library/framework upgrade | `/migrate` | Learn from past, incremental execution |
| Production is down | `/hotfix` | Speed priority, minimal scope |

## Custom Playbooks

Create custom playbooks in `~/.claude/skills/playbooks/custom/`:

```markdown
# Custom Playbook: [Name]

## Use When
[Conditions for using this playbook]

## Sequence
1. [Agent/Skill] → [Output]
2. [Agent/Skill] → [Output]
...

## Gates
- [ ] [Approval point 1]
- [ ] [Approval point 2]
```

## Playbook Execution Tracking

When a playbook runs, track progress:

```markdown
## Playbook: /feature "Add user settings"
Started: 2026-01-15 10:00 UTC

### Progress
- [x] /architect → Plan approved
- [x] /implement → Code written
- [ ] /review → In progress
- [ ] /memo → Pending

### Current Step
Waiting for Judge review...

### Blockers
None
```

## Integration with Todo System

Playbooks automatically create todos:

```javascript
// When /feature "Add X" is invoked:
TodoWrite([
  { content: "Design feature X", status: "in_progress", activeForm: "Designing feature X" },
  { content: "Implement feature X", status: "pending", activeForm: "Implementing feature X" },
  { content: "Review feature X", status: "pending", activeForm: "Reviewing feature X" },
  { content: "Document learnings", status: "pending", activeForm: "Documenting learnings" }
])
```

## Abort/Rollback

If a playbook fails mid-execution:

```
/playbook:abort → Stops current playbook
/playbook:rollback → Reverts changes from current step
/playbook:resume → Continues from last successful step
```
