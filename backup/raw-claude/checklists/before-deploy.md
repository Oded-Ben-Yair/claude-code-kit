# Before Deploy Checklist

Surface when: deploying, pushing to production, `git push azure`, pipeline trigger.

## Pre-Deploy

- [ ] All changes committed (`git status` — zero modified production files)
- [ ] Latest commit includes your changes (`git log --oneline -1`)
- [ ] Pushed to Azure DevOps (`git push azure <branch>`)
- [ ] Bump version in code BEFORE committing (for post-deploy version assertion)

## Pre-Deploy Snapshot

- [ ] Hit 2-3 key API endpoints and save response snippets
- [ ] Record current behavior you expect to CHANGE

## Wait for Pipeline

- [ ] Find pipeline: `az pipelines list` — verify triggered
- [ ] Wait for pipeline completion — do NOT verify before it completes (Rule 6)
- [ ] For large apps (150+ functions): use `isAsync=true` Kudu deploy with polling

## Post-Deploy Verification

- [ ] Wait 60 seconds for cold start
- [ ] `curl` health endpoint — assert version matches deployed version
- [ ] Hit the SAME endpoints from pre-deploy snapshot
- [ ] Compare: did behavior ACTUALLY change? (identical = fix missed or deploy didn't take)
- [ ] Check function count via health endpoint (not `az functionapp function list`)

## Red Flags

- Deploy CLI succeeded BUT endpoint behavior unchanged — investigate
- Health returns 200 BUT function count is 0 — deployment broke something
- Tests pass locally BUT production uses different config — check deployed config
- Old code persists 12+ hours on Consumption Plan warm instances

## References

- `rules/azure-deploy.md`: Post-Push Pipeline Verification, End-of-Session Deployment Verification
- `rules/azure-functions.md`: Consumption Plan Awareness, Async Kudu Deploy
