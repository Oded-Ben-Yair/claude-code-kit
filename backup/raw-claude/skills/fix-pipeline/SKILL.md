---
name: fix-pipeline
description: Auto-diagnose and fix CI/CD pipeline failures. Fetches pipeline logs, identifies root cause, and launches code-worker to fix.
allowed-tools: Read, Write, Edit, Bash(az:*), Bash(git:*), Bash(npm:*), Bash(python:*), Grep, Glob, Task
disable-model-invocation: true
metadata:
  version: "1.0.0"
  author: odedbe
---

# /fix-pipeline

Auto-diagnose and fix CI/CD pipeline failures on Azure DevOps.

## When to Use

- After a `git push azure` triggers a pipeline that fails
- When the user says "pipeline failed", "fix the build", "build broke", or "CI is red"
- When `az pipelines runs list` shows a recent run with `result=failed`

## Workflow

### Step 1: Identify the Failed Pipeline

Determine which pipeline failed. If the user provides a pipeline name or ID, use it directly. Otherwise, discover it from the current project:

```bash
# List pipelines for the project
az pipelines list --org https://dev.azure.com/Corp-domain --project Corp-AI \
  --query "[?contains(name, '<repo-name>')]" -o table

# Get the most recent run
az pipelines runs list --org https://dev.azure.com/Corp-domain --project Corp-AI \
  --pipeline-ids <id> --top 1 -o json
```

Record the `run_id` and `result` from the output.

### Step 2: Fetch Pipeline Logs

If `result=failed`, retrieve the run details and logs:

```bash
# Get run details
az pipelines runs show --org https://dev.azure.com/Corp-domain --project Corp-AI \
  --id <run-id> -o json

# Get logs for the failed run
az devops invoke --area build --resource builds \
  --route-parameters project=Corp-AI buildId=<run-id> \
  --org https://dev.azure.com/Corp-domain \
  --http-method GET --api-version 7.1 -o json

# Download timeline to find the failed step
az devops invoke --area build --resource timeline \
  --route-parameters project=Corp-AI buildId=<run-id> \
  --org https://dev.azure.com/Corp-domain \
  --http-method GET --api-version 7.1 -o json
```

### Step 3: Parse and Categorize the Error

Read the log output and classify into one of these categories:

| Category | Indicators | Action |
|----------|-----------|--------|
| **Build error** | `SyntaxError`, `ImportError`, `TypeError`, `ModuleNotFoundError`, compilation failure | Fix the source code |
| **Test failure** | `FAILED`, `AssertionError`, `pytest` exit code != 0 | Read the failing test, fix the code or test |
| **Deployment error** | `DeploymentFailed`, Azure resource errors, `403`, `409` | Check Azure config, resource state |
| **Dependency error** | `No matching distribution`, `Could not resolve`, version conflicts | Fix `requirements.txt` or `package.json` |
| **Lint/format error** | `black`, `ruff`, `eslint`, `prettier` failures | Run formatter/linter locally and commit |

Extract the specific error message, file path, and line number when available.

### Step 4: Apply the Fix

1. **Show the error and proposed fix to the user before applying.**
2. Launch code-worker agent (or fix directly for simple issues) to implement the fix.
3. For each category:
   - **Build error**: Open the file at the reported line, fix syntax/import/type issue.
   - **Test failure**: Read the failing test, understand the assertion, fix the code under test.
   - **Deployment error**: Report to user with diagnosis. Do NOT modify Azure resources automatically.
   - **Dependency error**: Update `requirements.txt` or `package.json`, run install to verify.
   - **Lint/format error**: Run the formatter/linter locally, commit the result.

### Step 5: Push and Re-check

```bash
# Stage and commit the fix
git add <fixed-files>
git commit -m "fix(<scope>): <description of pipeline fix>"

# Push to Azure DevOps
git push azure <branch>

# Wait for pipeline to trigger, then check status
az pipelines runs list --org https://dev.azure.com/Corp-domain --project Corp-AI \
  --pipeline-ids <id> --top 1 -o json
```

Wait for the pipeline run to complete before declaring success. Remember: verifying before pipeline completes shows PRE-deployment state.

### Step 6: Evaluate Result

- If `result=succeeded`: Report success, reset the attempt counter.
- If `result=failed`: Increment attempt counter, go back to Step 2 with the new logs.
- If attempt count reaches the limit: STOP and escalate to the user.

## Safety Rules

- **Max 2 auto-fix attempts** before escalating to the human. Never silently loop.
- **Never modify pipeline YAML** (`azure-pipelines.yml`, `.github/workflows/*`) without explicit user approval.
- **Never modify infrastructure** (Azure resources, resource groups, app settings) automatically.
- **Always show the error and proposed fix** before applying. Wait for implicit or explicit user confirmation.
- **Log all auto-fix attempts** to `~/.claude/telemetry/auto-fix.jsonl` in this format:
  ```json
  {
    "timestamp": "<ISO-8601>",
    "pipeline": "<name>",
    "run_id": "<id>",
    "error_category": "<build|test|deploy|dependency|lint>",
    "root_cause": "<description>",
    "fix_applied": "<description>",
    "attempt": 1,
    "result": "<pass|fail|escalated>"
  }
  ```
- **Never push to GitHub** -- Azure DevOps only (per project rules).
- **Never force push** to fix a pipeline issue.

## NEVER

- Attempt more than 2 auto-fixes without human approval
- Modify pipeline YAML without explicit user confirmation
- Touch Azure infrastructure (resources, app settings, resource groups)
- Force push to any branch
- Push to GitHub (Azure DevOps only)
- Silently retry the same fix that already failed
- Declare "fixed" before pipeline run completes with `result=succeeded`
- Skip showing error and proposed fix to the user
- Modify code in `shared/` without checking all consumers

---

## Anti-Loop Guard

Track fix attempts to prevent infinite retry loops:

1. On first invocation, write attempt count to `/tmp/claude-pipeline-fix-count`:
   ```bash
   echo "1" > /tmp/claude-pipeline-fix-count
   ```
2. On each subsequent attempt, increment the counter:
   ```bash
   count=$(($(cat /tmp/claude-pipeline-fix-count) + 1))
   echo "$count" > /tmp/claude-pipeline-fix-count
   ```
3. **Hard stop at attempt 3.** If the counter reaches 3, do NOT attempt another fix. Report all three attempts to the user and ask for manual intervention.
4. On a successful pipeline run (`result=succeeded`), reset the counter:
   ```bash
   echo "0" > /tmp/claude-pipeline-fix-count
   ```

## Output Format

After each fix attempt (or escalation), produce this report:

```markdown
## Pipeline Fix Report

**Pipeline**: [name]
**Run ID**: [id]
**Branch**: [branch name]
**Error Category**: [build/test/deploy/dependency/lint]
**Root Cause**: [specific error description with file and line if available]
**Fix Applied**: [what was changed, which files]
**Attempt**: [1/2/3]
**Result**: [pass/fail/escalated]

### Files Modified
| File | Change |
|------|--------|
| `path/to/file` | Description of change |

### Next Steps
- [If pass: none, pipeline is green]
- [If fail: description of remaining issue]
- [If escalated: what the user should investigate manually]
```

---

## Failed Approaches

*Document approaches that didn't work to prevent future sessions from repeating them.*

| Date | Pipeline/Error | Approach Tried | Why It Failed |
|------|----------------|----------------|---------------|
| — | — | — | — |

---

*Part of Silent Kernel Architecture v8.0*
