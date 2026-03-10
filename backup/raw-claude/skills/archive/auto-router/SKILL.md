---
name: auto-router
description: Automatically route tasks to optimal capability based on intent classification
allowed-tools: Read, Bash(cat:*), Task
---

# Auto-Router Skill

**Purpose**: Analyze user intent and route to the optimal MCP, agent, or skill.

---

## How It Works

1. **Intent Classification**: Analyze user request against `~/.claude/routing/intent-classifier.json`
2. **Capability Selection**: Match to best MCP tool, agent, or skill
3. **Contract Validation**: Verify inputs match `~/.claude/routing/llm-wrapper-contracts.json`
4. **Execution**: Route to selected capability

---

## Routing Table (Quick Reference)

| User Says | Route To | Why |
|-----------|----------|-----|
| "research X", "find out about" | `perplexity_research` | Real-time multi-source |
| "implement", "build", "code" | `code-worker` agent | Implementation specialist |
| "review", "check code" | `code-judge` + `azure_code_review` | Validation |
| "plan", "architect", "design" | `architect-planner` agent | Planning specialist |
| "screenshot", "image", "PDF" | `gemini-*` tools | Vision/document |
| "trending", "X/Twitter" | `grok_social_pulse` | Real-time social |
| "write tweet", "social post" | `grok_brand_content` | Human-like content |
| "brainstorm", "ideas" | `azure_brainstorm` | Creative ideation |
| "prove", "theorem", "algorithm" | `azure_deepseek_reason` | Gold-medal reasoning |
| "library docs", "how to use X" | `context7` | Live documentation |
| "deploy", "Azure" | `/azure-unified` skill | Infrastructure |
| "major decision" | `/multi-model-debate` | Multi-perspective |

---

## Execution Protocol

### Step 1: Classify Intent

Read the user's request and match against intent patterns:

```
Keywords: [matched keywords]
Patterns: [matched patterns]
Intent: [classified intent]
Confidence: [0.0-1.0]
```

### Step 2: Select Route

Based on intent, select:
- **MCP Tool**: Direct tool call (fastest)
- **Agent**: Task with subagent_type (for complex work)
- **Skill**: Skill invocation (for workflows)

### Step 3: Validate Contract

Check inputs against wrapper contract:
- Required fields present?
- Types correct?
- Constraints satisfied?

### Step 4: Execute

Route to selected capability with structured input.

---

## Special Cases

### Ambiguous Intent (Confidence < 0.4)
```
Multiple possible routes detected:
1. [route A] - because [reason]
2. [route B] - because [reason]

Which would you prefer?
```

### Multi-Step Tasks
```
This task requires multiple capabilities:
1. [step 1] → [capability 1]
2. [step 2] → [capability 2]
3. [step 3] → [capability 3]

Proceeding with sequential routing...
```

### Override Available
User can always say:
- "use perplexity" - force specific MCP
- "use gemini" - force specific MCP
- "no routing" - use Claude directly

---

## Integration with Session Hooks

The `session-start-enhanced.sh` hook displays the routing table.
This skill can be invoked explicitly with `/auto-router` or implicitly via the `auto-router.py` hook.

---

## Example Routing Decisions

### Example 1: "Research best practices for React hooks in 2026"
```
Intent: research
Keywords: research, best practices
Confidence: 0.95
Route: perplexity_research
Reason: Research task requiring current information
```

### Example 2: "Implement a login form with validation"
```
Intent: code_generation
Keywords: implement, form
Confidence: 0.9
Route: code-worker agent
Reason: Implementation task
Subtype: None (not complex enough for codex-builder)
```

### Example 3: "What's trending on X about AI today?"
```
Intent: social_realtime
Keywords: trending, X, today
Confidence: 0.98
Route: grok_social_pulse
Reason: Real-time social data required
```

### Example 4: "Analyze this screenshot of our dashboard"
```
Intent: vision_analysis
Keywords: screenshot, analyze
Confidence: 0.95
Route: gemini-analyze-image
Reason: Visual analysis required
```

---

## Metrics Tracking

After each routing decision, log to `~/.claude/routing/routing-log.jsonl`:
```json
{
  "timestamp": "2026-01-23T12:00:00Z",
  "intent": "research",
  "confidence": 0.95,
  "route": "perplexity_research",
  "success": true,
  "feedback": null
}
```

This enables learning which routes work best.

---

*Part of Silent Kernel Architecture v7.0*
