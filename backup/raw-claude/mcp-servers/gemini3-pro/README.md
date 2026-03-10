# Gemini 3 Pro MCP Server

Full-featured MCP server for Google's Gemini 3 Pro models with complete API support.

## Features

- **Thinking Levels**: Configure reasoning depth (`low` for speed, `high` for quality)
- **Media Resolution**: Control vision token usage (`LOW`/`MEDIUM`/`HIGH`/`ULTRA_HIGH`)
- **Image Generation**: Create images at 1K/2K/4K resolution
- **URL Context**: Analyze up to 20 URLs in a single request
- **Google Search**: Grounded queries with real-time web data
- **Thought Signatures**: Automatic handling for multi-turn coherence

## Installation

```bash
cd ~/.claude/mcp-servers/gemini3-pro
npm install
npm run build
```

## Configuration

Add to your MCP config (`~/.config/claude-code/mcp-config.json`):

```json
{
  "mcpServers": {
    "gemini3-pro": {
      "command": "node",
      "args": ["~/.claude/mcp-servers/gemini3-pro/dist/index.js"],
      "env": {
        "GEMINI_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

## Available Tools

### gemini-query
General-purpose queries with configurable reasoning.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prompt` | string | required | The query |
| `thinking_level` | "low" \| "high" | "high" | Reasoning depth |
| `media_resolution` | "LOW" \| "MEDIUM" \| "HIGH" \| "ULTRA_HIGH" | - | Vision token usage |

### gemini-analyze-code
Deep code analysis with focus areas.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `code` | string | required | Code to analyze |
| `language` | string | - | Programming language |
| `focus` | "quality" \| "security" \| "performance" \| "bugs" \| "general" | "general" | Analysis focus |

### gemini-analyze-text
Text analysis with multiple modes.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | string | required | Text to analyze |
| `type` | "sentiment" \| "summary" \| "entities" \| "key-points" \| "general" | "general" | Analysis type |

### gemini-brainstorm
Collaborative brainstorming with Claude.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prompt` | string | required | Topic/problem |
| `claudeThoughts` | string | required | Claude's initial analysis |
| `maxRounds` | number (1-5) | 3 | Brainstorming rounds |

### gemini-summarize
Flexible summarization.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `content` | string | required | Content to summarize |
| `length` | "brief" \| "moderate" \| "detailed" | "moderate" | Output length |
| `format` | "paragraph" \| "bullet-points" \| "outline" | "paragraph" | Output format |

### gemini-image-prompt
Generate optimized prompts for image generation.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `description` | string | required | Image description |
| `style` | string | - | Artistic style |
| `mood` | string | - | Mood/atmosphere |
| `details` | string | - | Additional details |

### gemini-generate-image
Create images with Gemini 3 Pro Image.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `prompt` | string | required | Generation prompt |
| `aspect_ratio` | AspectRatio | "16:9" | Output ratio |
| `image_size` | "1K" \| "2K" \| "4K" | "2K" | Resolution |
| `grounded` | boolean | false | Use Google Search |

**Aspect Ratios**: `1:1`, `2:3`, `3:2`, `3:4`, `4:3`, `4:5`, `5:4`, `9:16`, `16:9`, `21:9`

**Pricing**: 1K/2K = $0.134, 4K = $0.24 per image

### gemini-url-context
Analyze content from URLs.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `urls` | string[] | required | URLs to analyze (max 20) |
| `prompt` | string | required | Analysis prompt |
| `thinking_level` | "low" \| "high" | "high" | Reasoning depth |

### gemini-grounded-query
Query with real-time Google Search.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `query` | string | required | Search-augmented query |
| `thinking_level` | "low" \| "high" | "high" | Reasoning depth |

## Critical Configuration Notes

### Temperature
**ALWAYS use default temperature (1.0)**. Gemini 3's reasoning is optimized for this setting. Lower values cause looping and degraded output.

### Media Resolution Recommendations

| Media Type | Recommended | Tokens | Notes |
|------------|-------------|--------|-------|
| Images | HIGH | 1120 | Best for detailed analysis |
| PDFs | MEDIUM | 560 | Quality saturates here |
| Video | LOW | 70/frame | Sufficient for most cases |
| Video (OCR) | HIGH | 280/frame | When reading text in frames |

### Thinking Level Guidelines

| Task Type | Level | Rationale |
|-----------|-------|-----------|
| Simple Q&A | low | Speed over depth |
| Code review | high | Thorough analysis |
| Architecture | high | Complex reasoning |
| Chat/autocomplete | low | Minimize latency |

## Models Used

- `gemini-3-pro-preview` - Reasoning, analysis (1M context, 64k output)
- `gemini-3-pro-image-preview` - Image generation (65k context, 32k output)

## Token Budget

| Operation | Approximate Tokens |
|-----------|-------------------|
| Thinking (low) | ~500-1000 |
| Thinking (high) | ~2000-8000 |
| Image LOW | 280 |
| Image MEDIUM | 560 |
| Image HIGH | 1120 |
| Image ULTRA_HIGH | 2240 |
| Generated image (1K/2K) | 1120 |
| Generated image (4K) | 2000 |
