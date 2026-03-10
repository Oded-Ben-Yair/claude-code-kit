After ANY deployment to GCP Cloud Run:

### Pre-deploy snapshot (BEFORE deploying):
1. Hit 2-3 key API endpoints and save response snippets
2. Record current behavior that you expect to CHANGE

### Post-deploy verification (AFTER Cloud Build completes):
1. Wait 30 seconds for new revision to become active
2. Verify new revision is serving:
```bash
gcloud run services describe SERVICE_NAME --region REGION \
  --format='value(status.traffic[0].revisionName)'
```
3. Hit the SAME endpoints from pre-deploy snapshot
4. Compare: did the behavior ACTUALLY change?
5. If behavior is IDENTICAL to pre-deploy, the fix likely missed root cause or deployment didn't take effect — do NOT claim success

### Red flags:
- Cloud Build returned success BUT revision not serving traffic — investigate
- Health endpoint returns 200 BUT instance count is 0 — check min-instances config
- Tests pass locally BUT production uses different env vars — check Secret Manager config
- New revision deployed BUT traffic still routed to old revision — check traffic splitting
