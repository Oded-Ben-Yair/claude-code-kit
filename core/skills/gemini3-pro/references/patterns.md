# Gemini Configuration Patterns & Troubleshooting

## Configuration Patterns

### Cost-Optimized Pattern
```yaml
thinking_level: "low"
media_resolution: "LOW"
image_size: "1K"
```
Use for: Development, testing, simple tasks

### Quality-Optimized Pattern
```yaml
thinking_level: "high"
media_resolution: "HIGH"
image_size: "4K"
```
Use for: Production, detailed analysis, final outputs

### Balanced Pattern (Recommended Default)
```yaml
thinking_level: "high"  # Keep reasoning quality
media_resolution: "MEDIUM"  # Good enough for most docs
image_size: "2K"  # Web-quality images
```

---

## Common Mistakes to Avoid

### 1. Changing Temperature
```python
# WRONG - causes looping and degraded output
config = {"temperature": 0.3}

# CORRECT - always use default
config = {}  # temperature defaults to 1.0
```

### 2. Using Wrong Model for Images
```python
# WRONG - reasoning model can't generate images
model = "gemini-3.1-pro-preview"

# CORRECT - use image model
model = "gemini-3-pro-image-preview"
```

### 3. Lowercase Image Size
```python
# WRONG
image_size: "4k"

# CORRECT
image_size: "4K"
```

### 4. Over-using HIGH Resolution
```python
# WRONG - wasteful for PDFs
media_resolution: "HIGH"  # PDFs don't benefit

# CORRECT - MEDIUM is optimal for most documents
media_resolution: "MEDIUM"
```

---

## Multi-Turn Conversation Handling

When using Gemini 3.1 in multi-turn scenarios:

1. **Function Calling**: Thought signatures are REQUIRED
2. **Image Editing**: Thought signatures maintain context
3. **Chat**: SDK handles signatures automatically

### Manual Signature Handling
```python
# Save from response
thought_sig = response.parts[0].thought_signature

# Include in next request
next_request = [
    Part(text="Follow-up question"),
    Part(thought_signature=thought_sig)
]
```

---

## Integration with Other MCPs

### With Perplexity (Research + Reasoning)
1. Use `perplexity_search` for real-time web data
2. Pass results to `gemini-query` with thinking_level="high" for deep analysis

### With Azure AI (Code Focus)
1. Use `vertex_code_review` for initial code analysis
2. Use `gemini-analyze-code` for second opinion
3. Compare findings in multi-model debate

### With Playwright (Vision Testing)
1. Take screenshot with `browser_take_screenshot`
2. Analyze with `gemini-vision` at appropriate resolution

---

## Token Budget Planning

| Operation | Approximate Tokens |
|-----------|-------------------|
| Base prompt | Variable |
| Thinking (minimal) | ~100-300 (Flash only) |
| Thinking (low) | ~500-1000 |
| Thinking (medium) | ~1000-3000 (Pro + Flash) |
| Thinking (high/deep think) | ~2000-8000+ |
| Image (LOW) | 280 |
| Image (MEDIUM) | 560 |
| Image (HIGH) | 1120 |
| Image (ULTRA_HIGH) | 2240 |
| Video frame (LOW/MED) | 70 |
| Video frame (HIGH) | 280 |
| Generated image (1K/2K) | 1120 |
| Generated image (4K) | 2000 |

---

## Troubleshooting

### "Context window exceeded"
- Reduce media_resolution
- Use thinking_level="low"
- Sample video frames (every 5th frame)

### "Missing thought signatures"
- Include thought_signature from previous response
- Use SDK chat mode for automatic handling

### "Looping or repetitive output"
- Check temperature is 1.0
- Ensure not mixing incompatible settings

### "Poor image generation quality"
- Increase image_size to "4K"
- Add more specific details to prompt
- Use grounded=true for real-world accuracy
