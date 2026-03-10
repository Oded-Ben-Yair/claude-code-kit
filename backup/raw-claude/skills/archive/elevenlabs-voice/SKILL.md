---
name: elevenlabs-voice
description: |
  ElevenLabs Creative Platform integration including:
  - Conversational AI voice agents
  - Text-to-speech (TTS) generation
  - Voice cloning and management
  - Image generation (Beta - Nano Banana, Flux, Seedream, GPT Image)
  - Video generation (Beta - Sora 2, Veo 3.1, Kling, Seedance)
  - Lip sync and upscaling (Beta)
  - Audio processing workflows

  Keywords: elevenlabs, voice, agent, speech, tts, audio, image, video, creative platform
---

# ElevenLabs Voice Agent Development Guide

## API Reference

**Base URL**: `https://api.elevenlabs.io/v1`
**API Key**: Stored in `~/.env` as `ELEVENLABS_API_KEY`

## Key Endpoints

### Conversational AI Agents

```
POST /convai/agents                    # Create agent
GET  /convai/agents                    # List agents
GET  /convai/agents/{agent_id}         # Get agent details
PATCH /convai/agents/{agent_id}        # Update agent
DELETE /convai/agents/{agent_id}       # Delete agent
```

### Text-to-Speech

```
POST /text-to-speech/{voice_id}        # Generate speech
POST /text-to-speech/{voice_id}/stream # Stream speech
```

### Voices

```
GET /voices                            # List available voices
GET /voices/{voice_id}                 # Get voice details
```

## Agent Configuration Schema

```json
{
  "name": "Agent Name",
  "conversation_config": {
    "agent": {
      "prompt": {
        "prompt": "Your system prompt here...",
        "llm": "gpt-4o-mini",
        "temperature": 0.7
      },
      "first_message": "Hello! How can I help you today?",
      "language": "en"
    },
    "asr": {
      "provider": "elevenlabs"
    },
    "tts": {
      "model_id": "eleven_turbo_v2_5",
      "voice_id": "your-voice-id"
    },
    "turn": {
      "turn_timeout": 10,
      "mode": "turn_based"
    }
  }
}
```

## Best Practices for Voice Agents

### System Prompt Guidelines

1. **Keep it concise** - Voice interactions are time-sensitive
2. **Define personality** - Friendly, professional, etc.
3. **Set boundaries** - What the agent can/cannot do
4. **Include fallbacks** - How to handle unknown queries

### Voice Selection

| Voice Type | Use Case |
|------------|----------|
| `eleven_turbo_v2_5` | Fast, conversational |
| `eleven_multilingual_v2` | Multi-language support |

### Error Handling

- Always have graceful fallback responses
- Log conversation IDs for debugging
- Monitor latency and timeout issues

## Testing Voice Agents

### Local Testing

```python
import requests

headers = {
    "xi-api-key": "your-api-key",
    "Content-Type": "application/json"
}

# Test agent
response = requests.post(
    "https://api.elevenlabs.io/v1/convai/agents/{agent_id}/test",
    headers=headers,
    json={"message": "Test message"}
)
```

### Webhook Testing

```bash
# Verify webhook signature
curl -X POST your-webhook-url \
  -H "x-webhook-signature: $SIGNATURE" \
  -d '{"event": "conversation.ended"}'
```

## Webhook Events

| Event | Description |
|-------|-------------|
| `conversation.started` | New conversation initiated |
| `conversation.ended` | Conversation completed |
| `conversation.message` | Message received |

## Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| High latency | Model choice | Use `eleven_turbo_v2_5` |
| Voice cutoff | Short timeout | Increase `turn_timeout` |
| No response | Prompt issue | Simplify system prompt |
| Wrong language | ASR config | Set explicit language |

## Integration with Seekapa Training Platform

The training platform uses ElevenLabs for:
- Voice-based training sessions
- Real-time scoring feedback
- Session recording and playback

Key integration points:
- Agent configuration in backend
- WebSocket connection for streaming
- Session metadata storage in PostgreSQL

## Documentation Links

- [ElevenLabs Docs](https://elevenlabs.io/docs)
- [Conversational AI Guide](https://elevenlabs.io/docs/conversational-ai)
- [API Reference](https://elevenlabs.io/docs/api-reference)

---

# Creative Platform (Image & Video Generation)

> **Note**: Image & Video features are in Beta and currently available via web UI only.
> API endpoints are not yet public. This section documents workflows for the web platform.

## Overview

ElevenLabs Creative Platform brings together the best AI models for:
- **Image Generation**: Create static images from text prompts
- **Video Generation**: Create videos from text or starting images
- **Lip Sync**: Sync video with AI-generated voices
- **Upscaling**: Enhance resolution with Topaz

## Web UI Access

**URL**: https://elevenlabs.io/image-video

### Getting Started

1. Log into ElevenLabs
2. Navigate to "Image & Video" under Playground
3. Select Image or Video mode
4. Enter your prompt and configure settings
5. Generate and refine

## Image Generation Models

| Model | Best For | Style |
|-------|----------|-------|
| **Nano Banana** | General purpose | Balanced |
| **Seedream 4** | Artistic | Stylized |
| **GPT Image 1** | Detailed prompts | Photorealistic |
| **Flux** | Photorealistic | High fidelity |
| **Wan** | Artistic motion | Creative |

### Image Settings

- **Aspect Ratios**: 1:1, 16:9, 9:16, 4:3, 3:4, 4:5, 5:4, 21:9
- **Variations**: 1-4 images per generation
- **Reference Images**: Upload for style guidance

### Image Prompt Tips

```
Good: "A wooden puppet scientist examining a giant glowing tomato in a laboratory,
       dramatic lighting, photorealistic style"

Bad: "scientist tomato"
```

## Video Generation Models

| Model | Duration | Resolution | Key Features |
|-------|----------|------------|--------------|
| **Sora 2** | 4-12s | 720p/1080p | Physics-aware, audio sync |
| **Sora 2 Pro** | 4-12s | 720p/1080p | Higher quality |
| **Veo 3.1** | 4-8s | 720p/1080p | Cinematic, integrated audio |
| **Veo 3 Fast** | 4-8s | 720p/1080p | Rapid iteration |
| **Kling 2.5** | 5-10s | 1080p | Complex motion, physics |
| **Seedance** | Variable | 720p/1080p | Dancing/motion |
| **Wan 2.5** | Variable | 720p | Artistic motion |

### Video Settings

- **Duration**: 4s, 5s, 6s, 8s, 10s, 12s (varies by model)
- **Resolution**: 720p or 1080p
- **Aspect Ratios**: 16:9, 9:16, 1:1
- **Start/End Frames**: Upload images for control
- **Sound**: Enable/disable integrated audio

### Video Workflow

```
1. Generate or upload starting image
2. Write video prompt describing motion
3. Select model based on needs:
   - Fast iteration: Veo 3 Fast
   - High quality: Sora 2 Pro
   - Complex physics: Kling 2.5
   - Cinematic: Veo 3.1
4. Set duration and resolution
5. Generate (wait 1-3 minutes)
6. Refine with additional prompts
```

## Lip Sync Models

| Model | Quality | Speed | Best For |
|-------|---------|-------|----------|
| **OmniHuman 1.5** | Highest | Slower | Professional content |
| **Veed Lipsync** | Good | Faster | Quick iterations |

### Lip Sync Workflow

```
1. Generate or upload video
2. Generate voiceover using TTS or upload audio
3. Apply lip sync model
4. Export final video with synced audio
```

## Upscaling with Topaz

- **Input**: Images or videos
- **Output**: 2K or 4K resolution
- **Quality**: Preserves details, enhances sharpness

## Creative Workflows

### Text-to-Video Pipeline

```
Text Prompt
    ↓
Image Generation (Nano Banana/Flux)
    ↓
Video Generation (Sora 2/Veo 3.1)
    ↓
TTS Voiceover (eleven_multilingual_v2)
    ↓
Lip Sync (OmniHuman)
    ↓
Upscaling (Topaz 4K)
    ↓
Export to Studio
```

### Marketing Asset Pipeline

```
1. Write product description
2. Generate product images (4 variations)
3. Select best image
4. Create product video (8s, 1080p)
5. Add voiceover and music
6. Export for social media
```

### Tutorial Video Pipeline

```
1. Create slide images with text
2. Generate voiceover for each slide
3. Create transitions between slides (video)
4. Add lip sync for presenter sections
5. Export full tutorial
```

## Credit Costs (Approximate)

| Operation | Credits |
|-----------|---------|
| Image generation | 500-1000 |
| Video (4s, 720p) | 3500-4000 |
| Video (8s, 1080p) | 8000-12000 |
| Lip sync | 2000-4000 |
| Upscale to 4K | 500-1000 |

## MCP Server Integration

An MCP server is available at `~/.claude/mcp-servers/elevenlabs-creative/`:

### Working Tools (API Available)
- `elevenlabs_tts` - Text-to-speech
- `elevenlabs_list_voices` - List voices
- `elevenlabs_get_voice` - Voice details
- `elevenlabs_list_models` - List models

### Placeholder Tools (Web UI Only)
- `elevenlabs_generate_image`
- `elevenlabs_generate_video`
- `elevenlabs_lip_sync`
- `elevenlabs_upscale`

These tools return guidance to use the web UI until APIs become public.

## Best Practices

### Image Generation
- Be specific in prompts (style, lighting, composition)
- Use reference images for consistent style
- Generate 4 variations and pick the best
- Upscale only after selecting final image

### Video Generation
- Start with a strong first frame
- Keep prompts focused on motion/action
- Use shorter durations for iteration
- Enable sound for immersive content

### Lip Sync
- Use clear audio without background noise
- OmniHuman for talking head videos
- Veed for quick tests

### Workflow Efficiency
- Batch similar generations
- Save good prompts for reuse
- Use lower resolution for testing
- Only upscale final assets

## Future API Integration

When ElevenLabs releases public APIs for image/video generation, the MCP server
will be updated with working implementations. Monitor:
- https://elevenlabs.io/docs/api-reference
- https://elevenlabs.io/changelog
