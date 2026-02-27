---
name: gcp-compliance
description: Audit GCP resources for compliance and best practices
metadata:
  version: 1.0.0
  triggers:
    - compliance
    - audit
    - gcp audit
---

# GCP Compliance Audit

Audit GCP resources for security, naming conventions, and best practices.

## Checks

### 1. IAM Audit

```bash
# List project IAM bindings
gcloud projects get-iam-policy ${GCP_PROJECT} \
  --format='table(bindings.role, bindings.members)'

# Check for overly permissive roles
gcloud projects get-iam-policy ${GCP_PROJECT} \
  --flatten="bindings[].members" \
  --filter="bindings.role:roles/owner OR bindings.role:roles/editor" \
  --format='table(bindings.role, bindings.members)'
```

### 2. Secret Manager Audit

```bash
# List all secrets
gcloud secrets list --format='table(name, createTime, replication.automatic)'

# Check for secrets without rotation
gcloud secrets list --format=json | python3 -c "
import json, sys
secrets = json.load(sys.stdin)
for s in secrets:
    rotation = s.get('rotation', {})
    if not rotation.get('rotationPeriod'):
        print(f'WARNING: {s[\"name\"]} has no rotation policy')
"
```

### 3. Cloud Run Service Audit

```bash
# Check for services allowing unauthenticated access
gcloud run services list --region ${GCP_REGION:-us-central1} \
  --format='table(name, spec.template.spec.containerConcurrency)' \
  --filter='metadata.annotations["run.googleapis.com/ingress"]!=internal'

# Check for services without minimum instances
gcloud run services list --region ${GCP_REGION:-us-central1} --format=json | python3 -c "
import json, sys
services = json.load(sys.stdin)
for svc in services:
    annotations = svc.get('spec', {}).get('template', {}).get('metadata', {}).get('annotations', {})
    min_scale = annotations.get('autoscaling.knative.dev/minScale', '0')
    if min_scale == '0':
        print(f'INFO: {svc[\"metadata\"][\"name\"]} has 0 min instances (cold start risk)')
"
```

### 4. Resource Labels Audit

```bash
# Check Cloud Run services for required labels
gcloud run services list --region ${GCP_REGION:-us-central1} --format=json | python3 -c "
import json, sys
REQUIRED_LABELS = ['environment', 'team', 'project']
services = json.load(sys.stdin)
for svc in services:
    labels = svc.get('metadata', {}).get('labels', {})
    missing = [l for l in REQUIRED_LABELS if l not in labels]
    if missing:
        print(f'WARNING: {svc[\"metadata\"][\"name\"]} missing labels: {missing}')
"
```

### 5. Region Compliance

```bash
# Verify all resources are in approved regions
APPROVED_REGIONS="us-central1,us-east1,europe-west1"
gcloud run services list --format='table(name, metadata.labels.region)' \
  --filter="NOT metadata.labels.region:(${APPROVED_REGIONS})"
```

## Report

After running all checks, summarize:
- Total resources audited
- Findings by severity (CRITICAL / WARNING / INFO)
- Recommended remediations
