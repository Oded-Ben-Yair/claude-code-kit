# Cloud Deploy & Git Rules

## Git Remote

```bash
# Configure your remote (SSH preferred, HTTPS fallback)
git remote add origin <your-git-remote-url>
# Verify: git remote get-url origin
```

## Commit & Branch Format

```
# Commits: <type>(<scope>): <description>
# Types: feat | fix | refactor | docs | test | chore | perf
# Branches: <type>/<ticket-or-description>
# Example: feature/user-authentication
```

## Post-Push Pipeline Verification (MANDATORY)

After every `git push origin <branch>`:

1. Verify the CI/CD pipeline was triggered
2. Check pipeline status (use your platform's CLI or web UI)
3. Wait for pipeline completion before any verification
4. Do NOT run verification commands before the pipeline finishes -- you will see pre-deployment state

## Safety Rules

- **NEVER** hardcode credentials -- use secret managers / env vars
- **NEVER** restart services manually after deploy -- let the pipeline handle cold start
- **NEVER** delete cloud resources without explicit user confirmation
- **NEVER** force push to main/master without explicit confirmation
- **NEVER** modify secret manager access policies without review
- After deploy, verify via **database queries** if APIs may cache stale responses

## Deploy Lessons

- ALWAYS search for existing deploy scripts (`ls *deploy*.sh`) before manual CLI commands
- After deploy: check function/service count via health endpoint, not just HTTP status code
- Verification queries run before pipeline completes show PRE-deployment state -- wait for completion
- Manual restart after pipeline deploy can cause LLM client initialization race conditions -- let cold start happen naturally

Origin: Learned from multiple production incidents where premature verification gave false confidence.

## End-of-Session Deployment Verification (MANDATORY)

If ANY production code file (`src/`, `shared/`) was modified during the session:
1. `git status` -- ZERO modified production files (all committed)
2. `git log --oneline -1` -- latest commit includes your changes
3. `git push origin <branch>` -- pushed to remote
4. If deployed: health endpoint version matches what you just deployed
5. NEVER end a session with uncommitted changes to `src/` or `shared/`

Origin: Production ran stale code for 18 days because 5 modified files were never committed. Team believed fixes were live.

## Rollback

```bash
git revert <bad-commit>  # Never reset --hard on shared branches
git push origin main
```

## Async Deploy for Large Apps (MANDATORY for large deployments)

Use asynchronous deployment and poll for status instead of synchronous wait. Synchronous deploy can exceed gateway timeouts (~240s) for large apps.

1. Trigger async deploy (returns immediately)
2. Poll deployment status endpoint every 15s
3. Check for completion signal (status field or complete flag)
4. Timeout at 600s (10 min) for large builds
5. After any gateway timeout: deployment may still be running -- poll before retrying
6. Add HTTP 400 to retry list with 120s+ delay (deployment slot lock from previous attempt)

Origin: Synchronous deploy caused cascading pipeline failures (504->400). Async deploy eliminated timeouts entirely.

## Post-Deploy Version Assertion (MANDATORY)

After every deployment, assert the running version matches what was deployed:

1. Bump version in code BEFORE committing
2. Commit + push + deploy
3. Wait 60s for cold start
4. `curl` health endpoint and assert version matches
5. Only THEN run functional tests against production

Serverless platforms serve old code from warm instances for hours. Version assertion catches stale deployments immediately.

Origin: Health endpoint returned old version for 18 days on a serverless platform.

## Deploy Zip Root-Level Structure (MANDATORY for monorepos)

Many cloud build systems require `requirements.txt` / `package.json` and startup scripts at the ZIP/deploy root level -- not nested in subdirectories.

1. Build deploy artifact with dependency files COPIED to root
2. Keep backend/ package nested for imports
3. Exclude `.venv` / `node_modules` from deploy artifact
4. Verify container starts: check runtime logs, not just deploy status

Build systems silently skip dependency install if config files are nested. Container starts but crashes with missing module errors.

Origin: Deploy "succeeded" but container crash-looped because requirements.txt was nested in a subdirectory.

## Production Logs Before Code Re-Read (MANDATORY)

When production fails, pull actual runtime logs BEFORE re-reading code. The error is often a runtime mismatch (missing deps, wrong startup path, API contract), not a code logic bug.

- "Deploy succeeded" != "Bug fixed" -- always have user test the specific functionality
- Pull container/runtime logs on any user-reported issue, not just when tests fail

Origin: 3 deploy cycles where "tests pass + deploy succeeded" but user reported "nothing happening". All fixed by reading production logs.

## Container Persistent Storage for Simple State

Use platform-provided persistent directories for JSON file storage instead of database for MVP state that must survive restarts.

- Detect cloud environment via platform-specific path checks
- Write JSON to persistent directory
- Fall back to local `data/` dir for dev

Origin: Needed simple config/rules persistence without database overhead.

## Dockerfile Exec Form CMD (MANDATORY)

Always use exec form for CMD in Dockerfiles:

```dockerfile
# GOOD: PID 1 = application (receives SIGTERM directly)
CMD ["uvicorn", "src.api.app:app", "--host", "0.0.0.0", "--port", "8000"]

# BAD: PID 1 = /bin/sh (SIGTERM goes to shell, not app)
CMD uvicorn src.api.app:app --host 0.0.0.0 --port 8000
```

Shell form makes PID 1 = /bin/sh. SIGTERM goes to the shell, not the application. Graceful shutdown fails; container hits the kill timeout.

Origin: In-flight requests dropped on every deploy due to shell-form CMD.

## Blob/Object Storage Auth in CI/CD

Use key-based authentication (not login/RBAC) for blob/object storage operations in automated/CI contexts. Key mode auto-queries for credentials and does not require IAM role assignment on the CI runner.

Origin: Login-based auth failed in CI because the IAM role was not assigned to the service principal.

## Bash Dollar Expansion in Credentials

Some platform credentials start with `$` (e.g., `$app-name`). Using these in bash `curl -u` causes variable expansion, sending empty username (HTTP 401).

- Use Python `urllib.request` or `requests` instead of bash curl for deploy operations
- Pass credentials via environment variables or script arguments

Origin: 401 errors from username corruption. Works in Python but not bash due to $ expansion.

## Git Auth Fallback (SSH -> HTTPS+PAT)

When `git push` fails with authentication errors:

1. **Try SSH first** -- fastest, most reliable
2. **If SSH blocked**, use HTTPS remote with Personal Access Token
3. **PAT stored in** `~/.git-credentials` -- requires `git config --global credential.helper store`
4. **REST API success does NOT mean git push works** -- different auth paths
5. **Auth blocks can be intermittent** -- SSH may work again later without config changes

```bash
# Diagnostic sequence:
ssh -T git@<host>                    # Test SSH (fast)
git push origin-https <branch>       # Fall back to HTTPS+PAT
```

Origin: SSH blocked by identity provider for hours. PAT also expired. API returned 200 but git push failed. SSH worked again after policy cleared.
