# Agent Audit Report

**Date**: 2026-01-23
**Purpose**: Identify essential agents vs redundant agents per Silent Kernel Architecture

---

## Target Architecture (3 Core Specialists)

Per the architecture plan, we need:

1. **Planner** - Analyzes, plans, decomposes (no code)
2. **Implementer** - Writes code based on plans
3. **Verifier** - Reviews, tests, validates

Additional supporting agents can exist but should be minimal.

---

## Current Agents (31 total)

### Essential - Keep (7)

| Agent | Role | Why Essential |
|-------|------|---------------|
| `architect-planner.md` | Planner | Core role - planning/design |
| `code-worker.md` | Implementer | Core role - code execution |
| `code-judge.md` | Verifier | Core role - review/validation |
| `azure-devops-specialist.md` | Infrastructure | User-specific Azure workflow |
| `cleanup-specialist.md` | Janitor | Part of cleanup protocol |
| `design-specialist.md` | Frontend | UI/UX work |
| `multi-llm-orchestrator.md` | Router | Capability routing |

### Redundant - Consider Consolidating (24)

**Gemini-based (7)** → Consolidate to 1 "Gemini Specialist"
- gemini-asset-producer.md
- gemini-deep-reasoner.md
- gemini-design-coder.md (→ merge into design-specialist)
- gemini-doc-parser.md
- gemini-ui-auditor.md
- gemini-video-analyzer.md
- gemini-viz-generator.md

**Perplexity-based (4)** → Consolidate to 1 "Research Specialist"
- perplexity-academic-researcher.md
- perplexity-deep-research.md
- perplexity-geo-researcher.md
- perplexity-sec-analyst.md

**Grok-based (4)** → Consolidate to 1 "Real-time Specialist"
- grok-brand-writer.md
- grok-code-fast.md (→ merge into code-worker)
- grok-competitive-intel.md
- grok-social-pulse.md

**GPT-5-based (4)** → Consolidate to 1 "Reasoning Specialist"
- codex-max-builder.md (→ merge into code-worker)
- deepseek-speciale-reasoner.md
- gpt5-pro-brainstormer.md
- gpt5-pro-decision-panel.md
- gpt52-context-weaver.md

**Other (5)**
- seo-aeo-analyst.md (→ specialized, keep as-is)
- worktree-specialist.md (→ specialized, keep as-is)

---

## Recommended Consolidation Plan

### Phase 1: No Deletion (Safe)
1. Create consolidated agent definitions
2. Keep original files as backup
3. Update routing to use consolidated agents

### Phase 2: After Testing
1. Archive original agents to `agents/archive/`
2. Verify consolidated agents work
3. Delete archived files after 30 days

---

## Consolidated Agent Definitions

### 1. Gemini Specialist (NEW)
Combines: doc-parser, asset-producer, video-analyzer, viz-generator, ui-auditor, deep-reasoner, design-coder

```yaml
Triggers: PDF, document, image, video, vision, accessibility, OCR
MCP Tools: All mcp__gemini__* tools
Use when: Any visual/document analysis or image generation
```

### 2. Research Specialist (NEW)
Combines: academic-researcher, deep-research, geo-researcher, sec-analyst

```yaml
Triggers: research, investigate, find out, papers, SEC, financial
MCP Tools: All mcp__perplexity__* tools
Use when: Any research/information gathering task
```

### 3. Real-time Specialist (NEW)
Combines: brand-writer, social-pulse, competitive-intel

```yaml
Triggers: X/Twitter, trending, social, competitive, real-time
MCP Tools: All mcp__grok__* social tools
Use when: Social media or real-time information
```

### 4. Reasoning Specialist (NEW)
Combines: deepseek-reasoner, gpt5-brainstormer, gpt5-decision-panel, context-weaver

```yaml
Triggers: brainstorm, reason, prove, complex analysis, decision
MCP Tools: azure_brainstorm, azure_deepseek_reason, azure_reason
Use when: Complex reasoning, math, algorithms
```

---

## Action Items

- [ ] Create consolidated agent files
- [ ] Update CLAUDE.md routing table
- [ ] Test consolidated agents
- [ ] Archive original agents after validation
- [ ] Monitor for issues

---

*Part of Silent Kernel Architecture v7.0*
