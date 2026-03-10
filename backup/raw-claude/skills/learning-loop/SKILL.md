---
name: learning-loop
description: Extract learnings from sessions and update rule files. Human-gated policy updates.
allowed-tools: Read, Write, Edit, Bash(python:*), Bash(cat:*), Bash(grep:*), mcp__memory__*
metadata:
  version: "2.0.0"
  author: odedbe
---

# Learning Loop Skill

**Purpose**: Close the feedback loop by extracting learnings, adding them to rule files, and persisting architectural decisions to Memory MCP.

---

## When to Use

- At session end (automatically via `/end-of-session`)
- After completing a significant task
- When a new pattern is discovered
- When a failure teaches something valuable

---

## Workflow

### Step 1: Extract Learnings

From the current session, identify:

```markdown
## Session Learnings

### What Worked Well
1. [Pattern/approach that succeeded]
   - Context: [when it was used]
   - Why it worked: [reasoning]

### What Failed
1. [Pattern/approach that failed]
   - Context: [when it was used]
   - Why it failed: [reasoning]
   - How to avoid: [prevention]

### Decisions Made
1. [Decision]
   - Alternatives considered: [list]
   - Rationale: [why this choice]
```

### Step 2: Check for Duplicates

Before adding a new pattern, check if it already exists:

```bash
# Search existing rule files for the pattern
grep -ri "<keyword>" ~/.claude/rules/*.md
grep -ri "<keyword>" ~/.claude/checklists/*.md
```

If the pattern is already captured (even partially), skip or enhance the existing rule instead of duplicating.

### Step 3: Add to Appropriate Rule File

**Target file selection**:

| Learning Domain | Target File |
|----------------|-------------|
| Python/TS standards, testing, debugging | `rules/code-quality.md` |
| Azure Functions, Durable, activities | `rules/azure-functions.md` |
| Azure deploy, pipelines, git | `rules/azure-deploy.md` |
| ML models, predictions, evaluation | `rules/ml-production.md` |
| Multi-stage pipelines, transcription | `rules/pipeline-safety.md` |
| FastAPI, SSE, streaming, middleware | `rules/fastapi-streaming.md` |
| LangGraph, agents, state, validation | `rules/langgraph-patterns.md` |
| RAG, embeddings, vector DB | `rules/rag-production.md` |
| Database safety, queries, schema | `rules/db-safety.md` |
| File cleanup, deletion safety | `rules/cleanup-safety.md` |

**Format for new rules**:

```markdown
## [Rule Name] (MANDATORY if applicable)

[Concise description of what to do/not do]

[Code example if helpful — keep short]

Origin: [Project] [Date] — [What happened that taught this lesson]
```

**IMPORTANT**: Always include an `Origin:` tag so future reviews know where the rule came from.

### Step 4: Update Checklists (if applicable)

If the learning relates to a specific action phase, update the relevant checklist:

| Action Phase | Checklist File |
|-------------|---------------|
| Deploying | `checklists/before-deploy.md` |
| Refactoring | `checklists/before-refactor.md` |
| Creating new files | `checklists/before-new-file.md` |
| Pipeline changes | `checklists/before-pipeline-change.md` |
| ML changes | `checklists/before-ml-change.md` |
| Bug fixes | `checklists/before-bugfix.md` |

Add a new checkbox item to the relevant section.

### Step 5: Persist to Memory MCP

For architectural decisions that should persist across sessions:

```
Entity: [project-name]-decisions
Type: architectural_decision
Observations:
- [YYYY-MM-DD] [Decision description]
```

**Standardized entity types** (use ONLY these):
- `architectural_decision` — cross-session design choices
- `session_learnings` — per-project learning summaries
- `engineering_pattern` — reusable technical patterns
- `project_knowledge` — project-specific context

### Step 6: Propose Policy Updates (Human-Gated)

If learnings suggest changes to CLAUDE.md or Hard Rules, propose them:

```markdown
## Proposed Policy Update

**Current Rule** (in `~/.claude/[file]`):
[current text]

**Proposed Change**:
[new text]

**Reasoning**:
[Why this change based on learnings]

**Approve?** [User must confirm]
```

NEVER auto-apply policy updates. Always present for human approval.

---

## Integration Points

### Session Start
1. Load relevant Memory MCP entities for current project
2. Check recent checklists for the task type
3. Apply learnings to current session

### Session End
1. Extract learnings (this skill)
2. Add to rule files (with Origin tags)
3. Update checklists if applicable
4. Persist to Memory MCP
5. Propose policy updates if needed
6. Update project status.json

---

## Pattern Evolution Rules

### Promotion Criteria
- Pattern used 5+ times successfully → Add to rule file if not already there
- Anti-pattern occurs 3+ times → Add warning to rule file

### Demotion Criteria
- Rule becomes obsolete (technology changed) → Archive with note
- Rule causes more harm than good → Remove after human approval

---

## Skill Health Check

After each skill invocation, append a JSONL entry to `~/.claude/patterns/skill-health.jsonl`:

```jsonl
{"date": "2026-02-20", "skill_name": "go", "triggered_correctly": true, "completed_workflow": true, "user_corrections": 0, "notes": ""}
```

Review when skill-health.jsonl exceeds 100 entries. Present findings for human approval.

---

## Anti-Pattern: Self-Modification Without Gate

**CRITICAL**: The learning loop NEVER:
- Auto-modifies CLAUDE.md
- Auto-modifies rules/*.md without presenting the change first
- Auto-changes capabilities-registry.json
- Auto-updates agent definitions

All changes are PROPOSED and require human approval.

---

*Learning System v2.0 — Rules-first architecture, no JSON pattern files*
