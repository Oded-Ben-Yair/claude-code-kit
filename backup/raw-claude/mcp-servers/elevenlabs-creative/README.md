# ElevenLabs Creative Platform MCP Server

MCP server for ElevenLabs Creative Platform integration with Claude Code.

## Features

### Working Tools (Documented APIs)
- `elevenlabs_tts` - Text-to-speech generation with voice selection
- `elevenlabs_list_voices` - List available voices (premade + cloned)
- `elevenlabs_get_voice` - Get voice details
- `elevenlabs_list_models` - List TTS models

### Placeholder Tools (Beta - Web UI Only)
These tools are defined but return guidance to use the web UI since the APIs are not yet public:
- `elevenlabs_generate_image` - Image generation (Nano Banana, Flux, Seedream, etc.)
- `elevenlabs_generate_video` - Video generation (Sora 2, Veo 3.1, Kling, etc.)
- `elevenlabs_lip_sync` - Lip sync with OmniHuman/Veed
- `elevenlabs_upscale` - Topaz upscaling

## Installation

```bash
cd ~/.claude/mcp-servers/elevenlabs-creative
npm install
npm run build
```

## Configuration

1. Copy `.env.example` to `.env`
2. Add your ElevenLabs API key

```bash
cp .env.example .env
# Edit .env and add your API key
```

### Add to Claude Code settings.json

```json
{
  "mcpServers": {
    "elevenlabs-creative": {
      "command": "node",
      "args": ["/home/odedbe/.claude/mcp-servers/elevenlabs-creative/dist/index.js"],
      "env": {
        "ELEVENLABS_API_KEY": "${ELEVENLABS_API_KEY}"
      }
    }
  }
}
```

## Usage Examples

### Text-to-Speech
```
Use elevenlabs_tts to convert "Hello world" to speech using the Rachel voice
```

### List Voices
```
Use elevenlabs_list_voices to show all available voices
```

### Image/Video Generation (Beta)
Since the API is not public yet, the tools will redirect you to use the web UI at:
https://elevenlabs.io/image-video

## Models

### TTS Models
| Model | Description |
|-------|-------------|
| eleven_multilingual_v2 | Best quality, supports 29 languages |
| eleven_turbo_v2_5 | Fast, optimized for real-time |
| eleven_flash_v2_5 | Fastest, lowest latency |

### Image Models (Beta - Web UI)
| Model | Best For |
|-------|----------|
| Nano Banana | General purpose |
| Seedream 4 | Artistic styles |
| GPT Image 1 | Detailed prompts |
| Flux | Photorealistic |
| Wan | Artistic |

### Video Models (Beta - Web UI)
| Model | Duration | Features |
|-------|----------|----------|
| Sora 2 | 4-12s | Physics-aware, audio sync |
| Veo 3.1 | 4-8s | Cinematic, integrated audio |
| Kling 2.5 | 5-10s | Complex motion |
| Seedance | Variable | Dancing/motion |
| Wan 2.5 | Variable | Artistic motion |

## Roadmap

- [ ] Image generation API (when public)
- [ ] Video generation API (when public)
- [ ] Lip sync API (when public)
- [ ] Upscaling API (when public)
- [ ] Studio project integration

## Links

- [ElevenLabs API Docs](https://elevenlabs.io/docs/api-reference)
- [Creative Platform](https://elevenlabs.io/image-video)
- [ElevenLabs Studio](https://elevenlabs.io/studio)
