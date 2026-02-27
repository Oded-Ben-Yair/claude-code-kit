# GCP CLI Reference

Quick reference for common GCP operations. Maps Azure CLI equivalents where applicable.

## Authentication

```bash
# Login interactively
gcloud auth login

# Set up Application Default Credentials (for local dev)
gcloud auth application-default login

# Check current auth
gcloud auth list

# Set active project
gcloud config set project PROJECT_ID

# Get current project
gcloud config get-value project
```

## Cloud Run

```bash
# List services
gcloud run services list --region REGION

# Describe service
gcloud run services describe SERVICE_NAME --region REGION

# Deploy
gcloud run deploy SERVICE_NAME --image IMAGE_URL --region REGION

# Delete service
gcloud run services delete SERVICE_NAME --region REGION

# Get service URL
gcloud run services describe SERVICE_NAME --region REGION --format='value(status.url)'

# View logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=SERVICE_NAME" --limit=20
```

## Artifact Registry (Container Registry)

```bash
# Create repository
gcloud artifacts repositories create REPO_NAME --repository-format=docker --location=REGION

# Configure Docker auth
gcloud auth configure-docker REGION-docker.pkg.dev

# List images
gcloud artifacts docker images list REGION-docker.pkg.dev/PROJECT/REPO

# Delete image
gcloud artifacts docker images delete REGION-docker.pkg.dev/PROJECT/REPO/IMAGE:TAG
```

## Secret Manager

```bash
# Create secret
echo -n "value" | gcloud secrets create SECRET_NAME --data-file=-

# Read secret
gcloud secrets versions access latest --secret=SECRET_NAME

# List secrets
gcloud secrets list

# Update secret
echo -n "new-value" | gcloud secrets versions add SECRET_NAME --data-file=-

# Delete secret
gcloud secrets delete SECRET_NAME
```

## Cloud Build

```bash
# Submit build
gcloud builds submit --config cloudbuild.yaml

# List recent builds
gcloud builds list --limit=5

# Describe build
gcloud builds describe BUILD_ID

# Cancel build
gcloud builds cancel BUILD_ID

# View build logs
gcloud builds log BUILD_ID
```

## Cloud SQL

```bash
# List instances
gcloud sql instances list

# Connect via proxy
gcloud sql connect INSTANCE_NAME --user=USER

# Create database
gcloud sql databases create DB_NAME --instance=INSTANCE_NAME
```

## IAM

```bash
# List project IAM
gcloud projects get-iam-policy PROJECT_ID

# Add role binding
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:SA@PROJECT.iam.gserviceaccount.com" \
  --role="roles/run.admin"

# List service accounts
gcloud iam service-accounts list
```

## Logging

```bash
# Read logs
gcloud logging read "FILTER" --limit=N --format=FORMAT

# Common filters:
# resource.type=cloud_run_revision
# severity>=ERROR
# timestamp>="2024-01-01T00:00:00Z"

# Live tail (beta)
gcloud beta logging tail "FILTER"
```

## Azure to GCP Equivalents

| Azure CLI | GCP CLI |
|-----------|---------|
| `az functionapp list` | `gcloud run services list` |
| `az functionapp deployment` | `gcloud run deploy` |
| `az keyvault secret show` | `gcloud secrets versions access latest` |
| `az pipelines run` | `gcloud builds submit` |
| `az webapp log download` | `gcloud logging read` |
| `az acr build` | `gcloud builds submit` / `docker push` |
| `az group list` | `gcloud projects list` |
| `az account show` | `gcloud config get-value project` |
