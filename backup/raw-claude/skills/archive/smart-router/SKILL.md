---
name: smart-router
description: Intelligent task routing to optimal LLM/agent based on task analysis
allowed-tools: Read, Task, mcp__memory__*
---

# Smart Model Router

Routes tasks to the optimal LLM and specialized agent based on task characteristics, file types, and keywords.

## How This Skill Works

1. **Analyze** the user's request for signals (keywords, file types, complexity)
2. **Match** against routing rules to identify best model/agent
3. **Dispatch** to the appropriate tool or agent
4. **Coordinate** multi-model workflows when needed

---

## Primary Routing Decision Tree

### Step 1: File Type Detection

| File Type | Primary Model | Agent |
|-----------|---------------|-------|
| `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp` | Gemini 3 Pro | `gemini-design-coder` or `gemini-ui-auditor` |
| `.pdf` | Gemini 3 Pro | `gemini-doc-parser` |
| `.mp4`, `.mov`, `.webm` | Gemini 3 Pro | `gemini-video-analyzer` |
| `.figma`, `.sketch`, `.xd` | Gemini 3 Pro | `gemini-design-coder` |
| Code files (`.ts`, `.py`, etc.) | Codex Max | `codex-max-builder` |
| Large text (>50k tokens) | GPT-5.2 | `gpt52-context-weaver` |

### Step 2: Keyword Matching

| Keywords/Phrases | Route To | Agent | MCP Tool |
|------------------|----------|-------|----------|
| **Design & Visual** | | | |
| "design to code", "convert this design", "implement this UI" | Gemini 3 Pro → Codex Max | `frontend` skill | `gemini-query` → `azure_code_review` |
| "accessibility", "WCAG", "audit UI", "check this screen" | Gemini 3 Pro | `gemini-ui-auditor` | `gemini-analyze-image` |
| "extract from document", "parse PDF", "OCR" | Gemini 3 Pro | `gemini-doc-parser` | `gemini-analyze-document` |
| "analyze video", "document demo", "tutorial extraction" | Gemini 3 Pro | `gemini-video-analyzer` | `gemini-youtube` |
| "visualize data", "create chart", "infographic" | Gemini 3 Pro | `gemini-viz-generator` | `gemini-generate-image` (grounded) |
| **Research** | | | |
| "academic research", "peer-reviewed", "citations" | Perplexity | `perplexity-academic-researcher` | `perplexity_research` (academic mode) |
| "SEC filing", "10-K", "financial analysis" | Perplexity | `perplexity-sec-analyst` | `perplexity_search` (sec mode) |
| "market in [country]", "local news", "regional" | Perplexity | `perplexity-geo-researcher` | `perplexity_search` (country filter) |
| "deep research", "comprehensive analysis", "thorough investigation" | Perplexity | `perplexity-deep-research` | `perplexity_research` (sonar-deep-research) |
| **Social Intelligence (Grok)** | | | |
| "trending on X", "Twitter", "social sentiment" | Grok-4 | `grok-social-pulse` | `grok_social_pulse`, `grok_x_search` |
| "write tweet", "social media post", "content for X" | Grok-4 | `grok-brand-writer` | `grok_brand_content` |
| "competitor monitoring", "competitive intel", "share of voice" | Grok-4 | `grok-competitive-intel` | `grok_competitive_intel` |
| **Code** | | | |
| "build feature", "refactor", "code generation", "autonomous coding" | Codex Max | `codex-max-builder` | `azure_code_review` |
| "quick fix", "snippet", "small change", "rapid prototype" | Grok-code-fast-1 | `grok-code-fast` | `grok_code` (92 tok/s) |
| **Reasoning & Analysis** | | | |
| "complex reasoning", "step by step logic", "why", "explain logic" | Gemini 3 Pro (37.5% HLE) | `gemini-deep-reasoner` | `gemini-query` (thinking_level=high) |
| "brainstorm", "creative ideas", "ideation", "generate concepts" | GPT-5 Pro | `gpt5-pro-brainstormer` | `azure_brainstorm` |
| "decision analysis", "compare options", "trade-offs" | GPT-5 Pro | `gpt5-pro-decision-panel` | `azure_brainstorm` |
| "full codebase", "all documents", "synthesize everything" | GPT-5.2 (400k) | `gpt52-context-weaver` | `azure_chat` |
| "massive context", "2M tokens", "huge repo" | Grok-4-fast-reasoning (2M) | - | `grok_chat` |

### Step 3: Task Complexity Assessment

| Complexity Signal | Route To |
|-------------------|----------|
| Simple lookup, fact check | Perplexity (quick) |
| Complex reasoning, logic | Grok 4 (azure_reason) |
| Creative ideation | GPT-5 Pro (azure_brainstorm) |
| Code review/generation | Codex Max (azure_code_review) |
| Multi-step workflow | Claude (orchestration) |
| High-stakes decision | Multi-model debate |

### Step 4: Recency Requirements

| Recency Need | Route To |
|--------------|----------|
| Real-time social data | Grok 4 |
| Current news/events | Perplexity |
| Real-time grounded images | Gemini 3 Pro (grounded) |
| Historical analysis | GPT-5.2 |

---

## Routing Rules by Category

### Design & Visual Tasks

```yaml
Design-to-Code:
  Primary: gemini-design-coder
  MCP: mcp__gemini__gemini-query
  Config: thinking_level="high", media_resolution=HIGH

UI Audit:
  Primary: gemini-ui-auditor
  MCP: mcp__gemini__gemini-query + mcp__playwright__browser_take_screenshot
  Config: thinking_level="high", media_resolution=HIGH

Document Parsing:
  Primary: gemini-doc-parser
  MCP: mcp__gemini__gemini-query
  Config: thinking_level="high", media_resolution=MEDIUM (for PDFs)

Video Analysis:
  Primary: gemini-video-analyzer
  MCP: mcp__gemini__gemini-query
  Config: thinking_level="high", video_resolution=LOW (or HIGH for OCR)

Data Visualization:
  Primary: gemini-viz-generator
  MCP: mcp__gemini__gemini-query (image generation)
  Config: thinking_level="low", image_size="2K"
```

### Research Tasks

```yaml
Academic Research:
  Primary: perplexity-academic-researcher
  MCP: mcp__perplexity__perplexity_research
  Config: search_mode="academic", search_context_size="high"

Financial Research:
  Primary: perplexity-sec-analyst
  MCP: mcp__perplexity__perplexity_research
  Config: search_mode="sec"

Regional Research:
  Primary: perplexity-geo-researcher
  MCP: mcp__perplexity__perplexity_search + perplexity_research
  Config: country=[ISO code], search_language_filter=[lang]

Deep Investigation:
  Primary: perplexity-deep-research
  MCP: mcp__perplexity__perplexity_research
  Config: reasoning_effort="high", async processing
```

### Social & Content Tasks

```yaml
Social Intelligence:
  Primary: grok-social-pulse
  MCP: mcp__grok__grok_social_pulse, mcp__grok__grok_x_search
  Config: model="grok-4", time_window="24h"

Content Creation:
  Primary: grok-brand-writer
  MCP: mcp__grok__grok_brand_content
  Config: model="grok-4", content_type="tweet|thread|reply", tone="professional|witty|informative"

Competitive Monitoring:
  Primary: grok-competitive-intel
  MCP: mcp__grok__grok_competitive_intel, mcp__grok__grok_x_search
  Config: model="grok-4", metrics=["mentions", "sentiment", "share_of_voice"]
```

### Code & Development Tasks

```yaml
Code Generation (Complex):
  Primary: codex-max-builder
  MCP: mcp__azure-ai-foundry__azure_code_review
  Config: model="gpt-5.1-codex-max", reasoning_effort="high"
  Benchmark: 80% SWE-bench

Code Review:
  Primary: codex-max-builder
  MCP: mcp__azure-ai-foundry__azure_code_review
  Config: focus=[security|performance|quality|bugs]

Rapid Prototyping:
  Primary: grok-code-fast
  MCP: mcp__grok__grok_code
  Config: model="grok-code-fast-1"
  Speed: 92 tokens/second
  Use For: quick fixes, snippets, small iterations

Security Audit:
  Primary: codex-max-builder + gpt52-context-weaver
  MCP: mcp__azure-ai-foundry__azure_code_review, mcp__azure-ai-foundry__azure_chat
  Config: focus="security", load full codebase for context
```

### Analysis & Decision Tasks

```yaml
Decision Analysis:
  Primary: gpt5-pro-decision-panel
  MCP: mcp__azure-ai-foundry__azure_brainstorm
  Config: model="gpt-5-pro"

Long Context Analysis:
  Primary: gpt52-context-weaver
  MCP: mcp__azure-ai-foundry__azure_chat
  Config: model="gpt-5.2", up to 400k tokens

Complex Reasoning:
  Primary: gemini-deep-reasoner
  MCP: mcp__gemini__gemini-query
  Config: thinking_level="high", model="pro"
  Benchmark: 37.5% Humanity's Last Exam, 91.9% GPQA Diamond

Massive Context (2M+):
  Primary: grok-4-fast-reasoning
  MCP: mcp__grok__grok_chat
  Config: model="grok-4-fast-reasoning", context up to 2M tokens
```

---

## Multi-Model Pipelines

### Design-to-Production Pipeline
```
1. Gemini 3 (gemini-design-coder) → Extract design specs, generate initial code
2. Codex Max (codex-max-builder) → Refactor to production React + tests
3. GPT-5.2 (gpt52-context-weaver) → Integrate into codebase
4. Claude → Final review and polish
```

### Research-to-Decision Pipeline
```
1. Perplexity (perplexity-deep-research) → Gather sources and evidence
2. GPT-5.2 (gpt52-context-weaver) → Load all docs, create claim matrix
3. GPT-5 Pro (gpt5-pro-decision-panel) → Analyze options and trade-offs
4. Claude → Synthesize executive brief
```

### Social Intelligence Pipeline
```
1. Grok 4 (grok-social-pulse) → Real-time X/Twitter monitoring
2. GPT-5 Pro (gpt5-pro-decision-panel) → Segment analysis
3. Perplexity (perplexity-research) → Fact verification
4. Grok 4 (grok-brand-writer) → Generate response content
5. Claude → Brand/compliance review
```

### Autonomous Code Factory
```
1. Claude → Spec elicitation and acceptance criteria
2. GPT-5 Pro (gpt5-pro-decision-panel) → Task planning with dependencies
3. Codex Max (codex-max-builder) → Multi-file generation
4. GPT-5.2 (gpt52-context-weaver) → Repo-wide integration
5. Claude → Code review and approval
```

---

## Quality Optimization Mode (Default)

When routing, prioritize:
1. **Best model for task** - Use specialized model even if more expensive
2. **Agent specialization** - Match agent to task type
3. **Context efficiency** - Use appropriate context window
4. **Output quality** - Prefer higher reasoning_effort for important tasks

---

## Fallback Rules

| If Primary Fails | Fallback To |
|------------------|-------------|
| Gemini 3 unavailable | GPT-5.2 for vision, Claude for text |
| Perplexity unavailable | WebSearch + Claude synthesis |
| Grok 4 unavailable | Perplexity for research, Claude for writing |
| Codex Max unavailable | Claude for code tasks |
| GPT-5 Pro unavailable | Claude + multi-model-debate |

---

## Usage

This skill is invoked automatically when Claude detects:
- Specific file types attached
- Routing keywords in user message
- Task complexity requiring specialized model

Or manually via: `/route [task description]`

The router will:
1. Display the routing decision
2. Explain why this route was chosen
3. Execute the task via appropriate agent
4. Return results to user
