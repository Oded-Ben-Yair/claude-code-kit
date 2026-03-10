# Azure Static Web Apps & Pipelines

## Static Web Apps Deployment

```bash
# Deploy via SWA CLI
swa deploy ./build --deployment-token <token>

# Or via Azure Pipelines (preferred):
# See pipeline templates below
```

---

## Azure Pipelines Templates

### Static Web App (Next.js)
```yaml
# azure-pipelines.yml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: NodeTool@0
    inputs:
      versionSpec: '20.x'

  - script: npm ci
    displayName: 'Install dependencies'

  - script: npm run build
    displayName: 'Build'

  - task: AzureStaticWebApp@0
    inputs:
      app_location: '/'
      output_location: 'out'
      azure_static_web_apps_api_token: $(AZURE_STATIC_WEB_APPS_API_TOKEN)
```

### Function App (Python)
```yaml
# azure-pipelines.yml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: UsePythonVersion@0
    inputs:
      versionSpec: '3.11'

  - script: |
      python -m pip install --upgrade pip
      pip install -r requirements.txt
    displayName: 'Install dependencies'

  - task: ArchiveFiles@2
    inputs:
      rootFolderOrFile: '$(Build.SourcesDirectory)'
      includeRootFolder: false
      archiveType: 'zip'
      archiveFile: '$(Build.ArtifactStagingDirectory)/$(Build.BuildId).zip'

  - task: AzureFunctionApp@2
    inputs:
      azureSubscription: '<service-connection>'
      appType: 'functionAppLinux'
      appName: '<function-app-name>'
      package: '$(Build.ArtifactStagingDirectory)/$(Build.BuildId).zip'
      runtimeStack: 'PYTHON|3.11'
```
