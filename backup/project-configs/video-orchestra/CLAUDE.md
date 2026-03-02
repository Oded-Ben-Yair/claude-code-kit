# Video Orchestra - Claude Code Instructions

## Project Overview
Programmatic video generation pipeline combining:
- **Remotion** - React-based video rendering framework
- **HeyGen** - AI avatar video generation API
- **Claude Code** - Orchestration via skills

## Key Directories
```
video-orchestra/
├── src/
│   ├── HelloWorld/      # Default Remotion composition
│   ├── heygen/          # HeyGen API integration
│   └── Root.tsx         # Remotion root configuration
├── server/              # Render server for Container Apps
├── scripts/             # Deployment and utility scripts
├── public/              # Static assets (images, fonts, audio)
├── .claude/             # Project state tracking
└── out/                 # Rendered video output (gitignored)
```

## Commands
```bash
npm run dev           # Start Remotion Studio (localhost:3000)
npm run build         # Bundle for production
npm run render        # Render HelloWorld to out/hello-world.mp4
npm run render:preview # Render 1-second preview
npm run lint          # Run ESLint + TypeScript check
npm run heygen:test   # Test HeyGen API connection
```

## Azure Infrastructure

### Storage Account: `stvideoorchestrap`
| Container | Purpose |
|-----------|---------|
| `assets` | Input assets (images, audio, fonts) |
| `outputs` | Rendered video files |
| `heygen-cache` | Cached HeyGen avatar videos |

### Container App: `video-orchestra-renderer`
- **URL**: https://video-orchestra-renderer.victoriousbeach-8c9d46fb.swedencentral.azurecontainerapps.io
- **Environment**: sentimark-env
- **Resources**: 2 vCPU, 4GB RAM
- **Scale**: 0-3 replicas (scales to zero when idle)

### Render API Endpoints
```bash
# Health check
curl https://video-orchestra-renderer.victoriousbeach-8c9d46fb.swedencentral.azurecontainerapps.io/health

# Start render job
curl -X POST .../render -H 'Content-Type: application/json' \
  -d '{"compositionId": "HelloWorld", "props": {}}'

# Check job status
curl .../status/{jobId}
```

### Deployment
```bash
./scripts/deploy-to-azure.sh [tag]
```

## API Keys (Key Vault: `kv-seekapa-apps`)
| Secret Name | Purpose |
|-------------|---------|
| `MarketingNewsletter-HeyGen-ApiKey` | HeyGen avatar API |
| `MarketingNewsletter-GeminiApiKey` | Captions/transcription |
| `AzureAIFoundry-ApiKey` | Script generation |
| `MarketingNewsletter-ElevenLabsApiKey` | Voice synthesis |
| `MarketingNewsletter-PerplexityApiKey` | Research |
| `VideoOrchestra-StorageConnectionString` | Azure Blob Storage |

## HeyGen Integration
Use the HeyGen skill for Claude Code for avatar video generation:
```
/heygen  # Invoke HeyGen skill
```

### HeyGen Resources
- **Avatars**: 1,289 available
- **Voices**: 2,337 available
- **Credits**: Avatar IV = 20 credits/minute (hyper-realistic)

## Remotion Compositions
Each video type is a Remotion Composition in `src/Root.tsx`:
- `HelloWorld` - Default test composition
- `OnlyLogo` - Logo animation only
- (Add more compositions as needed)

## Rendering

### Local Development
```bash
npm run dev                    # Preview in browser
npm run render                 # Full render
npm run render:preview         # Quick 1-second preview
```

### Cloud Rendering (Azure)
1. Build Docker image: `docker build -t video-orchestra .`
2. Push to ACR: `./scripts/deploy-to-azure.sh`
3. Trigger via API: `POST /render`

## Important Notes
- Never commit `.env.local` - use Key Vault references
- Check `out/` directory for rendered videos
- Container App scales to zero when idle (~$0 when not in use)
- Use `npm run dev` to preview compositions before rendering
