---
name: gemini3-pro
description: |
  Comprehensive guide for using Gemini 3.1 Pro's advanced features correctly.
  Use when you need:
  - Deep Think (maximum reasoning with thinking process visibility)
  - Advanced reasoning with configurable thinking levels (low/medium/high — medium NEW in 3.1)
  - Vision analysis with per-image resolution control
  - Image generation with 4K support
  - Grounded generation with Google Search
  - Multi-turn conversations with thought signatures
  - Structured outputs combined with tools

  Keywords: gemini, gemini3, gemini3.1, vision, image, reasoning, thinking, multimodal, deep think
allowed-tools: Read, mcp__gemini__*
metadata:
  version: "2.0.0"
  author: odedbe
---

# Gemini 3.1 Pro Skill

## Reference Routing

Read the appropriate reference file for your task:

| Topic | Reference File |
|-------|---------------|
| g3-deep-think, g3-think, gemini-query, brainstorm, code/text analysis | `references/deep-think.md` |
| Vision analysis, media resolution, URL context | `references/vision.md` |
| Image generation, aspect ratios, image-prompt tool | `references/generation.md` |
| Configuration patterns, common mistakes, multi-turn, integrations, troubleshooting | `references/patterns.md` |

---

## Quick Reference

```yaml
Models:
  reasoning: gemini-3.1-pro-preview          # NEW — Feb 19, 2026
  image_gen: gemini-3-pro-image-preview
  flash: gemini-3-flash-preview              # Upgraded from 2.5-flash

Temperature: 1.0 (NEVER change - causes looping)

Thinking Levels (Gemini 3.1):
  minimal: lowest latency, simple chat (Flash only)
  low: fast, cheap, simple tasks
  medium: balanced reasoning (Pro + Flash) — NEW on Pro! Approx 3.0 Pro high at lower cost
  high: deep reasoning, math, science (default for both Pro and Flash)

Media Resolution:
  LOW: 280 tokens/image - simple icons, thumbnails
  MEDIUM: 560 tokens/image - PDFs, general docs
  HIGH: 1120 tokens/image - detailed analysis (default for images)
  ULTRA_HIGH: 2240 tokens/image - computer use only

Image Generation:
  sizes: "1K", "2K", "4K" (UPPERCASE!)
  cost: $0.134 (1K/2K), $0.24 (4K)
```

---

## MCP Tools Summary

| Tool | Purpose |
|------|---------|
| `g3-deep-think` | Maximum reasoning depth with thinking process visibility |
| `g3-think` | Configurable thinking (levels or budget) |
| `gemini-query` | General purpose queries (legacy, use g3-think instead) |
| `gemini-brainstorm` | Multi-round brainstorming with Claude collaboration |
| `gemini-analyze-code` | Deep code analysis (quality, security, performance, bugs) |
| `gemini-analyze-text` | Text analysis (sentiment, summary, entities, key-points) |
| `gemini-summarize` | Flexible summarization (brief/moderate/detailed) |
| `gemini-vision` | Image analysis with resolution control |
| `gemini-generate-image` | Image generation (1K/2K/4K) |
| `gemini-image-prompt` | Generate optimized prompts for image generation |
| `gemini-url-context` | Analyze up to 20 URLs (34MB each) |
| `gemini-grounded-query` | Web-grounded generation with Google Search |

---

## Decision Matrix

| Task | Tool | Thinking Level | Notes |
|------|------|----------------|-------|
| Hard math/science | **g3-deep-think** | high (forced) | Returns thinking process + token counts |
| Architecture decisions | **g3-deep-think** | high (forced) | See reasoning chain for decisions |
| Debugging complex issues | **g3-deep-think** | high (forced) | Trace model's reasoning |
| Balanced reasoning | **g3-think** | medium | NEW on Pro — approx 3.0 high quality, lower cost |
| Configurable reasoning | **g3-think** | any level | Full control, both Gemini 3.1 and 2.5 |
| Simple questions | g3-query / g3-think | low | Fast responses |
| Code review | g3-analyze-code | high | Thorough analysis |
| Architecture planning | g3-brainstorm | high | With Claude collaboration |
| Document OCR | gemini-vision | high + HIGH resolution | For text extraction |
| Quick image check | gemini-vision | low + LOW resolution | Classification tasks |
| Generate images | g3-generate-image | N/A | Use 2K for web, 4K for print |
| Web research combo | g3-grounded-query | high | With google_search tool |
