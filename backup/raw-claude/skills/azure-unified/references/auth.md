# Azure Authentication Reference

## 1. SSH Configuration (Preferred Method)

### SSH Key Location
```
Private: ~/.ssh/azure-devops
Public:  ~/.ssh/azure-devops.pub
```

### Verify SSH Connection
```bash
# Test connection (expect "Shell access is not supported" = SUCCESS)
ssh -T git@ssh.dev.azure.com

# Test git access
git ls-remote git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<repo-name>
```

### Azure DevOps SSH Fingerprints (for verification)
```
MD5:    97:70:33:82:fd:29:3a:73:39:af:6a:07:ad:f8:80:49 (RSA)
SHA256: ohD8VZEXGWo6Ez8GSEJQ9WpafgLFsOfLOtGGQCQo6Og (RSA)
```

### SSH URL Format
```bash
# Clone via SSH
git clone git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<repo-name>

# Add SSH remote to existing project
git remote add azure git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<repo-name>
```

---

## 1b. PAT Authentication (Fallback for Entra ID Conditional Access)

When SSH fails with `VS403463: The conditional access policy defined by your Microsoft Entra administrator has failed`, use the PAT method.

### Global PAT Configuration
The PAT is configured globally in `~/.git-credentials` with credential helper:
```bash
# Already configured - credentials stored in ~/.git-credentials
git config --global credential.helper store
```

### PAT Details
| Setting | Value |
|---------|-------|
| **PAT** | Stored in `~/.git-credentials` (NEVER hardcode -- Rule 9) |
| **Credentials File** | `~/.git-credentials` |
| **Scope** | Code (Read & Write) |
| **Retrieve** | `grep dev.azure.com ~/.git-credentials` |

### Using PAT for Git Operations
```bash
# Standard push (credentials auto-retrieved from ~/.git-credentials)
git push https://dev.azure.com/Corp-domain/Corp-AI/_git/<repo-name> <branch>

# Or add HTTPS remote alongside SSH
git remote add azure-https https://dev.azure.com/Corp-domain/Corp-AI/_git/<repo-name>
git push azure-https <branch>

# Explicit PAT in URL (if credential store fails)
git push https://Corp-domain:Do91Zj6jhui7kJ5MyHJEDufXK0EvoQndMBjMlIqOjavj4v5wAXbGJQQJ99BLACAAAAAMx44GAAASAZDO2cBP@dev.azure.com/Corp-domain/Corp-AI/_git/<repo-name> <branch>
```

### Troubleshooting Auth Issues
| Error | Cause | Solution |
|-------|-------|----------|
| `VS403463` | Entra conditional access blocking SSH | Use PAT via HTTPS |
| `403 Forbidden` | PAT expired or wrong scope | Create new PAT at dev.azure.com/_usersSettings/tokens |
| `Authentication failed` | Credential helper misconfigured | Check `~/.git-credentials` format |

---

## 5. SSO (Azure AD/Entra ID)

### Enable Easy Auth on Static Web App
```bash
# Configure authentication
az staticwebapp update -g AZAI_group -n <app-name> \
  --auth-providers "aad" \
  --aad-client-id "<app-registration-client-id>" \
  --aad-tenant-id "<tenant-id>"
```

### App Registration Setup
1. Azure Portal > Microsoft Entra ID > App registrations
2. New registration > Name: `<app-name>-auth`
3. Supported account types: "Accounts in this organizational directory only"
4. Redirect URI: `https://<app-url>/.auth/login/aad/callback`
5. Copy Application (client) ID and Directory (tenant) ID

### Restrict to Org Users Only
In App Registration > Authentication:
- Set "Supported account types" to "Single tenant"
- In Enterprise Applications > Properties: "Assignment required?" = Yes
- Add allowed users/groups under "Users and groups"

**Sysadmin Sister** approves user access requests.

---

## 10. Workload Identity Federation (Pipeline Auth)

Azure DevOps pipelines use **Workload Identity Federation** (WIF) for secure, secret-less authentication to Azure resources. This replaces service principal secrets.

### Current Setup

| Component | Value |
|-----------|-------|
| **Managed Identity** | `mi-marketing-newsletter-devops` |
| **Client ID** | `ced958d1-202d-49c7-98e4-e31b24701177` |
| **Principal ID** | `a14aec04-1f24-458d-87a1-4f2b16c98034` |
| **Issuer** | `https://login.microsoftonline.com/318030de-752f-42b3-9848-abd6ec3809e3/v2.0` |
| **Service Connection** | `U-BTech - CSP (Z-Online)` |

### Adding a New Pipeline to WIF

When creating a new pipeline that uses the shared service connection, you must add a federated credential:

```bash
# 1. Get the service connection's subject (from Azure DevOps)
az devops service-endpoint show \
  --id 1bc9c0d9-d540-45c7-9e1f-f72315e3b3b8 \
  --org https://dev.azure.com/Corp-domain \
  --project Corp-AI \
  --query "authorization.parameters.workloadIdentityFederationSubject" -o tsv

# 2. Add federated credential to managed identity
az identity federated-credential create \
  --name "<pipeline-name>" \
  --identity-name "mi-marketing-newsletter-devops" \
  --resource-group "AZAI_group" \
  --issuer "https://login.microsoftonline.com/318030de-752f-42b3-9848-abd6ec3809e3/v2.0" \
  --subject "<subject-from-step-1>" \
  --audience "api://AzureADTokenExchange"

# 3. Verify RBAC permissions (requires admin)
az role assignment create \
  --assignee a14aec04-1f24-458d-87a1-4f2b16c98034 \
  --role "Contributor" \
  --scope "/subscriptions/08b0ac81-a17e-421c-8c1b-41b59ee758a3/resourceGroups/AZAI_group"
```

### Common WIF Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `AADSTS70025: no configured federated identity credentials` | Missing federated credential | Add credential with `az identity federated-credential create` |
| `403: does not have authorization to perform action` | Missing RBAC role | Admin must assign Contributor role to managed identity |
| `invalid_client` | Wrong issuer or subject | Verify issuer/subject match service connection config |

### Troubleshooting WIF

```bash
# List federated credentials
az identity federated-credential list \
  --identity-name mi-marketing-newsletter-devops \
  -g AZAI_group -o table

# Check role assignments
az role assignment list \
  --assignee a14aec04-1f24-458d-87a1-4f2b16c98034 \
  --all -o table

# View service connection details
az devops service-endpoint show \
  --id 1bc9c0d9-d540-45c7-9e1f-f72315e3b3b8 \
  --org https://dev.azure.com/Corp-domain \
  --project Corp-AI
```

### Pipelines Using This WIF Setup

| Pipeline | Repository | Federated Credential |
|----------|------------|---------------------|
| marketing-newsletter | Seekapa-AI-Assistance | (original) |
| sentimark-backend-deploy | sentimark | `sentimark-backend-deploy` |

### Requesting Admin Access

If you get `403: does not have authorization` for role assignments, ask **Sysadmin Sister** to:
1. Go to Azure Portal -> AZAI_group -> Access control (IAM)
2. Add role assignment -> Contributor
3. Assign to: `mi-marketing-newsletter-devops`

---

## 11. Kudu API Deployment (No ARM/RBAC Required)

**IMPORTANT**: When you lack permissions to create service connections or assign RBAC roles, use **Kudu Zip Deploy API** with publish profile credentials. This bypasses all ARM authentication.

### When to Use Kudu API

| Scenario | Solution |
|----------|----------|
| No permission to create service connections | Use Kudu API |
| `AzureFunctionApp@2` fails with 403 | Use Kudu API |
| Managed identity lacks ARM permissions | Use Kudu API |
| `mi-marketing-newsletter-devops` can't access your app | Use Kudu API |

### Critical Insight: Managed Identity Scope

**`mi-marketing-newsletter-devops` is app-specific** to Marketing Newsletter, NOT shared infrastructure. It only has permissions for Marketing Newsletter resources. For other apps like Sentimark, use Kudu API or request a dedicated managed identity.

### Get Publish Profile Credentials

```bash
# From Azure Portal:
# Function App -> Overview -> Get publish profile -> Download file

# Or via Azure CLI (requires Contributor on app):
az functionapp deployment list-publishing-profiles \
  -g AZAI_group -n <app-name> --xml
```

The publish profile contains:
- Username: `$<app-name>` (e.g., `$polymarket-analyzer`)
- Password: A long base64 string
- Kudu URL: `<app-name>.scm.azurewebsites.net`

### Azure Pipeline with Kudu API

```yaml
# azure-pipelines.yml - Kudu API (no service connection needed)
trigger:
  branches:
    include:
      - main
      - master

variables:
  - name: functionAppName
    value: '<app-name>'
  - name: kuduUser
    value: '$<app-name>'  # From publish profile
  - name: kuduUrl
    value: 'https://<app-name>.scm.azurewebsites.net/api/zipdeploy'

stages:
  - stage: Build
    jobs:
      - job: BuildFunctionApp
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: UsePythonVersion@0
            inputs:
              versionSpec: '3.11'

          - script: |
              mkdir -p $(Build.ArtifactStagingDirectory)/deploy
              cp function_app.py $(Build.ArtifactStagingDirectory)/deploy/
              cp requirements.txt $(Build.ArtifactStagingDirectory)/deploy/
              cp host.json $(Build.ArtifactStagingDirectory)/deploy/
              cp -r shared $(Build.ArtifactStagingDirectory)/deploy/
            displayName: 'Create deployment package'

          - task: ArchiveFiles@2
            inputs:
              rootFolderOrFile: '$(Build.ArtifactStagingDirectory)/deploy'
              includeRootFolder: false
              archiveType: 'zip'
              archiveFile: '$(Build.ArtifactStagingDirectory)/app.zip'

          - publish: '$(Build.ArtifactStagingDirectory)/app.zip'
            artifact: 'app-package'

  - stage: Deploy
    dependsOn: Build
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/master'))
    jobs:
      - deployment: DeployFunctionApp
        pool:
          vmImage: 'ubuntu-latest'
        environment: 'production'
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: 'app-package'

                - script: |
                    HTTP_STATUS=$(curl -s -o /tmp/response.txt -w "%{http_code}" \
                      -X POST \
                      -u "$(kuduUser):$(KUDU_PASSWORD)" \
                      --data-binary @$(Pipeline.Workspace)/app-package/app.zip \
                      -H "Content-Type: application/zip" \
                      "$(kuduUrl)?isAsync=false")

                    if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "202" ]; then
                      echo "Deployment successful (HTTP $HTTP_STATUS)"
                    else
                      echo "Deployment failed (HTTP $HTTP_STATUS)"
                      cat /tmp/response.txt
                      exit 1
                    fi
                  displayName: 'Deploy via Kudu API'
                  env:
                    KUDU_PASSWORD: $(KUDU_PASSWORD)
```

### Add KUDU_PASSWORD Secret

1. Azure DevOps -> Your Pipeline -> Edit -> Variables
2. Click "New variable"
3. Name: `KUDU_PASSWORD`
4. Value: Password from publish profile
5. Check "Keep this value secret"
6. Save

### Local Deployment Script

```bash
#!/bin/bash
# deploy-kudu.sh - Local deployment using Kudu API
set -e

TEMP_DEPLOY=$(mktemp -d)
trap "rm -rf $TEMP_DEPLOY" EXIT

echo "Creating deployment package..."
cp ~/projects/<project>/function_app.py "$TEMP_DEPLOY/"
cp ~/projects/<project>/requirements.txt "$TEMP_DEPLOY/"
cp ~/projects/<project>/host.json "$TEMP_DEPLOY/"
cp -r ~/projects/<project>/shared "$TEMP_DEPLOY/"

cd "$TEMP_DEPLOY"
zip -rq deploy.zip .

echo "Deploying..."
HTTP_STATUS=$(curl -s -o /tmp/response.txt -w "%{http_code}" \
  -X POST \
  -u '$<app-name>:<password-from-publish-profile>' \
  --data-binary @deploy.zip \
  -H "Content-Type: application/zip" \
  "https://<app-name>.scm.azurewebsites.net/api/zipdeploy?isAsync=false")

if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "202" ]; then
  echo "Deployment successful"
else
  echo "Failed: HTTP $HTTP_STATUS"
  cat /tmp/response.txt
  exit 1
fi
```

### Kudu API vs AzureFunctionApp Task

| Aspect | Kudu API | AzureFunctionApp@2 |
|--------|----------|-------------------|
| Auth | Publish profile | Service connection (WIF/SP) |
| ARM permissions | Not needed | Required |
| Service connection | Not needed | Required |
| RBAC roles | Not needed | Contributor on resource |
| Setup complexity | Low (just add secret) | High (WIF config) |
| Security | App-scoped | Subscription/RG scoped |
