# Docker Compose, Pipeline, and Build Templates

## docker-compose.yml Template (BACKEND ONLY)

**NOTE**: Frontend deploys to Azure Static Web Apps, NOT Docker.
docker-compose.yml contains ONLY the backend service.

```yaml
# <PROJECT> - Docker Compose (Backend Only)
#
# Production: Backend runs on Azure Container Apps (Docker).
#             Frontend runs on Azure Static Web Apps (NOT Docker).
#
# This file is for local testing of the backend only.

services:
  api:
    build:
      context: ./<backend-dir>    # "." if backend at root, "./backend" if subdir
      dockerfile: Dockerfile
    container_name: <project>-api
    ports:
      - "<BACKEND_PORT>:<BACKEND_PORT>"
    environment:
      # REQUIRED — sysadmin must set these in .env file
      <ENV_VARS_LIST>
      # Runtime config
      ENVIRONMENT: ${ENVIRONMENT:-development}
      LOG_LEVEL: ${LOG_LEVEL:-INFO}
      # CORS — allow SWA frontend domain
      DASHBOARD_URL: https://<FRONTEND_DOMAIN>
    env_file:
      - .env
    volumes:
      # Only if persistent data needed (logs, reports, uploads)
      - ./<data-dir>:/app/<data-dir>
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:<BACKEND_PORT>/health"]
      interval: 30s
      timeout: 10s
      start_period: 10s   # Use 60s for Azure Functions
      retries: 3
    restart: unless-stopped
    networks:
      - app-network

  # ========================================================================
  # Frontend — Azure Static Web Apps (NOT Docker)
  # ========================================================================
  # Production: Deployed as static export to Azure Static Web Apps
  #   cd <frontend-dir> && npm ci && NEXT_PUBLIC_API_URL=https://<BACKEND_DOMAIN> npm run build
  #   swa deploy ./out --deployment-token <token>
  #
  # The frontend calls https://<BACKEND_DOMAIN>
  # CORS + CSP already configured for this connection.
  # ========================================================================

networks:
  app-network:
    driver: bridge
```

## .dockerignore Template

```
# Version control
.git
.gitignore

# Python
.venv
venv
__pycache__
*.pyc
*.pyo
.pytest_cache
.coverage
htmlcov/

# Node.js
node_modules/

# Secrets — NEVER include in images
.env
.env.*
!.env.template
local.settings.json

# IDE
.vscode
.idea

# Tests
tests/
test/
*.test.*
*.spec.*
e2e/
test-results/
playwright-report/

# Documentation
*.md
docs/

# CI/CD
azure-pipelines.yml

# Claude Code
.claude/

# Temp/build artifacts
*.log
*.tmp
screenshots/

# Frontend (excluded from backend build — frontend has its own .dockerignore)
dashboard/
frontend/
frontend-*/
ui/
web/
```

## azure-pipelines.yml Template

```yaml
trigger:
  branches:
    include:
      - main

variables:
  # REPLACE: Get service connection ID from Azure DevOps Project Settings > Service connections
  # Navigate to: https://dev.azure.com/Corp-domain/Corp-AI/_settings/adminservices
  dockerRegistryServiceConnection: '<REPLACE_WITH_SERVICE_CONNECTION_ID>'
  imageRepository: '<image-name>'
  containerRegistry: 'sentimarkregistry.azurecr.io'
  dockerfilePath: '$(Build.SourcesDirectory)/Dockerfile'
  vmImageName: 'ubuntu-latest'
  keepTags: 2

stages:
  - stage: BuildImage
    displayName: Build and Push Docker Image
    jobs:
      - job: Build
        displayName: Build
        pool:
          vmImage: $(vmImageName)
        steps:
          - script: |
              BRANCH_NAME=$(echo "$(Build.SourceBranchName)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]/-/g')
              echo "##vso[task.setvariable variable=ENV]$BRANCH_NAME"
            displayName: 'Get Branch Name'

          - task: Docker@2
            displayName: Build and Push Image
            inputs:
              command: buildAndPush
              repository: $(imageRepository)
              dockerfile: $(dockerfilePath)
              containerRegistry: $(dockerRegistryServiceConnection)
              tags: |
                $(Build.BuildId)-$(ENV)
                $(ENV)

          - task: AzureCLI@2
            displayName: 'Clean Old Tags (Keep $(keepTags))'
            inputs:
              azureSubscription: $(dockerRegistryServiceConnection)
              scriptType: bash
              scriptLocation: inlineScript
              inlineScript: |
                TAGS=$(az acr repository show-tags \
                  --name sentimarkregistry \
                  --repository $(imageRepository) \
                  --orderby time_desc \
                  --output tsv)
                COUNT=0
                for TAG in $TAGS; do
                  COUNT=$((COUNT + 1))
                  if [ $COUNT -gt $(keepTags) ]; then
                    echo "Deleting old tag: $TAG"
                    az acr repository delete \
                      --name sentimarkregistry \
                      --image "$(imageRepository):$TAG" \
                      --yes 2>/dev/null || true
                  fi
                done
```

## STORAGE-INFO.txt Template

After Phase 1 discovery, generate a plain-text file summarizing all storage dependencies.
This is a "stupid simple" text file the sysadmin can read in 10 seconds.

**Process**:
1. Scan code for ALL storage references: Cosmos DB, Blob Storage, PostgreSQL, Redis, Azure Files, local volumes
2. For each storage found, extract: service type, account name, endpoint, database/container names
3. For each storage NOT found, explicitly say "No X" to prevent follow-up questions
4. Keep it plain text, no markdown, no tables — just lines a sysadmin can grep

**Template**:

```
<PROJECT_NAME> - Storage Usage
==============================

<For each storage service found, one block like:>

Uses: Azure Cosmos DB
  Account:  <account-name>
  Endpoint: <endpoint-url>
  Database: <database-name>
  Containers: <comma-separated list>
  Auth: <env var names for connection>

<For each storage service NOT used, one line like:>

No Blob Storage. No PostgreSQL. No Redis. No queues. No Azure Files.

What the container needs:
  - <network access requirements>
  - <env vars needed>

That's it.
```

**Rules**:
- Check `requirements.txt` / `package.json` for storage SDKs (azure-cosmos, azure-storage-blob, psycopg2, redis, etc.)
- Check code for `os.getenv("*STORAGE*")`, `os.getenv("*BLOB*")`, `os.getenv("*REDIS*")`, etc.
- Check docker-compose.yml for volume mounts (mention if local-only, not a storage service)
- If a volume mount exists, mention it but clarify it's container-local, not an Azure service
- Write to `STORAGE-INFO.txt` in project root
