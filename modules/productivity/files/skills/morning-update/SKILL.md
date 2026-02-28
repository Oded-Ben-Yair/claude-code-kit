---
name: morning-update
description: Review daily research findings and propose rule updates at session start. Triggers on "morning update", "daily briefing", "what's new", "/morning-update".
allowed-tools: Read, Bash(cat:*), Bash(python:*), mcp__memory__*
metadata:
  version: "1.0.0"
---

# Morning Update Skill

**Purpose**: Start each day by reviewing research updates, proposing improvements, and setting focus.

---

## When to Invoke

- First session of the day
- User says "morning update", "daily briefing", "what's new"

---

## Workflow

### Step 1: Load Research Updates

```bash
cat {CLAUDE_HOME}/research/daily-updates.md | tail -50
```

Look for entries from the last 24-48 hours that haven't been reviewed.

### Step 2: Present Findings

```markdown
## Morning Update - [DATE]

### Research Findings

**Topic**: [Research topic from daily-updates.md]

**Key Findings**:
1. [Finding 1]
2. [Finding 2]
3. [Finding 3]

**Relevance to Your Work**:
[How this applies to current projects/workflow]
```

### Step 3: Propose Rule Updates (If Applicable)

```markdown
### Proposed Updates

Based on research findings, I recommend:

**Update 1**: [Rule file] - [Section]
- Current: [current text]
- Proposed: [new text]
- Reason: [why based on research]

**Approve these updates?**
- [ ] Update 1
- [ ] Skip all
```

### Step 4: Pattern Review

```markdown
### Pattern Health Check

**Most Used Success Patterns (Last 7 Days)**:
1. [Pattern] - [X] uses
2. [Pattern] - [X] uses

**Recurring Issues**:
1. [Anti-pattern] - [X] occurrences
   -> Consider: [mitigation]

**Focus Recommendation**:
[Based on patterns, suggest focus area for today]
```

### Step 5: Memory MCP Check

Query Memory MCP for recent decisions that might affect today's work:

```
Search: [project-name]-decisions
Show: Last 5 entries
Highlight: Any blocking decisions or pending items
```

---

## Research Topics Rotation

The daily research rotates through these topics:

| Day | Topic |
|-----|-------|
| Monday | Claude Code best practices |
| Tuesday | MCP server development patterns |
| Wednesday | Multi-agent orchestration LLM |
| Thursday | Context engineering optimization |
| Friday | LangGraph vs custom orchestration |
| Saturday | (catch-up on pending) |
| Sunday | (review week's learnings) |

---

## Policy Update Protocol

**HUMAN-GATED**: All policy updates require explicit approval.

### Automatic Proposal Triggers
- Research finding contradicts current rule
- Success pattern has 10+ successful uses
- Failure pattern has 5+ occurrences
- Memory MCP shows recurring decision

### Update Process
1. Present proposed change
2. Show evidence/reasoning
3. Wait for user response
4. If approved: Apply change, log to Memory MCP
5. If rejected: Log rejection reason, don't propose again

### What Can Be Updated
- `{CLAUDE_HOME}/rules/*.md` - Behavior rules
- `{CLAUDE_HOME}/CLAUDE.md` - Main configuration
- Routing and capability configuration files

### What Cannot Be Auto-Updated
- MCP server configurations
- Credentials or secrets
- Project-specific CLAUDE.md files
- Production deployment configs

---

## Example Morning Update

```markdown
## Morning Update - January 24, 2026

### Research Findings

**Topic**: Context engineering optimization

**Key Findings**:
1. Progressive context loading reduces errors by 40%
2. Explicit schema definitions improve multi-model coordination
3. Memory MCP persistence prevents "fresh start" syndrome

**Relevance**:
- Consider adding explicit schemas to agent handoffs

### Proposed Updates

Based on finding #2, I recommend:

**Update 1**: `rules/code-quality.md` - Task Handoff Structure
- Add: "Include JSON schema for expected output format in task handoffs"
- Reason: Research shows 35% improvement in agent coordination with explicit schemas

**Approve?** [Yes/No/Skip]

### Pattern Health

**Top Success Pattern**: Pattern-First Development (8 uses, 100% success)
**Recurring Issue**: None in last 48 hours

**Today's Focus**: Last session left off at database schema design.

### Memory Check
- [2026-01-22] Project: Chose PostgreSQL over MongoDB for time-series
- [2026-01-20] Project: Deployed v2.3 to production
```

---

## Integration

### With Session Start Hook
The session-start hook can trigger morning update if:
- First session of day (check timestamp)
- Research updates pending (check daily-updates.md)

### With Learning Loop
Morning update feeds into learning loop:
- Approved updates -> Added to patterns
- Rejected updates -> Logged for future reference
