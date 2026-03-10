# Handover Alignment Reference

Project-to-artifact mapping and change classification logic for Phase 3.7.

## Project Directory Mapping

Map `pwd` to project slug. Match against `~/projects/<slug>/`.

```
sentimark            → wiki:Sentimark, deploy:sentimark-docker-deploy, blob:sentimark
training-platform    → wiki:Training-Platform, deploy:seekapa-training-docker-deploy, blob:seekapa-training-platform
aeo                  → wiki:AEO-Platform, deploy:NONE, blob:aeo
cs-agents            → wiki:CS-Agents, deploy:cs-agents-docker-deploy, blob:axia-seekapa-cs-agents
sales-agents         → wiki:Sales-Agents, deploy:NONE, blob:sales-agents
client-evaluation    → wiki:Client-Evaluation, deploy:client-eval-docker-deploy, blob:client-evaluation
compliance-exam      → wiki:Compliance-Exam, deploy:compliance-exam-docker-deploy, blob:seekapa-compliance-exam
automation-fabric    → wiki:Automation-Fabric, deploy:automation-fabric-docker-deploy, blob:automation-fabric
anychat              → wiki:AnyChat, deploy:anychat-docker-deploy, blob:anyChat
real-time            → wiki:Real-Time-Monitor, deploy:realtime-docker-deploy, blob:real-time
website              → wiki:Website-Taqyeem, deploy:NONE, swa:swa-brokershub-latam, blob:website
tech4all             → wiki:Tech4All, deploy:NONE, blob:tech4all
kever-rachel         → wiki:Kever-Rachel, deploy:NONE, blob:NONE
hey-seven            → wiki:NONE, deploy:NONE, blob:NONE
qc-telephony-api     → wiki:QC-Telephony, deploy:NONE, blob:NONE
```

Slugs derived from directory basename under `~/projects/`. If `pwd` doesn't match any project, skip Phase 3.7 entirely.

## Artifact Locations

| Artifact | Check Path | Exists If |
|----------|-----------|-----------|
| Wiki KB | ADO wiki (check via `az devops wiki page show`) | wiki != NONE |
| Deploy repo | `~/deploy-repos/{deploy-slug}/` | deploy != NONE |
| Architecture diagram | Azure Blob `{blob-slug}/system-arch-interactive.html` | blob != NONE |
| CEO report | `~/ceo-report-v3.html` | Always (single file) |
| Portfolio diagram | `~/handover-diagrams/portfolio-macro-interactive.json` | Always (single file) |
| status.json | `{project}/.claude/status.json` | Always (per-project) |

## Change Classification

Classify session changes to determine which artifacts need checking.

### Step 1: Get changed files

```bash
git diff --name-only HEAD~5 2>/dev/null
```

### Step 2: Classify by signal

| Signal | Classification | Artifacts to Check |
|--------|---------------|--------------------|
| Only existing files modified, small diffs (<50 lines total) | `bugfix` | status.json only |
| New files in `src/` or `shared/` | `structural` | Wiki, deploy repo, diagram |
| `requirements.txt`, `Dockerfile`, `host.json` changed | `deploy` | Deploy repo, wiki (ops section) |
| `function_app.py` routes changed, new endpoints | `api` | Wiki (API section), diagram |
| New cron/schedule, timer triggers | `operations` | Wiki (ops section), deploy repo |
| Only `docs/`, `README`, `.md` files | `docs-only` | Skip (no artifact drift) |
| Only test files (`tests/`, `test_*`) | `tests-only` | Skip (no artifact drift) |

Multiple classifications can apply (e.g., `structural` + `deploy`).

### Step 3: Check rules per artifact

| Artifact | When to Flag | What to Check |
|----------|-------------|---------------|
| Wiki KB | `structural`, `api`, `operations` | New modules/scripts not documented, changed endpoints, new schedules |
| Deploy repo | `deploy`, `operations` | New deps in requirements.txt, new scripts, new env vars, Dockerfile changes |
| Architecture diagram | `structural` (new modules/services only) | New service boxes, new data flows |
| CEO report | Never auto-flag (status changes only on request) | — |
| Portfolio diagram | Never auto-flag (status changes only on request) | — |
| status.json | Always | Update with session state (handled by Phase 3.5) |

## Check Commands

### Wiki KB

```bash
# Verify wiki exists for project
az devops wiki page show --wiki Corp-AI.wiki \
  --path "/{wiki-name}" --org https://dev.azure.com/Corp-domain \
  --project Corp-AI --query "page.path" -o tsv 2>/dev/null
```

If wiki exists, flag when:
- New files in `src/` or `shared/` not mentioned in wiki content
- New scripts (`.sh`, `.py` in root) not in Operations section
- Changed endpoints not in API section

### Deploy Repo

```bash
# Check deploy repo exists
ls ~/deploy-repos/{deploy-slug}/docker-compose.yml 2>/dev/null
```

If deploy repo exists, flag when:
- `requirements.txt` changed (new deps may need Docker rebuild)
- New `.sh` scripts added (may need copying to deploy repo)
- `host.json`, `local.settings.json` changed (deploy config drift)
- New environment variables referenced in code

### Architecture Diagram

Only flag for `structural` changes that add new modules or services. Bug fixes and small edits never trigger diagram updates.

## Output Format

### Clean (no gaps)

```
=== Handover Alignment Check ===
Project: {project-name}
Changes: {N} files ({M} modified, {K} new)
Classification: {bugfix|structural|deploy|api|operations}

  [OK] Wiki KB — No drift detected
  [OK] Deploy repo — No drift detected
  [--] Diagram — Skipped (bug fix, no new modules)
  [--] CEO report — Skipped (status unchanged)
  [OK] status.json — Updated

Alignment: CLEAN (0 gaps)
```

### Gaps found

```
=== Handover Alignment Check ===
Project: {project-name}
Changes: {N} files ({M} modified, {K} new)
Classification: {classification}

  [!!] Wiki KB — NEEDS UPDATE
       -> New email_health.sh not documented in Operations section
       -> Action: Add email pipeline health check to wiki
  [OK] Deploy repo — No drift detected
  [--] Diagram — Skipped (bug fix, no new modules)
  [--] CEO report — Skipped (status unchanged)
  [OK] status.json — Updated

Alignment: {N} GAPS FOUND
  P0: Update wiki Operations section with new script
```

### Artifact missing (no deploy repo configured)

```
  [--] Deploy repo — N/A (no deploy repo for this project)
```

### Not a project directory

```
Phase 3.7: Handover Alignment Check — SKIPPED (not in a project directory)
```
