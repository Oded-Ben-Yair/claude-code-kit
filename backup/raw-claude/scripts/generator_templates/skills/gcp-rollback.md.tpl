---
name: gcp-rollback
description: Roll back a Cloud Run service to a previous revision
metadata:
  version: 1.0.0
  triggers:
    - rollback
    - revert deploy
    - undo deploy
---

# GCP Rollback

Roll back a Cloud Run service to a previous known-good revision.

## Steps

### 1. List Recent Revisions

```bash
gcloud run revisions list --service ${SERVICE_NAME} \
  --region ${GCP_REGION} \
  --format='table(name, active, creation_timestamp)' \
  --limit=5
```

### 2. Identify Current and Target Revision

```bash
# Current serving revision
gcloud run services describe ${SERVICE_NAME} --region ${GCP_REGION} \
  --format='value(status.traffic[0].revisionName)'

# Select the previous good revision from the list above
TARGET_REVISION="<previous-revision-name>"
```

### 3. Route Traffic to Previous Revision

```bash
gcloud run services update-traffic ${SERVICE_NAME} \
  --region ${GCP_REGION} \
  --to-revisions $${TARGET_REVISION}=100
```

### 4. Verify Rollback

```bash
SERVICE_URL=$$(gcloud run services describe ${SERVICE_NAME} --region ${GCP_REGION} \
  --format='value(status.url)')
curl -s "$$SERVICE_URL/health" | python3 -m json.tool
```

### 5. (Optional) Delete Bad Revision

```bash
gcloud run revisions delete BAD_REVISION_NAME \
  --region ${GCP_REGION} --quiet
```

## Notes

- Rollback is instant -- Cloud Run just shifts traffic
- Old revisions remain available for 24h+ unless explicitly deleted
- If the issue is in env vars or secrets, update those separately
