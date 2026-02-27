---
name: multi-model-debate
description: |
  Multi-model debate with 6 LLMs and 5 rounds of cross-critique for complex decisions.
  Use when you need:
  - Deep analysis of complex problems
  - Multiple perspectives on architecture/design decisions
  - Validation of approaches through argumentation
  - Best-of-breed synthesis from diverse AI models

  Keywords: debate, brainstorm, multi-model, cross-critique, consensus, argumentation
allowed-tools: Read, Write, mcp__vertex-ai__*, mcp__gemini__*, mcp__grok__*, mcp__perplexity__*
context: fork
metadata:
  version: "1.0.0"
  author: odedbe
---

# Multi-Model Debate Skill

## Overview
Orchestrates a structured debate between 6 AI models across 5 rounds to reach well-reasoned conclusions.

## Optimized Council Composition

The debate council is structured with specific roles based on model benchmarks and specializations:

| Role | Model | MCP Tool | Context | Strength |
|------|-------|----------|---------|----------|
| **Orchestrator** | Claude Opus 4.6 | (native) | 200k | Final synthesis, adjudication, context management |
| **Logic/Conservative** | GPT-5.2 | `vertex_chat` | 400k | Near-perfect recall, structured reasoning |
| **Contrarian/Real-time** | Grok-4 | `grok_chat` or `grok_reason` | 256k | Live Search, X/Twitter data, adversarial thinking |
| **Evidence Engine** | Perplexity | `perplexity_reason` | 128k | Citations, source verification, fact-checking |
| **Multimodal/Context** | Gemini 3 Pro | `gemini-query` (thinking_level=high) | 1M | 91.9% GPQA Diamond, abstract reasoning |
| **Creative/Ideation** | GPT-5 Pro | `vertex_brainstorm` | - | Divergent thinking, creativity benchmarks |
| **Code Expert** | Codex Max | `vertex_code_review` | - | 80% SWE-bench, technical implementation |

### Role Descriptions

- **Orchestrator (Claude)**: Manages debate flow, synthesizes positions, produces final recommendation
- **Logic/Conservative (GPT-5.2)**: Provides structured, systematic reasoning; questions assumptions
- **Contrarian/Real-time (Grok-4)**: Challenges consensus, injects real-time data from X/social, identifies blind spots
- **Evidence Engine (Perplexity)**: Verifies claims, provides citations, grounds arguments in sources
- **Multimodal/Context (Gemini)**: Handles visual elements, abstract reasoning, massive context
- **Creative/Ideation (GPT-5 Pro)**: Proposes novel approaches, creative solutions
- **Code Expert (Codex Max)**: Technical implementation details, code-specific trade-offs

**Note**: Gemini 3 Pro uses `thinking_level: high` for debates. Grok-4 can use `grok_reason` with `reasoning_effort: high` for exposed thought process.

**Note:** GPT-5 Pro and Codex Max use the Responses API. The MCP server handles routing automatically.

## Debate Protocol

### Round 1: Initial Positions (~60 sec)
Each model provides its independent analysis of the problem.

**Prompt each model:**
```
Topic: [TOPIC]

Provide your initial position on this topic. Include:
1. Your recommended approach
2. Key reasoning points (3-5)
3. Potential concerns or risks
4. Confidence level (High/Medium/Low)

Be specific and actionable. ~200 words.
```

### Round 2: Cross-Critique (~90 sec)
Each model critiques 2 other models' positions.

**Assignment matrix (role-based):**
- **Claude (Orchestrator)** critiques Creative (GPT-5 Pro) + Multimodal (Gemini)
- **GPT-5.2 (Logic)** critiques Contrarian (Grok-4) + Creative (GPT-5 Pro)
- **Grok-4 (Contrarian)** critiques Logic (GPT-5.2) + Code Expert (Codex Max) - *injects real-time counter-signals*
- **Perplexity (Evidence)** critiques ALL positions - *fact-checks claims, adds citations*
- **Gemini (Multimodal)** critiques Logic (GPT-5.2) + Creative (GPT-5 Pro)
- **GPT-5 Pro (Creative)** critiques Contrarian (Grok-4) + Logic (GPT-5.2)
- **Codex Max (Code)** critiques Logic (GPT-5.2) + Creative (GPT-5 Pro) - *technical feasibility only*

**Critique prompt:**
```
Review these two positions on [TOPIC]:

Position A: [MODEL_A_POSITION]
Position B: [MODEL_B_POSITION]

For each, identify:
1. Strongest points (1-2)
2. Weaknesses or blind spots (1-2)
3. Missing considerations
4. Questions that need answering
```

### Round 3: Response to Critiques (~60 sec)
Models defend or update their positions based on critiques.

**Response prompt:**
```
Your original position on [TOPIC] received these critiques:
[CRITIQUES]

Respond by:
1. Addressing valid criticisms
2. Defending strong points
3. Updating your position if warranted
4. New confidence level
```

### Round 4: Synthesis Attempt (~60 sec)
Each model proposes a synthesized solution combining best elements.

**Synthesis prompt:**
```
Based on all positions and critiques on [TOPIC], propose a synthesis:

1. Core approach (combining best elements)
2. Key trade-offs acknowledged
3. Implementation priority
4. Remaining uncertainties
5. Final confidence level
```

### Round 5: Final Ranking (~30 sec)
Claude (as orchestrator) ranks all approaches and produces final recommendation.

**Ranking criteria:**
- Feasibility (can it be done?)
- Completeness (does it address all concerns?)
- Consensus (how much agreement?)
- Risk mitigation (are downsides addressed?)

## Output Format

```markdown
## Multi-Model Debate Results

### Topic
[TOPIC]

### Final Recommendation
[SYNTHESIZED RECOMMENDATION]

### Confidence: [HIGH/MEDIUM/LOW]

### Key Insights from Debate
1. [INSIGHT 1]
2. [INSIGHT 2]
3. [INSIGHT 3]

### Areas of Agreement
- [POINT 1]
- [POINT 2]

### Areas of Divergence
- [POINT 1]: Model A says X, Model B says Y
- [POINT 2]: ...

### Risk Factors
- [RISK 1]: Mitigation: [STRATEGY]
- [RISK 2]: Mitigation: [STRATEGY]

### Implementation Steps
1. [STEP 1]
2. [STEP 2]
3. [STEP 3]
```

## Parameters

| Parameter | Options | Default |
|-----------|---------|---------|
| `depth` | `quick` (3 rounds), `full` (5 rounds) | `full` |
| `models` | subset or `all` | `all` |
| `focus` | `code`, `architecture`, `design`, `strategy` | `strategy` |
| `mode` | `sequential` (default), `teams` | `sequential` |

## Agent Teams Mode (Parallel Execution)

When Agent Teams is enabled, the debate can run with teammates for true parallel execution instead of sequential MCP calls.

### How It Works

The lead Claude spawns 4-6 teammates, each assigned a model perspective via their MCP tools:

| Teammate | Model Role | Primary MCP Tool |
|----------|-----------|------------------|
| logic-analyst | Logic/Conservative | `vertex_chat` (GPT-5.2) |
| contrarian | Contrarian/Real-time | `grok_reason` (Grok-4) |
| evidence-checker | Evidence Engine | `perplexity_reason` |
| abstract-reasoner | Multimodal/Context | `gemini-query` (thinking=high) |
| creative-ideator | Creative/Ideation | `vertex_brainstorm` (GPT-5 Pro) |
| code-expert | Code Expert | `vertex_code_review` (Codex Max) |

### Debate Flow with Teams

**Round 1** (Parallel): All teammates analyze independently. Each receives the topic and produces their initial position using their assigned MCP tool. All run simultaneously.

**Round 2** (Peer Messaging): Each teammate reads others' Round 1 findings via task list and cross-critiques. The critique assignment matrix from the sequential protocol applies.

**Round 3** (Parallel): Teammates defend or update their positions based on received critiques.

**Round 4** (Parallel): Each teammate proposes a synthesis combining best elements.

**Round 5** (Lead Only): The lead Claude synthesizes all teammate outputs into the final recommendation.

### When to Use Teams vs Sequential

| Factor | Sequential (Default) | Teams (Parallel) |
|--------|---------------------|-------------------|
| Latency | ~3 min (serial) | ~1 min (parallel rounds) |
| Token cost | Lower (shared context) | Higher (per-teammate overhead) |
| Depth | All models see full history | Teammates work from summaries |
| Best for | Nuanced, deeply referenced debates | Speed-critical decisions, broad coverage |

### Invoking with Teams

```
/multi-model-debate --mode=teams
Topic: "Your question here"
```

The lead will automatically create the team, assign roles, and orchestrate the rounds.

## Usage Examples

### Architecture Decision
```
Invoke multi-model-debate:
Topic: "Should we use microservices or monolith for our new e-commerce platform?"
Focus: architecture
Depth: full
```

### Code Approach
```
Invoke multi-model-debate:
Topic: "Best approach to implement real-time notifications: WebSockets vs SSE vs polling"
Focus: code
Depth: full
```

### Strategy Decision
```
Invoke multi-model-debate:
Topic: "Pricing strategy for our SaaS product: freemium vs trial vs paid-only"
Focus: strategy
Depth: quick
```

## Execution Checklist

1. [ ] Clarify topic with user
2. [ ] Round 1: Get initial positions from all 6 models
3. [ ] Round 2: Execute cross-critique assignments
4. [ ] Round 3: Collect responses to critiques
5. [ ] Round 4: Request synthesis from each model
6. [ ] Round 5: Claude produces final ranking and recommendation
7. [ ] Present formatted results to user

## Notes

- **Latency**: Sequential mode ~3 minutes. Teams mode ~1 minute (parallel rounds)
- **Token usage**: ~15-20k tokens total
- **MCP activation**: Requires perplexity, gemini, grok, and vertex-ai MCPs enabled
- **Best for**: High-stakes decisions where multiple perspectives matter
- **Grok advantage**: Contrarian role can inject real-time social signals via `grok_x_search`
- **Perplexity advantage**: Evidence role fact-checks all claims with citations
- **Gemini advantage**: Use for visual/multimodal decisions (UI, design, architecture diagrams)

## Auto-Trigger Conditions

This skill should be automatically invoked when:
- High-stakes architectural decisions
- Multiple viable approaches with similar trade-offs
- Production apps with significant risk
- WLNK confidence < 0.5 after initial analysis
- User explicitly requests "debate" or "multiple perspectives"
