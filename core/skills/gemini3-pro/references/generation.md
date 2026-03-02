# Gemini Image Generation Reference

## Image Generation

```python
mcp__gemini__gemini-generate-image
  prompt: "Professional headshot of a software engineer"
  aspect_ratio: "1:1"
  image_size: "2K"
  grounded: false  # Set true for real-time data
```

### Supported Aspect Ratios

1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9

### Image Sizes

| Size | Cost | Use For |
|------|------|---------|
| 1K | $0.134 | Quick drafts, thumbnails |
| 2K | $0.134 | Web-quality (recommended) |
| 4K | $0.24 | Print, high-detail |

**IMPORTANT**: Size values MUST be UPPERCASE: `"1K"`, `"2K"`, `"4K"` (lowercase fails silently).

### Token Cost for Generated Images

| Size | Tokens |
|------|--------|
| 1K/2K | 1120 |
| 4K | 2000 |

---

## gemini-image-prompt

Generate optimized prompts for image generation.

```
Parameters:
- description (required): Image description
- style: Artistic style
- mood: Desired atmosphere
- details: Additional specifics
```

Use this tool to refine prompts before generating images -- better prompts produce better results.

---

## Model Selection

- Image generation uses `gemini-3-pro-image-preview` (NOT the reasoning model)
- The reasoning model `gemini-3.1-pro-preview` CANNOT generate images
