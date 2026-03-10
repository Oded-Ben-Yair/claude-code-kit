---
name: mcp-activator
description: |
  Activate or deactivate MCP servers on-demand to manage context tokens.
  Use this skill to enable heavy MCPs (Playwright, Gemini, Perplexity) only when needed.

  Keywords: mcp, activate, enable, disable, context, tokens
---

# MCP Activator Skill

## Purpose
Manage MCP server activation to reduce context token usage. Heavy MCPs are disabled by default and activated on-demand.

## Default State
| MCP Server | Status | Token Est. | Use Case |
|------------|--------|------------|----------|
| `memory` | **Active** | ~6k | Always needed for context persistence |
| `azure-ai-foundry` | **Active** | ~3k | AI model access |
| `perplexity` | Lazy | ~3k | Web research |
| `gemini3-pro` | Lazy | ~4k | Gemini 3 Pro (vision, reasoning, image gen) |
| `playwright` | Lazy | ~14k | Browser automation |

### Gemini 3 Pro Tools (when activated)
| Tool | Purpose | Key Config |
|------|---------|------------|
| `gemini-query` | General queries | `thinking_level: low\|high` |
| `gemini-analyze-code` | Code review | `focus: security\|performance\|quality` |
| `gemini-brainstorm` | Collaborative ideation | With Claude's thoughts |
| `gemini-generate-image` | Image generation | `image_size: 1K\|2K\|4K` |
| `gemini-url-context` | Analyze URLs | Max 20 URLs |
| `gemini-grounded-query` | Web-grounded query | With Google Search |

**Critical Gemini 3 Settings:**
- Temperature: **Always 1.0** (lower values cause looping)
- `thinking_level: "high"` for complex tasks, `"low"` for speed
- `media_resolution: "HIGH"` for images, `"MEDIUM"` for PDFs

## Quick Toggle Commands (v2.0.60+)

**NEW**: Use `/mcp` commands directly - no session restart needed!

### Enable/Disable MCPs
```bash
# Enable an MCP server
/mcp enable perplexity
/mcp enable gemini3-pro
/mcp enable playwright

# Disable an MCP server
/mcp disable perplexity
/mcp disable gemini3-pro
/mcp disable playwright

# List all MCP servers and their status
/mcp list

# View MCP server details
/mcp status <server-name>
```

### OAuth Authentication (for MCPs requiring it)
```bash
# Authenticate with OAuth-enabled MCP
/mcp auth <server-name>
```

## Legacy: Manual Config Editing

For persistent changes, edit the config file:

### Activate Perplexity (for research)
```bash
# Edit ~/.config/claude-code/mcp-config.json
# Change "perplexity" section: "disabled": false
# Restart Claude Code session for persistent change
```

### Activate Gemini 3 Pro (for design/vision/reasoning)
```bash
# Edit ~/.config/claude-code/mcp-config.json
# Change "gemini3-pro" section: "disabled": false
# Restart Claude Code session for persistent change
```

### Activate Playwright (for browser automation)
```bash
# Edit ~/.config/claude-code/mcp-config.json
# Change "playwright" section: "disabled": false
# Restart Claude Code session for persistent change
```

## MCP Profiles

For common workflows, consider creating profile-based configs:

### Minimal Profile (default)
- memory: active
- azure-ai-foundry: active
- Total: ~9k tokens

### Research Profile
- memory: active
- azure-ai-foundry: active
- perplexity: active
- Total: ~12k tokens

### Design Profile
- memory: active
- azure-ai-foundry: active
- gemini3-pro: active
- Total: ~13k tokens

### Vision/Image Gen Profile
- memory: active
- azure-ai-foundry: active
- gemini3-pro: active (with `thinking_level: high`, `media_resolution: HIGH`)
- Total: ~13k tokens

### Full Profile
- All MCPs active
- Total: ~30k tokens

## Quick Toggle Script

Create `~/.claude/scripts/toggle-mcp.sh`:
```bash
#!/bin/bash
MCP_CONFIG="$HOME/.config/claude-code/mcp-config.json"

toggle_mcp() {
  local mcp_name=$1
  local current=$(jq -r ".mcpServers.\"$mcp_name\".disabled // false" "$MCP_CONFIG")

  if [ "$current" = "true" ]; then
    jq ".mcpServers.\"$mcp_name\".disabled = false" "$MCP_CONFIG" > tmp.$$ && mv tmp.$$ "$MCP_CONFIG"
    echo "Activated $mcp_name"
  else
    jq ".mcpServers.\"$mcp_name\".disabled = true" "$MCP_CONFIG" > tmp.$$ && mv tmp.$$ "$MCP_CONFIG"
    echo "Deactivated $mcp_name"
  fi
  echo "Restart Claude Code to apply changes"
}

case $1 in
  perplexity|gemini3-pro|playwright) toggle_mcp $1 ;;
  *) echo "Usage: toggle-mcp.sh <perplexity|gemini3-pro|playwright>" ;;
esac
```

## Best Practices

1. **Start minimal** - Only activate what you need for current task
2. **Deactivate after use** - Return to minimal profile when done
3. **Monitor context** - Use `/doctor` to check MCP token usage
4. **Session-based** - Changes require session restart

## When to Activate Each MCP

| Task | MCPs Needed | Gemini 3 Config |
|------|-------------|-----------------|
| Code review | memory, azure-ai-foundry | - |
| Web research | + perplexity | - |
| UI testing | + playwright | - |
| Design review | + gemini3-pro | `thinking_level: high` |
| Image analysis | + gemini3-pro | `media_resolution: HIGH` |
| Image generation | + gemini3-pro | `image_size: 2K` (or 4K for print) |
| Document OCR | + gemini3-pro | `media_resolution: HIGH`, `thinking_level: high` |
| Multi-model debate | + perplexity, gemini3-pro | `thinking_level: high` |
| URL analysis | + gemini3-pro | Uses `gemini-url-context` (max 20 URLs) |
| Grounded queries | + gemini3-pro | Uses `gemini-grounded-query` |

### Gemini 3 Pro Quick Reference
```yaml
# For simple/fast tasks
thinking_level: "low"
media_resolution: "LOW"

# For complex analysis (default)
thinking_level: "high"
media_resolution: "HIGH"

# For PDFs (quality saturates at medium)
media_resolution: "MEDIUM"

# Image generation pricing
1K/2K: $0.134/image
4K: $0.24/image
```
