---
name: ultra-plan
description: Task decomposition with capability mapping (use EnterPlanMode + enforce-capabilities instead)
---

# Ultra-Plan - Superseded by Built-in Planning

**This skill has been replaced by a simpler workflow.**

## The New Approach

Instead of a complex "ultra-plan" skill, use the built-in planning flow:

### Step 1: Enter Plan Mode
```
Use EnterPlanMode tool (or Claude auto-enters for complex tasks)
```

### Step 2: Claude Plans
- Explores codebase
- Identifies approach
- Writes plan to `docs/plans/` or presents inline

### Step 3: Capability Enrichment (Optional but Recommended)
Before executing, invoke:
```
/enforce-capabilities
```

This enriches each plan step with:
- Appropriate agent (e.g., `codex-builder`, `gemini-doc-parser`)
- Required skills (e.g., `/frontend`, `/pattern-first`)
- MCP tools to use
- Confidence score

### Step 4: Execute
Exit plan mode and implement with the enriched plan.

## Quick Capability Reference

The routing is now automatic via the session-start hook. Check the injected table at session start, or reference:

```
~/.claude/rules/capability-routing.md
```

## Example Workflow

**User**: "Build a dashboard with real-time metrics"

**Claude** (auto-enters plan mode):
1. Research existing dashboard patterns
2. Design component architecture
3. Implement data fetching layer
4. Build visualization components
5. Add real-time updates
6. Test and validate

**User**: "/enforce-capabilities"

**Claude** (enriches plan):
1. Research → `perplexity_search` + `/pattern-first`
2. Design → `azure_brainstorm`
3. Implement data → `codex-builder` agent
4. Build viz → `/frontend` skill + `gemini` for design
5. Real-time → `codex-builder` agent
6. Test → `playwright` MCP + `gemini-analyze-image`

**User**: "Proceed"

**Claude**: Executes with optimal tools for each step.

## Why Not a Separate "Ultra-Plan" Skill?

1. **Claude already plans well** - EnterPlanMode triggers thorough planning
2. **Capability mapping is separate** - `/enforce-capabilities` handles enrichment
3. **Reduces complexity** - One less skill to maintain
4. **Hooks inject context** - Routing table available automatically

## For Complex Multi-Phase Projects

Use the playbooks skill for predefined workflows:
```
/playbooks
```

Available templates:
- `/feature` - New feature (Architect → Worker → Judge → Memo)
- `/bugfix` - Bug fix (TDD → Worker → Judge → Memo)
- `/refactor` - Refactoring (Review → Architect → Worker → Review)
