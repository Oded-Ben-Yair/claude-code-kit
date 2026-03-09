---
name: gcp-rollback
description: Rollback Cloud Run or Agent Engine deployments. Triggers on "rollback", "revert deploy", "undo deploy", "/gcp-rollback".
argument-hint: [SERVICE] [--to-revision=NAME]
allowed-tools: Bash
metadata:
  version: 1.0.0
  author: odedbe
---

# GCP Rollback

## Cloud Run Rollback

### Step 1: List Revisions

```bash
gcloud run revisions list --service=SERVICE --region=us-central1 \
    --format="table(name, status.conditions[0].status, metadata.creationTimestamp)" \
    --sort-by="~metadata.creationTimestamp" \
    --limit=5
```

### Step 2: Identify Target Revision

The second entry is typically the last known good revision. Verify:

```bash
# Check revision details
gcloud run revisions describe REVISION_NAME --service=SERVICE --region=us-central1
```

### Step 3: Shift Traffic

```bash
# Instant rollback — 100% traffic to previous revision
gcloud run services update-traffic SERVICE \
    --to-revisions=PREVIOUS_REVISION=100 \
    --region=us-central1
```

### Step 4: Verify

```bash
# Confirm traffic shift
gcloud run services describe SERVICE --region=us-central1 \
    --format="yaml(status.traffic)"

# Health check
curl -s https://SERVICE-URL/health | python3 -m json.tool
```

## Canary Rollback (Gradual)

```bash
# Split traffic: 90% old, 10% new (for testing)
gcloud run services update-traffic SERVICE \
    --to-revisions=OLD_REV=90,NEW_REV=10

# If new is bad, shift back to 100% old
gcloud run services update-traffic SERVICE \
    --to-revisions=OLD_REV=100
```

## Agent Engine Rollback

Agent Engine doesn't have revision-based rollback. Delete and redeploy.

```bash
# 1. Delete current agent
gcloud ai agent-engines delete AGENT_ID --region=us-central1

# 2. Checkout previous code version
git checkout PREVIOUS_COMMIT

# 3. Redeploy (use gcp-deploy skill)
```

## Emergency: Disable Service

```bash
# Block all traffic (503 to all requests)
gcloud run services update SERVICE \
    --no-traffic --region=us-central1

# Re-enable
gcloud run services update-traffic SERVICE \
    --to-latest --region=us-central1
```

## Post-Rollback

1. Verify health endpoint returns expected version
2. Check logs for errors: `gcloud run services logs read SERVICE --limit=20`
3. Investigate root cause before re-deploying
4. If DB migration was involved, check if rollback migration is needed
