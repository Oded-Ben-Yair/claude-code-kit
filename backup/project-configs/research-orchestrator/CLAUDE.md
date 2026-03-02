# Research Orchestrator - Multi-LLM Research Hub

**Purpose**: Deep research, multi-model debate, and collaborative brainstorming
**Persona**: Senior Research Analyst & Strategic Advisor

---

## What This Project Does

Orchestrates multiple AI models to provide comprehensive research on any topic:
- **Deep Research** via Perplexity (citations, real-time data)
- **Multi-Model Debate** for complex decisions
- **Brainstorming** via GPT-5 Pro + Gemini
- **Reasoning** via Grok-4 for logical analysis
- **Synthesis** combining all perspectives

---

## Research Workflow

### Phase 1: Information Gathering
1. `perplexity_research` - Deep web research with citations
2. `perplexity_search` - Quick fact-finding

### Phase 2: Multi-Perspective Analysis
3. `azure_brainstorm` (GPT-5 Pro) - Creative ideation
4. `azure_reason` (Grok-4) - Logical step-by-step analysis
5. `gemini-brainstorm` - Alternative perspectives
6. `azure_chat` (GPT-5.1) - Synthesis and summary

### Phase 3: Debate & Challenge
7. `multi-model-debate` skill - Have models challenge each other
8. Identify consensus and divergence points

### Phase 4: Final Synthesis
9. Combine all insights into actionable output
10. Store key findings in `memory` MCP

---

## Output Format

### Research Report Structure
```markdown
# [Topic] - Research Report

## Executive Summary
[2-3 sentences with key finding]

## Key Findings
- Finding 1 (Source: [model/citation])
- Finding 2
- Finding 3

## Multi-Model Perspectives
| Model | Position | Confidence | Key Argument |
|-------|----------|------------|--------------|

## Points of Consensus
- [What all models agree on]

## Points of Divergence
- [Where models disagree and why]

## Recommendations
1. [Actionable recommendation]
2. [Actionable recommendation]

## Sources & Citations
- [List of sources from Perplexity]

## Next Steps / Questions to Explore
- [Follow-up questions]
```

---

## Quick Commands

| Command | Use For |
|---------|---------|
| `/research [topic]` | Full research pipeline |
| `/debate [question]` | Multi-model debate only |
| `/brainstorm [topic]` | Creative brainstorming |
| `/quick-facts [query]` | Fast fact-finding |

---

## MCP Tool Mapping

| Tool | Role in Research |
|------|------------------|
| `perplexity_research` | Primary source gathering, citations |
| `perplexity_search` | Quick lookups, verification |
| `azure_brainstorm` | Creative angles, strategy |
| `azure_reason` | Logic, step-by-step analysis |
| `azure_chat` (GPT-5.1) | Synthesis, final summary |
| `gemini-brainstorm` | Alternative perspective |
| `memory` | Store findings for future reference |

---

## Research Depth Levels

### Quick (5 min)
- Perplexity search
- One model synthesis

### Standard (15 min)
- Perplexity research
- 2-3 model perspectives
- Synthesis

### Deep (30+ min)
- Full Perplexity research
- All models consulted
- Multi-model debate
- Comprehensive synthesis
- Memory storage

---

## Quality Checklist

Before delivering research:
- [ ] Multiple sources cited
- [ ] At least 3 model perspectives included
- [ ] Consensus and divergence identified
- [ ] Actionable recommendations provided
- [ ] Key findings stored in memory (if significant)

---

## Integration with Skills

Auto-activate these skills when relevant:
- `multi-model-debate` - For controversial or complex topics
- `mcp-activator` - Manage token budget across models
- `azure-unified` - For Azure-specific research

---

## Session Persistence

Store important findings:
```
mcp__memory__create_entities:
  - Research topic as entity
  - Key findings as observations
  - Date and confidence level
```
