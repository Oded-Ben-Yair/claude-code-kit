---
name: scrap-reimplement
description: Destructive recovery - stash broken code, reimplement from spec when fix attempts are looping. Last resort.
allowed-tools: Read, Write, Edit, Bash(git:*), Bash(python:*), Bash(npm:*), Bash(node:*), Grep, Glob, Task
disable-model-invocation: true
metadata:
  version: "1.0.0"
  author: odedbe
---

# Scrap & Reimplement

Destructive recovery pattern. Delete broken code and rewrite from spec when fix attempts are looping.

## When to Use

- After 3+ failed fix attempts on the same issue
- When the `/find-solution` skill did not help
- When code has accumulated so many patches it is unreadable
- When user explicitly says "start over", "scrap it", "rewrite this"

## When NOT to Use

- First or second fix attempt (use `/find-solution` instead)
- On files you do not fully understand yet
- On shared infrastructure code without explicit approval
- When the issue is in external dependencies

## Workflow

### Step 1: Preserve

Create a safety branch before touching anything. Print the backup name to the user.

```bash
git stash push -m "scrap-reimplement-$(date +%Y%m%d-%H%M%S)" -- <files>
# OR if changes are larger:
git checkout -b backup/scrap-$(date +%Y%m%d-%H%M%S)
git add -A && git commit -m "backup before scrap-reimplement"
git checkout -  # back to working branch
```

### Step 2: Analyze

Before deleting, extract the SPEC (not the code):

- **What does this module DO?** (inputs, outputs, side effects)
- **What are the interface contracts?** (function signatures, API routes)
- **What tests exist?** (they define expected behavior)
- **What do callers expect?** (grep for imports/usage across the codebase)

Write down the spec. You will reimplement from this, not from memory of the old code.

### Step 3: Delete

Remove the broken implementation. Keep the file to preserve git history.

```bash
# Delete file contents but keep the file
> <file>
```

### Step 4: Reimplement

Write fresh from the spec extracted in Step 2.

- Follow the spec exactly -- inputs, outputs, interface contracts
- Use the simplest possible implementation
- Do NOT carry over clever optimizations from the old code
- Do NOT reference the old code from memory
- Run tests after each function/method

### Step 5: Verify

Full verification before declaring done:

- All existing tests pass
- Import chain from entry point is intact (`grep -r "from <module> import"`)
- No regressions in dependent modules
- Run the full test suite, not just unit tests for the changed file

## Safety Rules

- **ALWAYS** create backup branch/stash BEFORE deleting anything
- **NEVER** scrap `shared/` utilities without checking all consumers first
- **NEVER** scrap more than 3 files at once without explicit user approval
- **Log** the scrap event to `~/.claude/telemetry/scrap-reimplement.jsonl` with timestamp, files, and result
- **Print** the backup branch/stash name to the user immediately after creating it

---

## NEVER

- Delete code without creating backup first
- Reference old code from memory during reimplementation
- Carry over "clever" optimizations from broken code
- Scrap files you haven't analyzed for interface contracts
- Scrap external dependencies (the issue isn't in your code)
- Attempt reimplementation on first or second fix attempt
- Skip running the full test suite after reimplementation
- Continue reimplementation if tests fail (restore and escalate instead)
- Scrap production infrastructure code without explicit approval
- Assume the spec from memory — extract it from tests and callers

## Recovery if Scrap Fails

If the reimplementation does not pass tests or breaks other modules, restore immediately:

```bash
# Restore from stash
git stash pop
# OR restore from backup branch
git checkout backup/scrap-<timestamp> -- <files>
```

Do not attempt further fixes on the reimplemented code. Restore and escalate to the user.

## Output Format

After completing the scrap-reimplement, produce this report:

```markdown
## Scrap & Reimplement Report
**Files scrapped**: [list]
**Backup**: [stash ref or branch name]
**Spec extracted**: [summary of interface contracts]
**New implementation**: [summary of approach]
**Tests**: [pass/fail count]
**Result**: [success/partial/rolled-back]
```

---

## Failed Approaches

*Document approaches that didn't work to prevent future sessions from repeating them.*

| Date | Module/File | Approach Tried | Why It Failed |
|------|-------------|----------------|---------------|
| — | — | — | — |

---

*Part of Silent Kernel Architecture v8.0*
