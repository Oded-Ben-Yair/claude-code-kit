# /route

Route a task to the optimal LLM based on task type.

## Usage

```
/route <task-type> <description>
```

## Task Types

| Type | Primary Model | MCP Tool |
|------|---------------|----------|
| `search` | Perplexity | `mcp__perplexity__search` |
| `research` | Perplexity | `mcp__perplexity__deep_research` |
| `reason` | Perplexity | `mcp__perplexity__reason` |
| `vision` | Gemini | `mcp__gemini__*` |
| `code` | Claude Sonnet | (current session) |
| `analyze` | Claude Opus | (current session) |
| `azure` | Azure AI Foundry | `mcp__azure-ai-foundry__chat` |

## Examples

```
/route search latest news on forex regulations UAE
/route research comprehensive analysis of GCC forex market 2025
/route vision analyze this screenshot for UI issues
/route code refactor this function for better performance
```

## Implementation Logic

When user runs `/route <type> <description>`:

### Search Tasks
```markdown
For real-time web search, use Perplexity:

Tool: mcp__perplexity__search
Query: <user's description>

This returns current web results with citations.
```

### Research Tasks
```markdown
For in-depth research reports, use Perplexity Deep Research:

Tool: mcp__perplexity__deep_research
Query: <user's description>

This performs comprehensive research and returns a detailed report.
```

### Reasoning Tasks
```markdown
For complex reasoning with search, use Perplexity Reason:

Tool: mcp__perplexity__reason
Query: <user's description>

This combines web search with step-by-step reasoning.
```

### Vision Tasks
```markdown
For image analysis, use Gemini:

Tool: mcp__gemini__analyze_image or mcp__gemini__describe
Input: <image path or URL>

Gemini excels at visual understanding and multimodal tasks.
```

### Code Tasks
```markdown
Stay with Claude Sonnet (current session).

Claude Sonnet 4.5 is the best coding model available.
Proceed with the coding task directly.
```

### Analysis Tasks
```markdown
Stay with Claude Opus (current session if available).

For deep analysis, use extended thinking mode.
Switch to opus if not already: /model opus
```

### Azure Tasks
```markdown
For Azure-specific or when Azure integration is needed:

Tool: mcp__azure-ai-foundry__chat
Model: GPT-4o

Useful when you need Azure ecosystem integration.
```

## Routing Decision Tree

```
Is it real-time/current info?
├── Yes → Perplexity search/research
└── No
    ├── Is it visual/image?
    │   └── Yes → Gemini
    └── No
        ├── Is it coding?
        │   └── Yes → Claude Sonnet
        └── No
            ├── Is it complex analysis?
            │   └── Yes → Claude Opus
            └── No → Claude Haiku (fast)
```

## Notes

- All MCP tools are pre-configured in ~/.claude.json
- Perplexity requires API key (configured)
- Gemini requires API key (configured)
- Azure AI Foundry requires Azure credentials (configured)
- Model aliases: opus, sonnet, haiku (no need for full identifiers)
