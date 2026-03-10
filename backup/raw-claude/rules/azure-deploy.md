# Azure Deploy & Git Rules

## Git Remote (Azure DevOps ONLY - Never GitHub)

```bash
# SSH (preferred)
git remote add azure git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<repo-name>
# HTTPS (fallback)
git remote add azure https://Corp-domain@dev.azure.com/Corp-domain/Corp-AI/_git/<repo-name>
# Verify: git remote get-url azure  (must be dev.azure.com, NOT github.com)
```

## Commit & Branch Format

```
# Commits: <type>(<scope>): <description>
# Types: feat | fix | refactor | docs | test | chore | perf
# Branches: <type>/<ticket-or-description>
# Example: feature/user-authentication
```

## Post-Push Pipeline Verification (MANDATORY)

After every `git push azure <branch>`:
```bash
# 1. Find pipeline
az pipelines list --org https://dev.azure.com/Corp-domain --project Corp-AI \
  --query "[?contains(name, 'repo-name')]" -o table
# 2. Check if triggered
az pipelines runs list --org https://dev.azure.com/Corp-domain --project Corp-AI \
  --pipeline-ids <id> --top 1 -o table
# 3. Manual trigger if needed
az pipelines run --org https://dev.azure.com/Corp-domain --project Corp-AI \
  --name <pipeline-name> --branch <branch>
# 4. Wait for completion before any verification
```

## Azure Infrastructure

| Key | Value |
|-----|-------|
| Subscription | U-BTech - CSP (Z-Online) |
| Resource Group | AZAI_group |
| Location | swedencentral |
| Key Vault | kv-seekapa-apps |

## Safety Rules

- **NEVER** push to GitHub - Azure DevOps only
- **NEVER** restart function apps manually after deploy - let pipeline handle cold start
- **NEVER** hardcode credentials - use Key Vault / env vars
- **NEVER** delete Azure resources without explicit user confirmation
- **NEVER** force push to main/master without explicit confirmation
- **NEVER** modify Key Vault access policies without review
- Secrets via: `az keyvault secret show --vault-name kv-seekapa-apps --name <secret>`
- After deploy, verify via **database queries** (APIs may cache)

## Production Apps

See CLAUDE.md Production Apps table (single source of truth).

## Deploy Lessons

- ALWAYS search for existing deploy scripts (`ls *deploy*.sh`) before manual CLI commands
- Manual `curl` to Kudu breaks `WEBSITE_RUN_FROM_PACKAGE=1` apps — use `az functionapp deployment`
- Kudu zip deploy for frontends without CI/CD: `curl -X POST https://<app>.scm.azurewebsites.net/api/zipdeploy`
- After deploy: check function count via health endpoint, not just HTTP status code
- Verification queries run before pipeline completes show PRE-deployment state — wait for completion
- Manual restart after pipeline deploy can cause LLM client initialization race conditions — let cold start happen naturally

## End-of-Session Deployment Verification (MANDATORY)

If ANY production code file (`src/`, `shared/`) was modified during the session:
1. `git status` — ZERO modified production files (all committed)
2. `git log --oneline -1` — latest commit includes your changes
3. `git push azure <branch>` — pushed to remote
4. If deployed: health endpoint version matches what you just deployed
5. NEVER end a session with uncommitted changes to `src/` or `shared/`

Origin: QC Telephony Feb 2026 — 5 modified files never committed. Production ran stale v2.0.0 for 18 days while team believed fixes were live.

## Rollback

```bash
git revert <bad-commit>  # Never reset --hard on shared branches
git push azure main
```

## Async Kudu Deploy for Large Apps (MANDATORY for 150+ functions)

Use `isAsync=true` for Kudu zipdeploy and poll for status instead of synchronous wait. Synchronous deploy exceeds Azure Front Door gateway timeout (~240s) for large apps.

1. `POST /api/zipdeploy?isAsync=true` (returns 202 immediately)
2. Poll `/api/deployments/latest` every 15s
3. Check `status` field: 0=pending, 1=building, 2=deploying, 3=failed, 4=success
4. Also check `complete=True` as backup signal
5. Timeout at 600s (10 min) for large Oryx builds
6. After any 504 gateway timeout: deployment may still be running — poll before retrying
7. Add HTTP 400 to retry list with 120s+ delay (deployment slot lock from previous attempt)

Origin: Sentimark Feb 2026 — synchronous deploy caused 2 pipeline failures (504->400 cascade). Async deploy eliminated 504s entirely.

## Post-Deploy Version Assertion (MANDATORY)

After every deployment, assert the running version matches what was deployed:

1. Bump version in code BEFORE committing
2. Commit + push + deploy
3. Wait 60s for cold start
4. `curl` health endpoint and assert version matches
5. Only THEN run functional tests against production

Azure Consumption Plan serves old code for 12+ hours from warm instances. Version assertion catches stale deployments immediately.

Origin: QC Telephony Feb 2026 — health endpoint returned old version for 18 days.

## Oryx Deploy Zip Root-Level Structure (MANDATORY for monorepos)

Azure App Service Oryx build requires `requirements.txt` and `startup.sh` at the ZIP root level — not nested in subdirectories.

1. Build deploy zip with `requirements.txt` and `startup.sh` COPIED to zip root
2. Keep backend/ package nested for imports
3. Exclude `.venv` from zip
4. Verify container starts: check Docker logs (`az webapp log download`), not just deploy status

Oryx silently skips pip install if `requirements.txt` is nested. Container starts but crashes with `ModuleNotFoundError`.

Origin: Real-time Feb 2026 — deploy "succeeded" but container crash-looped. requirements.txt nested in backend/ caused silent skip.

## Bash Dollar Expansion in Publish Credentials

Azure App Service publish profile usernames start with `$` (e.g., `$app-realtime-monitor`). Using this in bash `curl -u` causes variable expansion, sending empty username (HTTP 401).

- Use Python `urllib.request` for Kudu zipdeploy instead of bash curl
- Pass credentials as `sys.argv` from Azure DevOps `$(VAR)` macros (expanded before bash runs)

Origin: Real-time Feb 2026 — 401 errors from username corruption. Works in Python but not bash due to $ expansion.

## Production Logs Before Code Re-Read (MANDATORY)

When production fails, pull actual runtime logs (`az webapp log download`) BEFORE re-reading code. The error is often a runtime mismatch (missing deps, wrong startup path, API contract), not a code logic bug.

- "Deploy succeeded" != "Bug fixed" — always have user test the specific functionality
- Pull Docker logs on any user-reported issue, not just when tests fail

Origin: Real-time Feb 2026 — 3 deploy cycles where "tests pass + deploy succeeded" but user reported "nothing happening". All fixed by reading production logs.

## Azure Blob --auth-mode key for CI/CD

Use `--auth-mode key` (not `login`) for Azure Blob operations in automated/CI contexts. Key mode auto-queries for the account key and does not require RBAC role assignment.

Origin: Sentimark Feb 2026 — login mode failed in CI because RBAC role was not assigned to the service principal.

## Azure App Service /home/ for Simple Persistence

Use Azure App Service's persistent `/home/` directory for JSON file storage instead of database for MVP state that must survive restarts.

- Detect Azure via `Path('/home/site').exists()`
- Write JSON to `/home/data/<filename>.json` (persistent across restarts)
- Fall back to local `data/` dir for dev
- `/home/` is a persistent Azure Files share. Survives restarts, redeployments, and plan changes.

Origin: Phone Spam Checker Feb 2026 — needed simple config/rules persistence without database overhead.

## Dockerfile Exec Form CMD (MANDATORY)

Always use exec form for CMD in Dockerfiles:

```dockerfile
# GOOD: PID 1 = application (receives SIGTERM directly)
CMD ["uvicorn", "src.api.app:app", "--host", "0.0.0.0", "--port", "8000"]

# BAD: PID 1 = /bin/sh (SIGTERM goes to shell, not app)
CMD uvicorn src.api.app:app --host 0.0.0.0 --port 8000
```

Shell form makes PID 1 = /bin/sh. SIGTERM goes to the shell, not the application. Graceful shutdown fails; container hits the 10-second kill timeout.

Origin: Hey Seven Feb 2026 — in-flight requests dropped on every deploy due to shell-form CMD.

## SSH Blocked by Entra → Fall Back to HTTPS+PAT (MANDATORY)

When `git push azure` fails with `VS403463: The conditional access policy defined by your Microsoft Entra administrator has failed`:

1. **Try SSH first** — `ssh -T git@ssh.dev.azure.com` (expect "Shell access is not supported" = success)
2. **If SSH blocked**, use HTTPS remote with PAT: `git push azure-https <branch>`
3. **PAT stored in** `~/.git-credentials` — requires `git config --global credential.helper store`
4. **If auth fails with user `aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa`** — PAT is expired or wrong scope
5. **REST API 200 does NOT mean git push works** — different auth paths. PAT needs `Code (Read & Write)` scope for push.
6. **Entra blocks are intermittent** — SSH may work minutes later without any config change

```bash
# Diagnostic sequence:
ssh -T git@ssh.dev.azure.com          # Test SSH (fast)
git push azure-https <branch>          # Fall back to HTTPS+PAT
# If both fail:
curl -s -o /dev/null -w "%{http_code}" \
  -u "Corp-domain:<PAT>" \
  "https://dev.azure.com/Corp-domain/Corp-AI/_apis/git/repositories/<repo>?api-version=7.0"
# 200 = PAT valid but wrong scope. 401 = PAT expired.
```

Origin: Sentimark Feb 2026 — SSH blocked by Entra for hours. PAT also expired. API returned 200 but git push failed (TF400813). SSH worked again after Entra policy cleared.
