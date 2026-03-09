---
description: Prime session with ALL capabilities - MCPs, skills, agents, schemas, routing
arguments: []
---

# Session Prime - Full Capability Loading

You are starting a new session. This onboarding primes you with COMPLETE awareness of all available tools, skills, agents, and MCPs so you can optimally plan and execute any task.

**IMPORTANT**: Complete ALL phases. After onboarding, you will be ready to receive a task and plan/execute it using the optimal combination of capabilities.

---

## Phase 1: MCP Tool Discovery

### 1.1 Read Available MCP Servers

**Memory MCP** - Context persistence across sessions:
```
Tools: create_entities, create_relations, add_observations, delete_entities,
       delete_observations, delete_relations, read_graph, search_nodes, open_nodes
Use for: Storing architectural decisions, findings, patterns for future sessions
```

**Azure AI Foundry MCP** - Multi-model access:
```
Tools: azure_chat, azure_code_review, azure_brainstorm, azure_research, azure_reason, list_models

Model Routing:
| Task Type | Tool | Model |
|-----------|------|-------|
| General chat | azure_chat | gpt-5.2 (default), any model |
| Code review | azure_code_review | gpt-5.1-codex-max |
| Brainstorming | azure_brainstorm | gpt-5-pro |
| Deep research | azure_research | gpt-5-pro |
| Logical reasoning | azure_reason | grok-4 -> gpt-5.2 fallback |

Note: Grok-4 has connectivity issues (Dec 2025), falls back to GPT-5.2
```

**Gemini MCP** - Vision, design, and multimodal:
```
Tools: gemini-query, gemini-brainstorm, gemini-analyze-code, gemini-analyze-text,
       gemini-summarize, gemini-image-prompt

Key Parameters:
- thinking_level: "low" (fast) | "high" (thorough) - default high
- media_resolution: LOW | MEDIUM | HIGH - use HIGH for images, MEDIUM for PDFs
- temperature: ALWAYS 1.0 (never change)

Use for: Vision tasks, design analysis, UI/UX, document OCR, image generation
```

**Perplexity MCP** - Real-time research with citations:
```
Tools: perplexity_ask, perplexity_search, perplexity_research, perplexity_reason

Use for: Current information, citations, academic research, fact verification
Strengths: Real-time web data, source citations, academic modes
```

**Playwright MCP** - Browser automation:
```
Tools: browser_navigate, browser_snapshot, browser_click, browser_type,
       browser_take_screenshot, browser_evaluate, etc.

Use for: E2E testing, web scraping, visual validation, form testing
```

### 1.2 Internalize Model Routing

```
ROUTING DECISION TREE:

1. Need current/real-time data? → Perplexity (perplexity_search/research)
2. Analyzing images/designs/PDFs? → Gemini (gemini-query with media_resolution)
3. Code review or generation? → Azure (azure_code_review with Codex Max)
4. Complex reasoning/logic? → Azure (azure_reason) or Perplexity (perplexity_reason)
5. Creative brainstorming? → Azure (azure_brainstorm with GPT-5 Pro)
6. Long document analysis? → Azure (azure_chat with gpt-5.2, 400k context)
7. Multi-perspective analysis? → Use multi-model-debate skill
8. Persisting decisions? → Memory MCP (create_entities)
```

---

## Phase 2: Skills Discovery

Read and internalize these skills (use Skill tool to load when needed):

### Core Skills

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `azure-unified` | Any Azure task | DevOps, deployment, SSO, Key Vault, AI Foundry |
| `smart-router` | Multi-model tasks | Intelligent routing to optimal model |
| `multi-model-debate` | High-stakes decisions | Get perspectives from Claude + GPT-5 + Gemini + Perplexity |
| `mcp-activator` | Token budget concerns | Enable/disable MCPs to manage context |

### Specialized Skills

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `gemini3-pro` | Gemini-specific tasks | Thinking levels, media resolution, image gen |
| `design-to-code` | UI implementation | Figma/screenshot to React/HTML |
| `premium-frontend` | Premium UI | High-quality components and styling |
| `premium-effects` | Visual effects | Animations, 3D, micro-interactions |
| `claude-agent-sdk` | Building agents | Custom agent development |
| `elevenlabs-voice` | Voice features | Text-to-speech integration |

### Plugin Skills (example-skills)

| Skill | Purpose |
|-------|---------|
| `example-skills:frontend-design` | Production-grade UI |
| `example-skills:pdf` | PDF manipulation |
| `example-skills:xlsx` | Spreadsheet operations |
| `example-skills:docx` | Word document operations |
| `example-skills:pptx` | PowerPoint presentations |
| `example-skills:webapp-testing` | Playwright testing |

---

## Phase 3: Agents Discovery

These specialized agents can be launched via Task tool for complex subtasks:

### Gemini Vision Agents
```
gemini-design-coder    - Design screenshots → production code
gemini-ui-auditor      - WCAG accessibility analysis
gemini-doc-parser      - PDF/document → structured data
gemini-video-analyzer  - Video → step-by-step documentation
gemini-viz-generator   - Data → visualizations/charts
```

### Perplexity Research Agents
```
perplexity-academic-researcher - Peer-reviewed sources with citations
perplexity-sec-analyst         - SEC filings and financial analysis
perplexity-geo-researcher      - Regional market research
perplexity-deep-research       - Exhaustive multi-source synthesis
```

### Social Intelligence Agents (Grok)
```
grok-social-pulse      - X/Twitter sentiment monitoring
grok-brand-writer      - Human-like social content
grok-competitive-intel - Competitive social analysis
```

### GPT-5.x Agents
```
codex-max-builder        - Multi-file autonomous coding
gpt5-pro-decision-panel  - Parallel reasoning for decisions
gpt52-context-weaver     - Long-context analysis (400k tokens)
```

### Utility Agents
```
azure-devops-specialist  - Azure DevOps, pipelines, repos
cleanup-specialist       - Safe temp file cleanup
worktree-specialist      - Git worktrees for parallel work
design-specialist        - Frontend design validation
```

---

## Phase 4: Structured Output Schemas

These schemas ensure consistent, parseable outputs:

```
~/.claude/schemas/
├── ui-component.json      - Design-to-code component specs
├── research-report.json   - Perplexity research outputs
├── sentiment-analysis.json - Grok social analysis
└── code-review.json       - Codex Max review format
```

Use these for: Structured outputs that need to be parsed, stored, or processed.

---

## Phase 5: Context Engineering

From `~/.claude/rules/context-engineering.md`:

### Progressive Disclosure
```
Level 1 (Always): System prompt, current task, constraints
Level 2 (On demand): Project CLAUDE.md, relevant files, memory
Level 3 (When needed): Full codebase, history, external docs
```

### Model Selection by Context Size
```
< 8k tokens      → Any model
8k-100k tokens   → GPT-5.2, Gemini, Grok-4
100k-256k tokens → GPT-5.2, Gemini
256k-400k tokens → GPT-5.2
400k-1M tokens   → Gemini 3 Pro
Real-time data   → Grok-4, Perplexity
```

### Compaction Strategy
Before context fills:
1. Save detailed plans to files
2. Persist decisions to Memory MCP
3. Summarize verbose outputs

---

## Phase 6: Chain-of-Thought Templates

From `~/.claude/prompts/cot-templates.md`:

| Situation | Template | Model |
|-----------|----------|-------|
| Architecture decisions | Decision Analysis | GPT-5 Pro |
| Complex debugging | Problem Decomposition | Grok-4/GPT-5.2 |
| Security audit | Security Review | Codex Max |
| Performance tuning | Performance Review | Codex Max |
| Literature review | Academic Research | Perplexity |
| Design specs | Visual Analysis | Gemini 3 |
| Brand monitoring | Sentiment Deep Dive | Grok-4 |

---

## Phase 7: Project Context

### 7.1 Identify Current Project

```bash
pwd
basename $(pwd)
```

### 7.2 Project Registry

| Project | Database | Production? | Special Rules |
|---------|----------|-------------|---------------|
| sentimark | `polymarket_analyzer` | No | Data science persona |
| qc-call-analyzer | `qc_analyzer` | **YES** | QA Architect, extra caution |
| axia-seekapa-cs-agents | `axia_seekapa_chatbot` | No | CS Engineer persona |
| seekapa-training-platform | `seekapa_training` | No | Instructional Designer |
| khaleeji-brand-video | - | No | Brand Director persona |
| seekapa-compliance-exam | `compliance_exam` | **YES** | Compliance Officer |
| phone-spam-checker | `phone_spam_checker` | No | Telecom & Sales Ops |
| research-orchestrator | - | No | Research Analyst |

### 7.3 Read Project CLAUDE.md
If exists, read for project-specific persona, constraints, and workflows.

### 7.4 Verify Git Setup

```bash
git remote -v  # Should be SSH to Azure DevOps
git branch --show-current
git status --short
```

Expected: `azure git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<project>`

### 7.5 Check Memory for Prior Context

```
mcp__memory__search_nodes with query: "<project-name>"
```

---

## Phase 8: Readiness Report

After completing all phases, output this summary:

```
╔══════════════════════════════════════════════════════════════════╗
║                    ONBOARDING COMPLETE                           ║
╠══════════════════════════════════════════════════════════════════╣
║ PROJECT                                                          ║
║   Name: <project-name>                                           ║
║   Database: <db> (user: <user>)                                  ║
║   Production: Yes/No                                             ║
║   Branch: <branch>                                               ║
╠══════════════════════════════════════════════════════════════════╣
║ CAPABILITIES LOADED                                              ║
║   MCP Servers: Memory, Azure AI, Gemini, Perplexity, Playwright  ║
║   Skills: 10+ specialized skills                                 ║
║   Agents: 20 specialized agents                                  ║
║   Schemas: 4 structured output formats                           ║
╠══════════════════════════════════════════════════════════════════╣
║ READY FOR                                                        ║
║   ✓ Multi-model orchestration                                    ║
║   ✓ Intelligent task routing                                     ║
║   ✓ Design-to-code workflows                                     ║
║   ✓ Deep research with citations                                 ║
║   ✓ Code review and generation                                   ║
║   ✓ Complex reasoning and analysis                               ║
║   ✓ Visual and document analysis                                 ║
╠══════════════════════════════════════════════════════════════════╣
║ AWAITING YOUR TASK                                               ║
║   Provide your task and I will:                                  ║
║   1. Plan using optimal tool/model selection                     ║
║   2. Execute with specialized agents where beneficial            ║
║   3. Output structured results when appropriate                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## Execution Instructions

**DO THIS NOW:**

1. Read `azure-unified` skill (use Skill tool)
2. Run git/project identification commands
3. Read project CLAUDE.md if exists
4. Search memory for prior context
5. Output the readiness report

**THEN WAIT** for user's task. When received:
- Use TodoWrite to plan the task
- Route to optimal models/agents
- Execute using skills when applicable
- Persist important decisions to memory
