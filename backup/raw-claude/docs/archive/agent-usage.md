# Claude Code Agent Usage Guide

This guide explains how to use the specialized agents in your Claude Code environment.

## Overview

You have **21 specialized agents** available, each optimized for specific tasks:

| Category | Agents | Primary MCP |
|----------|--------|-------------|
| **Gemini** (6) | Design Coder, Doc Parser, UI Auditor, Video Analyzer, Viz Generator, Asset Producer | gemini |
| **Perplexity** (4) | Academic Researcher, Deep Researcher, Geo Researcher, SEC Analyst | perplexity |
| **Grok/Azure** (4) | Competitive Intel, Social Pulse, Brand Writer, Context Weaver | azure-ai-foundry |
| **GPT-5** (2) | Pro Decision Panel, Codex Max Builder | azure-ai-foundry |
| **Utility** (5) | Multi-LLM Orchestrator, Cleanup Specialist, Design Specialist, Azure DevOps, Worktree | various |

## How Agents Work

Agents are invoked via the **Task tool** with a `subagent_type` parameter. Each agent has:

1. **Name** - Display name for the agent
2. **Description** - What the agent does
3. **Tools** - Which tools the agent can use
4. **Model** - Which Claude model (haiku/sonnet/opus)

## Invoking Agents

### Via Task Tool

```
Use the Task tool with subagent_type="agent-name"
```

### Auto-Routing

The system automatically routes tasks to appropriate agents based on:
- **Keywords** in your request
- **File types** involved
- **Task complexity**

## Agent Reference

### Gemini Agents (Vision & Design)

#### Gemini Design to Code
- **Trigger**: "design to code", "screenshot to code", "Figma to React"
- **Use for**: Converting design mockups to code
- **Model**: sonnet
- **Tools**: Read, Write, Edit, mcp__gemini__*

#### Gemini Document Parser
- **Trigger**: "parse PDF", "OCR", "extract from document"
- **Use for**: Extracting structured data from documents
- **Model**: sonnet
- **Tools**: Read, Glob, mcp__gemini__*

#### Gemini UI Auditor
- **Trigger**: "accessibility", "WCAG", "audit UI"
- **Use for**: A11y audits, visual QA
- **Model**: sonnet
- **Tools**: Read, mcp__gemini__*, mcp__playwright__*

#### Gemini Video Analyzer
- **Trigger**: "analyze video", "document demo"
- **Use for**: Video → tutorial documentation
- **Model**: sonnet
- **Tools**: Read, mcp__gemini__*

#### Gemini Visualization Generator
- **Trigger**: "visualize data", "create chart"
- **Use for**: Data → infographics
- **Model**: sonnet
- **Tools**: Read, Write, mcp__gemini__*

#### Gemini Asset Producer
- **Trigger**: "create app icon", "generate logo", "make banner"
- **Use for**: Image asset generation
- **Model**: sonnet
- **Tools**: Read, Write, mcp__gemini__*

### Perplexity Agents (Research)

#### Perplexity Academic Researcher
- **Trigger**: "research papers", "peer-reviewed", "citations"
- **Use for**: Academic literature review
- **Model**: sonnet
- **Tools**: Read, WebFetch, mcp__perplexity__*

#### Perplexity Deep Researcher
- **Trigger**: "deep research", "comprehensive analysis"
- **Use for**: Exhaustive multi-source synthesis
- **Model**: sonnet
- **Tools**: Read, WebFetch, mcp__perplexity__*

#### Perplexity Geo Researcher
- **Trigger**: "market in [country]", "regional analysis"
- **Use for**: Location-specific research
- **Model**: sonnet
- **Tools**: Read, WebFetch, WebSearch, mcp__perplexity__*

#### Perplexity SEC Analyst
- **Trigger**: "SEC filing", "10-K", "financial analysis"
- **Use for**: Financial/regulatory research
- **Model**: sonnet
- **Tools**: Read, WebFetch, mcp__perplexity__*

### Grok/GPT Agents (Intelligence & Generation)

#### Grok Competitive Intelligence
- **Trigger**: "competitor monitoring", "share of voice"
- **Use for**: Competitive social analysis
- **Model**: sonnet
- **Tools**: Read, Bash, WebFetch, WebSearch, mcp__azure-ai-foundry__*

#### Grok Social Pulse
- **Trigger**: "trending on X", "social sentiment"
- **Use for**: Real-time X/Twitter monitoring
- **Model**: sonnet
- **Tools**: Read, WebFetch, WebSearch, mcp__azure-ai-foundry__*

#### Grok Brand Writer
- **Trigger**: "write tweet", "social media post"
- **Use for**: Human-like social content
- **Model**: haiku
- **Tools**: Read, Write, mcp__azure-ai-foundry__*

#### GPT-5.2 Context Weaver
- **Trigger**: "analyze entire", "full codebase", "synthesize all"
- **Use for**: Long-context analysis (400k tokens)
- **Model**: opus
- **Tools**: Read, Glob, Grep, mcp__azure-ai-foundry__*

#### GPT-5 Pro Decision Panel
- **Trigger**: "analyze options", "decision matrix"
- **Use for**: Parallel reasoning, trade-offs
- **Model**: opus
- **Tools**: Read, mcp__azure-ai-foundry__*

#### Codex Max Builder
- **Trigger**: "build feature", "refactor", "autonomous coding"
- **Use for**: Multi-file code generation
- **Model**: sonnet
- **Tools**: Read, Write, Edit, Bash, Glob, Grep, mcp__azure-ai-foundry__*

### Utility Agents

#### Multi-LLM Orchestrator
- **Trigger**: Complex multi-model tasks
- **Use for**: Routing to optimal model
- **Model**: opus
- **Tools**: All MCPs

#### Cleanup Specialist
- **Trigger**: "clean up", "remove dead code"
- **Use for**: Safe cleanup operations
- **Model**: haiku
- **Tools**: Read, Bash, Glob, Grep, Edit, Write

#### Design Specialist
- **Trigger**: Frontend design tasks
- **Use for**: UI/UX implementation
- **Model**: sonnet
- **Tools**: Read, Write, Edit, Bash, WebFetch, mcp__playwright__*, mcp__gemini__*

#### Azure DevOps Specialist
- **Trigger**: Azure deployment, pipelines
- **Use for**: Azure-specific operations
- **Model**: sonnet
- **Tools**: Read, Write, Edit, Bash, Glob, Grep, WebFetch, mcp__azure-ai-foundry__*

#### Worktree Specialist
- **Trigger**: "git worktree", "parallel development"
- **Use for**: Multi-branch workflows
- **Model**: sonnet
- **Tools**: Read, Bash, Glob, Grep

## Model Selection Guidelines

| Model | Use When | Cost | Latency |
|-------|----------|------|---------|
| **haiku** | Simple, fast tasks | Lowest | Fastest |
| **sonnet** | Most coding/analysis | Medium | Balanced |
| **opus** | Complex reasoning, synthesis | Highest | Slowest |

## Best Practices

### 1. Let Auto-Routing Work
The system is configured to route tasks to appropriate agents. Include relevant keywords in your request.

### 2. Be Specific About Output
Tell agents what format you need:
- "Return as JSON"
- "Create a summary table"
- "Generate code with tests"

### 3. Provide Context
Agents work better with context:
- Mention relevant files
- Describe the project type
- Specify constraints

### 4. Use Multiple Agents
For complex tasks, agents can be chained:
1. Research with Perplexity
2. Analyze with Gemini
3. Generate with Codex

### 5. Review Agent Output
Agents are tools - always review their output for accuracy and appropriateness.

## Troubleshooting

### Agent Not Found
- Check agent file has correct YAML frontmatter
- Run `/doctor` to verify agents are parsing correctly
- Verify the `name` field in frontmatter

### Agent Using Wrong Model
- Check `model` field in agent frontmatter
- More complex tasks may need `opus`
- Fast tasks can use `haiku`

### MCP Tools Not Available
- Verify MCP server is running
- Check `mcpServers` in settings.json
- Some MCPs are lazy-loaded

## Adding New Agents

1. Create file at `~/.claude/agents/your-agent.md`
2. Add frontmatter:
```yaml
---
name: Your Agent Name
description: What this agent does
tools:
  - Read
  - Write
  - mcp__server__*
model: sonnet
---
```
3. Add documentation below frontmatter
4. Run `/doctor` to verify

## Related Resources

- [Agent Files](~/.claude/agents/)
- [Capabilities Registry](~/.claude/capabilities-registry.json)
- [MCP Server Config](~/.claude/settings.json)
