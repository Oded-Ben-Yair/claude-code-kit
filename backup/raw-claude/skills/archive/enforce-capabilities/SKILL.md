---
name: enforce-capabilities
description: Auto-enriches plans with proper agent/skill/MCP usage before execution. Run after planning, before approval.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Enforce Capabilities Skill

## Purpose

This skill ensures every plan step is enriched with the appropriate agents, skills, and MCPs from your capability ecosystem before execution begins. It prevents underutilization of your powerful toolset.

## When This Skill Runs

**Automatically triggered** via post-plan hook when:
1. A plan file is written to `docs/plans/`
2. Before `ExitPlanMode` approval prompt
3. When explicitly invoked via `/enforce-capabilities`

## The Enrichment Process

### Step 1: Load Capability Registry

Read `~/.claude/capabilities-registry.json` which contains:
- **21 Agents**: gemini-doc-parser, codex-max-builder, perplexity-deep-research, etc.
- **12 Skills**: smart-router, multi-model-debate, brainstorming, etc.
- **5 MCPs**: memory, perplexity, gemini, azure-ai-foundry, playwright

### Step 2: Parse Plan Steps

Extract each step from the plan. For each step, identify:
- **Intent**: research, parse, code, test, review, deploy, design, document, decide
- **Artifacts**: files, APIs, data mentioned
- **Complexity**: simple (1 tool) vs complex (multi-tool)
- **Risk level**: low/medium/high based on irreversibility

### Step 3: Match Capabilities

For each step, use multi-tier matching:

**Tier 1 - Keyword Match (Fast)**
```
Step: "Parse the uploaded requirements.pdf"
Match: triggers contain "parse" + "pdf" → gemini-doc-parser (confidence: 0.95)
```

**Tier 2 - Intent Classification**
```
Step: "Research best practices for authentication"
Intent: research → perplexity MCP + perplexity-deep-research agent
```

**Tier 3 - Complexity Analysis**
```
Step: "Design and implement the user dashboard"
Complex step → multiple capabilities:
- design-to-code skill (design phase)
- codex-max-builder agent (implementation)
- premium-frontend skill (quality)
```

### Step 4: Apply Matching Rules

From `capabilities-registry.json`:
- Max 1 agent per step
- Max 2 skills per step
- Max 2 MCPs per step
- Confidence threshold: 0.6
- Always consider memory MCP for decisions/artifacts

### Step 5: Enrich Plan In-Place

Rewrite each step with capability annotations:

**Before:**
```markdown
3. Analyze the codebase architecture and identify patterns
```

**After:**
```markdown
3. Analyze the codebase architecture and identify patterns
   → Agent: `gpt52-context-weaver` (long-context synthesis)
   → MCP: `memory` (persist architectural findings)
   → Confidence: 0.87
```

### Step 6: Add Execution Metadata

Append a machine-readable block at the end of the plan:

```yaml
---
# Capability Mapping (auto-generated)
enrichment_version: 1.0
enriched_at: 2025-12-20T13:45:00Z
steps:
  - id: 1
    agent: gemini-doc-parser
    skills: []
    mcps: [gemini]
    confidence: 0.92
  - id: 2
    agent: codex-max-builder
    skills: [smart-router]
    mcps: [azure-ai-foundry, memory]
    confidence: 0.85
  - id: 3
    agent: null
    skills: [multi-model-debate]
    mcps: [perplexity, azure-ai-foundry]
    confidence: 0.78
---
```

## High-Value Capability Mappings

### Research Tasks
| Pattern | Recommended Capability |
|---------|----------------------|
| "research", "find out", "investigate" | `perplexity` MCP + `perplexity-deep-research` agent |
| "academic", "peer-reviewed", "citations" | `perplexity-academic-researcher` agent |
| "SEC", "10-K", "financial" | `perplexity-sec-analyst` agent |
| "trending", "social media", "X/Twitter" | `grok-social-pulse` agent |

### Document/Media Tasks
| Pattern | Recommended Capability |
|---------|----------------------|
| "parse PDF", "extract from document" | `gemini-doc-parser` agent |
| "analyze image", "screenshot" | `gemini` MCP with HIGH resolution |
| "design to code", "implement UI" | `design-to-code` skill + `gemini-design-coder` agent |
| "video", "recording" | `gemini-video-analyzer` agent |

### Code Tasks
| Pattern | Recommended Capability |
|---------|----------------------|
| "implement", "build feature", "refactor" | `codex-max-builder` agent |
| "code review", "check quality" | `azure_code_review` MCP tool |
| "full codebase", "large context" | `gpt52-context-weaver` agent |

### Decision Tasks
| Pattern | Recommended Capability |
|---------|----------------------|
| "complex decision", "trade-offs" | `multi-model-debate` skill |
| "compare options", "evaluate" | `gpt5-pro-decision-panel` agent |
| "architectural decision" | `multi-model-debate` + `memory` MCP |

### Persistence Tasks
| Pattern | Recommended Capability |
|---------|----------------------|
| "remember", "store decision", "persist" | `memory` MCP |
| "for future sessions" | `memory` MCP with entities/relations |

## Validation Rules

Before finalizing enrichment, validate:

1. **No Conflicts**: Agent doesn't require MCP that's not included
2. **Cost Awareness**: High-cost steps are justified by complexity
3. **Coverage**: Every non-trivial step has at least one capability
4. **Memory for Decisions**: Architectural decisions → memory MCP

## Output Format

The enriched plan maintains human readability while adding machine-parseable metadata:

```markdown
## Implementation Plan (Enriched)

### Phase 1: Research & Discovery

1. Research authentication best practices for SaaS applications
   → Agent: `perplexity-deep-research`
   → MCP: `perplexity`
   → Output: `research_notes.md` with citations

2. Analyze existing auth code in the codebase
   → Agent: `gpt52-context-weaver`
   → MCP: `azure-ai-foundry`
   → Output: Architecture summary

### Phase 2: Implementation

3. Implement OAuth2 flow with Azure AD
   → Agent: `codex-max-builder`
   → Skills: `azure-unified`
   → MCP: `azure-ai-foundry`, `memory`
   → Output: Auth module + tests

4. Create login UI components
   → Agent: `codex-max-builder`
   → Skills: `premium-frontend`
   → Output: React components

---
# Execution Metadata
enrichment_version: 1.0
total_steps: 4
capabilities_used:
  agents: [perplexity-deep-research, gpt52-context-weaver, codex-max-builder]
  skills: [azure-unified, premium-frontend]
  mcps: [perplexity, azure-ai-foundry, memory]
estimated_cost_tier: high
---
```

## Integration with Plan Mode

This skill integrates with Claude Code's planning workflow:

1. **User enters plan mode** → Claude creates plan
2. **Plan written to file** → Post-plan hook triggers
3. **This skill runs** → Analyzes and enriches plan
4. **Enriched plan shown** → User approves/declines
5. **On approval** → Execution uses capability mappings

## Manual Invocation

If automatic enrichment didn't trigger, run manually:

```
/enforce-capabilities
```

Or reference in your prompt:
```
Before executing this plan, use the enforce-capabilities skill to ensure proper tool usage.
```

## Fallback Behavior

If enrichment fails or confidence is too low:
- Show original plan with warning banner
- List suggested capabilities without auto-applying
- Allow manual override

## Continuous Improvement

After execution, the skill can:
1. Track which enrichments were accepted/modified
2. Log which capabilities were actually used
3. Feed back to improve matching over time (via memory MCP)
