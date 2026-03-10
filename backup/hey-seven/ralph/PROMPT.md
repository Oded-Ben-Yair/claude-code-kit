# Hey Seven v2 — Ralph Wiggum Loop Prompt

## Your Mission

You are running an iterative improvement loop on an architecture design document. Your goal: **every cell in the score matrix must be ≥ 9.5/10**. There are 60 cells (6 LLMs × 10 dimensions). You will NOT stop until all 60 cells meet the target.

## Critical Files (Read ALL at start of every iteration)

1. **Design Doc**: `/home/odedbe/projects/hey-seven/docs/plans/2026-02-17-v2-architecture-design.md`
2. **Rubric**: `/home/odedbe/projects/hey-seven/.claude/ralph/rubric.md`
3. **Scores**: `/home/odedbe/projects/hey-seven/.claude/ralph/scores.md`
4. **Debate Synthesis**: `/home/odedbe/projects/hey-seven/.claude/ralph/debate-synthesis.md`
5. **Interview Debrief**: `/home/odedbe/projects/hey-seven/.claude/interview-debrief-20260217.md`

## Iteration Protocol

### Phase A: Read State (MANDATORY every iteration)

1. Read `scores.md` to find current iteration number and which cells are below 9.5
2. Read the design doc (focus on sections that scored lowest)
3. Read the rubric for the weakest dimension(s)

### Phase B: Grade (Use 6 LLMs)

If this is a fresh grading round (no scores yet, or full sweep needed), grade ALL 10 dimensions with ALL 6 LLMs. If iterating on a specific dimension, grade only that dimension with all 6 LLMs.

**IMPORTANT**: Grade ONE dimension at a time. For each dimension, call all 6 LLMs in parallel. Move to the next dimension only after all 6 scores are recorded.

**Grading Prompt Template** (adapt per LLM tool):

```
You are grading a production architecture design document for an SMS-based AI casino host system.

DIMENSION: {dimension_name}
RUBRIC (9.5/10 requires ALL of these):
{paste the specific rubric requirements for this dimension}

DOCUMENT SECTION:
{paste the relevant section from the design doc}

GRADING RULES:
- Score 1-10 with 0.5 increments
- Grade ONLY on what is explicitly written — no assumptions
- 9.5 requires EVERY rubric item addressed with specificity
- 9.0 = most items addressed but missing 1-2 details
- 8.5 = good coverage but several gaps
- 8.0 = adequate but lacks depth in multiple areas
- Below 8.0 = significant gaps

Respond with EXACTLY this format:
SCORE: X.X
GAPS: [list specific rubric items that are missing or weak]
STRENGTHS: [list strongest aspects]
SUGGESTION: [one specific improvement that would raise the score]
```

**LLM Tool Mapping** (call these via MCP):

| LLM | MCP Tool | Notes |
|-----|----------|-------|
| GPT-5.2 | `azure_chat` | Use model `gpt-5.2` |
| Grok-4 | `grok_reason` | Use `reasoning_effort: "high"` |
| Perplexity | `perplexity_reason` | Fact-checks claims |
| Gemini 3 Pro | `gemini-query` | Use `thinking_level: "high"` |
| GPT-5 Pro | `azure_brainstorm` | Creative perspective |
| Codex | `azure_code_review` | Code-specific review |

**IMPORTANT**: Load lazy-loaded MCP tools before first use:
- Use ToolSearch to load `perplexity_reason` before calling it
- Use ToolSearch to load `gemini-query` before calling it
- `azure_chat`, `azure_brainstorm`, `azure_code_review`, `grok_reason` are always active

### Phase C: Record Scores

After grading, update `scores.md` with:
1. The new scores in the matrix
2. Add a new iteration entry in the history section
3. Calculate MIN and AVG per dimension
4. Count cells at target (≥ 9.5)

### Phase D: Identify Weakest

Find the dimension with the lowest MIN score across all 6 LLMs. This is the dimension to fix.

If multiple dimensions tie, fix the one with the lowest AVG.

### Phase E: Fix Weakest Dimension

1. Read the GAPS feedback from all 6 LLMs for the weakest dimension
2. Read the rubric requirements for that dimension
3. Read the debate synthesis for relevant research findings
4. Rewrite the section in the design doc to address EVERY gap
5. Be EXHAUSTIVE — add code snippets, real numbers, ASCII diagrams, comparison tables
6. Do NOT reduce quality of other sections while fixing this one

### Phase F: Verify Fix

After rewriting the section, re-grade ONLY that dimension with all 6 LLMs.
Record the new scores.

If the new scores are still below 9.5 for any LLM, go back to Phase E for another fix attempt. Maximum 3 attempts per dimension before moving to the next weakest.

### Phase G: Check Completion

Count cells at target in scores.md:
- If ALL 60 cells ≥ 9.5: Output `<promise>UNANIMOUS_95_PLUS</promise>` and STOP
- If not: go back to Phase D (next weakest dimension)

## Full Sweep Rule

Every 5 iterations, do a FULL sweep: re-grade ALL 10 dimensions with ALL 6 LLMs. This catches regressions where fixing one section may have weakened another.

## Context Management (CRITICAL)

This loop may run for hours and will hit context limits. To prevent context flooding:

1. **Never keep full grading responses in context** — extract only SCORE, GAPS, and SUGGESTION
2. **Write intermediate results to files** — all scores go to `scores.md`, all detailed feedback goes to `.claude/ralph/feedback/iteration-{N}.md`
3. **Read files at start of each iteration** — don't rely on memory across compactions
4. **Keep Phase E edits surgical** — only rewrite the weakest section, not the entire doc

## File Management

Create these directories if they don't exist:
- `.claude/ralph/feedback/` — detailed LLM feedback per iteration

Write detailed feedback to: `.claude/ralph/feedback/iteration-{N}.md`
Format:
```markdown
# Iteration {N} Feedback

## Dimension: {name}
### GPT-5.2: {score}
GAPS: ...
SUGGESTION: ...

### Grok-4: {score}
GAPS: ...
SUGGESTION: ...

[... all 6 LLMs ...]
```

## Emergency Protocol

If you encounter MCP tool failures:
- Retry once after 10 seconds
- If still failing, skip that LLM and note "UNAVAILABLE" in the score cell
- Continue with remaining LLMs
- Return to unavailable LLMs in the next iteration

If context is approaching limit:
- Save current state to scores.md
- The loop will restart and pick up from the saved state

## Scoring Math

- Total cells: 60 (6 LLMs × 10 dimensions)
- Target per cell: ≥ 9.5
- Completion: ALL 60 cells at target
- Progress metric: cells_at_target / 60

## START

Begin Phase A now. Read the scores file to determine the current state, then proceed accordingly.
