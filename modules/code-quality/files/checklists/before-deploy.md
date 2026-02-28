# Before Deploy Checklist

Surface when: deploying, pushing to production, `git push`, pipeline trigger.

## Pre-Deploy

- [ ] All changes committed (`git status` -- zero modified production files)
- [ ] Latest commit includes your changes (`git log --oneline -1`)
- [ ] Pushed to remote (`git push origin <branch>`)
- [ ] Bump version in code BEFORE committing (for post-deploy version assertion)

## Pre-Deploy Snapshot

- [ ] Hit 2-3 key API endpoints and save response snippets
- [ ] Record current behavior you expect to CHANGE

## Wait for Pipeline

- [ ] Verify CI/CD pipeline was triggered
- [ ] Wait for pipeline completion -- do NOT verify before it completes
- [ ] For large apps: use async deploy with polling if available

## Post-Deploy Verification

- [ ] Wait 60 seconds for cold start
- [ ] `curl` health endpoint -- assert version matches deployed version
- [ ] Hit the SAME endpoints from pre-deploy snapshot
- [ ] Compare: did behavior ACTUALLY change? (identical = fix missed or deploy didn't take)
- [ ] Check service health via health endpoint

## Red Flags

- Deploy CLI succeeded BUT endpoint behavior unchanged -- investigate
- Health returns 200 BUT service is degraded -- deployment broke something
- Tests pass locally BUT production uses different config -- check deployed config
- Old code persists on warm instances after deploy -- verify version endpoint

## References

- Deploy rules in your project's CLAUDE.md or devops module
