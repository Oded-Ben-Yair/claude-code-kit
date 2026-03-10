---
name: image-asset-studio
description: |
  Unified 4-engine image creation. Generates from ALL engines in parallel,
  saves to files, presents visual comparison. Invokable via /create-image.

  Engines: Gemini 3 Pro Image, Imagen 4, Grok, Azure GPT-image-1.5

  Use when: image, asset, icon, logo, banner, mockup, create image, create asset,
  generate image, emoji, symbol, illustration, product photo, marketing, social media
allowed-tools: Read, Write, Bash, mcp__gemini__*, mcp__grok__*, mcp__azure-ai-foundry__*
metadata:
  version: "1.0.0"
  author: odedbe
---

# Image Asset Studio — Unified 4-Engine Image Creation

## Execution Flow

When invoked, follow these phases IN ORDER:

### Phase 1: Prompt Enhancement

1. Take the user's description
2. Call `mcp__gemini__gemini-image-prompt` to create an optimized base prompt
3. Adapt the base prompt for each engine's strengths (see Prompt Optimization table below)

### Phase 2: Parallel Generation (4 engines)

Determine aspect ratio from user intent (default: square):

| User Intent | Gemini | Imagen 4 | Grok | GPT-image-1.5 |
|------------|--------|----------|------|---------------|
| Square (default) | 1:1 | 1:1 | 1:1 | 1024x1024 |
| Landscape / banner | 16:9 | 16:9 | 16:9 | 1536x1024 |
| Portrait / story | 9:16 | 9:16 | 9:16 | 1024x1536 |

Create an output directory:
```bash
mkdir -p /tmp/create-image-$(date +%s)
```

Call ALL 4 engines in parallel (use 4 parallel tool calls in a single message):

1. **Gemini 3 Pro Image**: `mcp__gemini__gemini-generate-image`
   - `prompt`: enhanced prompt with style/mood descriptors
   - `aspect_ratio`: from table above
   - `image_size`: "2K"

2. **Imagen 4**: `mcp__gemini__gemini-imagen4`
   - `prompt`: clean descriptive prompt (shorter, avoid overly long)
   - `aspect_ratio`: from table above
   - `number_of_images`: 1

3. **Grok**: `mcp__grok__grok_image_generate`
   - `prompt`: creative/expressive prompt with artistic style cues
   - `aspect_ratio`: from table above
   - `n`: 1

4. **Azure GPT-image-1.5**: `mcp__azure-ai-foundry__azure_generate_image`
   - `prompt`: structured 6-component formula (Subject > Action > Environment > Style > Lighting > Details)
   - `size`: from table above
   - `quality`: "high"

### Phase 3: Save & Present

After all 4 engines return:

1. Copy/move any output files to the shared output directory with engine-labeled names:
   - `gemini-pro.png`
   - `imagen4.png`
   - `grok.png`
   - `gpt-image.png`

2. Present comparison table to user:

| # | Engine | File | Strengths |
|---|--------|------|-----------|
| 1 | Gemini 3 Pro | gemini-pro.png | Best text rendering, 4K support, grounded |
| 2 | Imagen 4 | imagen4.png | Top photorealism, fine detail |
| 3 | Grok | grok.png | Creative/artistic style, unique aesthetic |
| 4 | GPT-image-1.5 | gpt-image.png | Enterprise text accuracy, structured output |

3. Show the output directory path so user can browse files

### Phase 4: User Chooses

Ask the user which version(s) to keep (1-4, or "all").

If the user wants refinements on a chosen version, use the respective engine's edit capability:
- Gemini: `mcp__gemini__gemini-edit-image`
- Grok: `mcp__grok__grok_image_edit`
- GPT-image-1.5: re-call `azure_generate_image` with refined prompt

---

## Prompt Optimization Per Engine

| Engine | Prompt Style | Tips |
|--------|-------------|------|
| Gemini 3 Pro | Detailed, include `text_content` if text needed. Works well with style/mood descriptors. Add specific color palettes. | Best for text-heavy images, UI mockups |
| Imagen 4 | Clean descriptive prompts. Best with photorealistic subjects. Avoid overly long prompts (keep under 200 words). | Best for product photography, portraits |
| Grok | Creative, expressive prompts. Good with artistic styles, abstract concepts, pop culture references. | Best for logos, creative illustrations |
| GPT-image-1.5 | Structured 6-component formula: Subject > Action > Environment > Style > Lighting > Details. Be explicit about composition. | Best for marketing materials, precise layouts |

---

## Error Handling

If any engine fails, continue with the others. Report which engines succeeded and which failed:

```
Results:
  Gemini 3 Pro: OK — /tmp/create-image-1234/gemini-pro.png
  Imagen 4: OK — /tmp/create-image-1234/imagen4.png
  Grok: FAILED — Rate limit exceeded
  GPT-image-1.5: FAILED — Deployment not found (gpt-image-1.5 may not be deployed)
```

NEVER fail the entire operation because one engine fails. Show what you have.

If Azure GPT-image-1.5 fails with "deployment not found", suggest the user deploy it:
```
Note: gpt-image-1.5 is not deployed on your Azure endpoint. Deploy with:
az cognitiveservices account deployment create \
  --name brn-azai --resource-group AZAI_group \
  --deployment-name gpt-image-1.5 --model-name gpt-image-1.5 \
  --model-version "2025-04-15" --model-format OpenAI \
  --sku-capacity 1 --sku-name Standard
```

---

## Pricing Reference

| Engine | Cost | Notes |
|--------|------|-------|
| Gemini 3 Pro | ~$0.13/image (2K) | Token-based (1120 tokens/image) |
| Imagen 4 | ~$0.04/image | Fixed per-image |
| Grok | ~$0.07/image | Fixed per-image |
| GPT-image-1.5 | Token-based | Varies by size/quality |

Total cost per 4-engine comparison: ~$0.30-0.50

---

## Legacy Features (Gemini-only, still available)

These Gemini-specific features remain available for advanced workflows:

| Feature | Tool | When to Use |
|---------|------|-------------|
| Edit existing image | `gemini-edit-image` | Inpainting, style transfer, background swap |
| Extend to new ratio | `gemini-extend-image` | Outpaint to different aspect ratios |
| Multi-image composite | `gemini-composite-image` | Combine object/person references |
| Session editing | `gemini-session-edit` | Multi-turn iterative refinement |

---

## Integration Points

| Scenario | Hand Off To |
|----------|-------------|
| UI implementation needed | `frontend` skill |
| Brand compliance check | `frontend` skill (audit mode) |
| Complex design decisions | `multi-model-debate` skill |
| Persist asset specs | `memory` MCP |
