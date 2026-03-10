---
name: gcp-status
description: Check GCP resource status — Cloud Run services, Cloud SQL, secrets, builds. Triggers on "GCP status", "check GCP", "cloud run status", "/gcp-status".
allowed-tools: Bash
metadata:
  version: 1.0.0
  author: odedbe
---

# GCP Status Check

Run these commands to get a full picture of GCP resource health.

## Cloud Run Services

```bash
# List all services
gcloud run services list --region=us-central1 --format="table(name, status.url, status.traffic[0].revisionName, status.traffic[0].percent)"

# Describe specific service
gcloud run services describe SERVICE --region=us-central1 --format="yaml(status)"

# Recent logs (last 30 min)
gcloud run services logs read SERVICE --region=us-central1 --limit=50
```

## Cloud SQL

```bash
# Instance status
gcloud sql instances describe INSTANCE --format="table(name, state, settings.tier, ipAddresses)"

# Database list
gcloud sql databases list --instance=INSTANCE

# Connection name (for Cloud Run)
gcloud sql instances describe INSTANCE --format="value(connectionName)"
```

## Secret Manager

```bash
# List all secrets
gcloud secrets list --format="table(name, createTime)"

# Check specific secret (exists + has versions)
gcloud secrets versions list SECRET_NAME --format="table(name, state, createTime)" --limit=3
```

## Cloud Build (CI/CD)

```bash
# Recent builds
gcloud builds list --limit=5 --format="table(id, status, startTime, source.repoSource.branchName)"

# Specific build logs
gcloud builds log BUILD_ID
```

## Agent Engine

```bash
# List deployed agents
gcloud ai agent-engines list --region=us-central1

# Describe agent
gcloud ai agent-engines describe AGENT_ID --region=us-central1
```

## Quick Health Summary

```bash
echo "=== Cloud Run ==="
gcloud run services list --region=us-central1 --format="table(name, status.url)" 2>/dev/null || echo "No services"

echo ""
echo "=== Cloud SQL ==="
gcloud sql instances list --format="table(name, state, region)" 2>/dev/null || echo "No instances"

echo ""
echo "=== Recent Builds ==="
gcloud builds list --limit=3 --format="table(id, status, startTime)" 2>/dev/null || echo "No builds"

echo ""
echo "=== Secrets ==="
gcloud secrets list --format="table(name)" 2>/dev/null | head -10 || echo "No secrets"
```
