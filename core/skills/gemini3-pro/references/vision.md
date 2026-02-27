# Gemini Vision & URL Context Reference

## Vision Analysis with Media Resolution

For analyzing images with Gemini 3.1, control token usage with media resolution:

```python
# High resolution for detailed analysis
mcp__gemini__gemini-vision
  image_url: "https://..."
  prompt: "What text is visible in this document?"
  media_resolution: "HIGH"

# Low resolution for simple classification
mcp__gemini__gemini-vision
  image_url: "https://..."
  prompt: "Is this a cat or dog?"
  media_resolution: "LOW"
```

### Resolution Token Costs

| Resolution | Tokens/Image | Use For |
|-----------|-------------|---------|
| LOW | 280 | Simple icons, thumbnails, classification |
| MEDIUM | 560 | PDFs, general documents |
| HIGH | 1120 | Detailed analysis, text extraction (default for images) |
| ULTRA_HIGH | 2240 | Computer use only |

### Video Resolution

| Resolution | Tokens/Frame | Notes |
|-----------|-------------|-------|
| LOW/MEDIUM | 70 | General video analysis |
| HIGH | 280 | Detailed frame analysis |

---

## URL Context Analysis

```python
mcp__gemini__gemini-url-context
  urls: ["https://example.com/doc1", "https://example.com/doc2"]
  prompt: "Compare these two documents"
```

**Limits:** Max 20 URLs, 34MB per URL

---

## Integration with Playwright (Vision Testing)

1. Take screenshot with `browser_take_screenshot`
2. Analyze with `gemini-vision` at appropriate resolution
3. For MCP vision analysis: resize to 200px wide JPEG q50 (<5K base64)
