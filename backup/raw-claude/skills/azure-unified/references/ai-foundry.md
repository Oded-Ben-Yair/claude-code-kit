# Azure AI Foundry & Multi-Model Routing

## Azure AI Foundry

**Available Models:**
| Model | API Type | Status | Use Case |
|-------|----------|--------|----------|
| `gpt-5.2` | chat | Working | Latest general purpose |
| `gpt-5.1` | chat | Working | Previous generation model |
| `gpt-5` | chat | Working | General purpose |
| `gpt-5-chat` | chat | Working | Chat-optimized conversations |
| `grok-4-fast-reasoning` | chat | Unstable | Fast reasoning (2M context) |
| `gpt-5-pro` | responses | Working | Research, reasoning, brainstorm |
| `gpt-5.3-codex` | responses | Working | Latest code generation & review |
| `gpt-5.2-codex` | responses | Deprecated | Previous code model |
| `gpt-5.1-codex-max` | responses | Deprecated | Legacy code model |
| `Mistral-Large-2411` | chat | Working | Third-party alternative |

**MCP Tools:**
| Tool | Model | Use For |
|------|-------|---------|
| `azure_chat` | Any model | General chat with any model |
| `azure_code_review` | gpt-5.3-codex | Code review (security, performance, quality, bugs) |
| `azure_brainstorm` | gpt-5-pro | Creative brainstorming |
| `azure_research` | gpt-5-pro | Deep research and analysis |
| `azure_reason` | grok-4 -> GPT-5.2 fallback | Step-by-step logical reasoning |

**Note**: GPT-5+ models do NOT support temperature parameter. `responses` API uses `/openai/v1/responses` endpoint.

### Known Issue: Grok-4 (xAI) Connectivity (Dec 2025)

**Symptom**: Calls to `grok-4-fast-reasoning` timeout with "fetch failed" error.

**Root Cause**: xAI models in Azure AI Foundry have backend routing issues. The deployment shows `provisioningState: Succeeded` but API calls never complete. Other third-party models (Mistral) work fine.

**Diagnosis**:
```bash
# Verify deployment exists
az cognitiveservices account deployment show --name brn-azai --resource-group AZAI_group \
  --deployment-name grok-4-fast-reasoning --query "properties.provisioningState"
# Returns: "Succeeded" but API calls timeout

# Test with curl (will timeout)
timeout 30 curl -s -X POST "https://brn-azai.openai.azure.com/openai/deployments/grok-4-fast-reasoning/chat/completions?api-version=2025-01-01-preview" \
  -H "Content-Type: application/json" \
  -H "api-key: $AZURE_OPENAI_KEY" \
  -d '{"messages":[{"role":"user","content":"Hi"}],"max_tokens":10}'
```

**Workaround Applied**:
- MCP server updated to fall back to GPT-5.2 when Grok-4 times out
- `azure_reason` tool shows `[GPT-5.2 (fallback) Reasoning]` when using fallback
- Requires Claude Code restart to apply (MCP servers are long-running)

**Resolution**:
- Check Azure AI Foundry status page for xAI model availability
- Try different deployment region (currently swedencentral)
- Contact Azure support if persists

---

## Multi-Model Routing (Azure + Gemini + Perplexity)

Use the right model for each task type:

| Task | Primary Tool | Secondary | Notes |
|------|--------------|-----------|-------|
| **Code Review** | `azure_code_review` | `gemini-analyze-code` | Codex Max is primary |
| **Complex Reasoning** | `azure_reason` | `gemini-query` (high) | Grok-4 for speed, Gemini for depth |
| **Research** | `perplexity_research` | `azure_research` | Perplexity for real-time citations |
| **Brainstorming** | `azure_brainstorm` | `gemini-brainstorm` | GPT-5 Pro + Gemini collaboration |
| **Vision/Design** | `gemini-query` | - | Gemini 3 Pro with `media_resolution: HIGH` |
| **Image Generation** | `gemini-generate-image` | - | 1K/2K/4K resolution |
| **URL Analysis** | `gemini-url-context` | - | Max 20 URLs |
| **Grounded Queries** | `gemini-grounded-query` | `perplexity_search` | Real-time web data |

### Gemini 3 Pro Quick Reference
```yaml
# Key settings
thinking_level: "low" | "high"  # high for complex tasks
media_resolution: "LOW" | "MEDIUM" | "HIGH"  # HIGH for images, MEDIUM for PDFs
temperature: 1.0  # NEVER change - causes looping

# Image generation
aspect_ratio: "16:9" | "1:1" | "9:16" | etc.
image_size: "1K" | "2K" | "4K"  # UPPERCASE required
grounded: true | false  # Use Google Search for real-time data
```

### Multi-Model Debate
For high-stakes decisions, use `multi-model-debate` skill to get perspectives from:
- Claude Opus 4.5 (native)
- GPT-5 Pro (`azure_brainstorm`)
- Grok-4 (`azure_reason`)
- Gemini 3 Pro (`gemini-brainstorm` with `thinking_level: high`)
- Perplexity (`perplexity_reason`)
