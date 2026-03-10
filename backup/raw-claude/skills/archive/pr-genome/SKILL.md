name: pr-genome
description: Extracts patterns from historical PRs, commits, and code reviews to build institutional knowledge. Based on Roblox's approach that improved AI acceptance from 30% to 60%.

---

# PR Genome Learning Skill

## Purpose

This skill mines historical PRs, commits, and reviews to extract **"gold" patterns** - the implicit expertise embedded in your team's code history. Research shows this approach doubled AI code acceptance rates at scale.

## When to Use

Invoke this skill:
- When onboarding to a new project
- When starting work on an unfamiliar area
- Periodically (weekly) to update pattern library
- After a series of PRs get rejected (learn from failures)

## The Genome Extraction Process

### Phase 1: Historical PR Mining

```bash
# Get recent merged PRs (last 50)
git log --oneline --merges -50

# Get commit history for a specific area
git log --oneline --all -- "src/api/*" | head -20

# Get commits by pattern
git log --oneline --grep="feat:" | head -20
```

### Phase 2: Success Pattern Extraction

For each successful PR/commit, analyze:

| Aspect | Questions | How to Extract |
|--------|-----------|----------------|
| **Size** | How big are typical PRs? | `git log --stat` |
| **Structure** | How are commits organized? | `git log --format="%s"` |
| **Messages** | What commit message style? | `git log --format="%B" -10` |
| **Testing** | What test patterns are used? | Review test files in commits |
| **Reviews** | What gets flagged in reviews? | PR comments (if available) |

### Phase 3: Failure Pattern Mining

**This is critical** - learn from what DIDN'T work:

```bash
# Find reverted commits
git log --oneline --all | grep -i "revert"

# Find fixup commits (indicate problems)
git log --oneline --all | grep -i "fix:"
```

Document failure patterns:
- What patterns led to reverts?
- What mistakes are commonly fixed?
- What review comments appear repeatedly?

### Phase 4: Style Guide Generation

From the extracted patterns, generate a style guide:

```markdown
## Extracted Style Guide: [Project Name]

### Commit Messages
- Format: `type(scope): description`
- Types used: feat, fix, refactor, test, docs, chore
- Max length: ~72 characters
- Body: Used for breaking changes only

### PR Size
- Typical LOC: 50-200 lines
- Max files: 5-10 files
- One concern per PR

### Code Patterns
- Error handling: [extracted pattern]
- Naming: [extracted pattern]
- Testing: [extracted pattern]

### Common Review Feedback
- "Add tests for edge case X"
- "Follow existing pattern in Y"
- "Missing error handling for Z"
```

## Output Format

After running PR genome extraction:

```markdown
## PR Genome Report: [Project/Area]

### Analyzed
- Commits reviewed: X
- Date range: [from] to [to]
- Areas covered: [list]

### Success Patterns (Gold Standards)
1. **[Pattern Name]**
   - Example commit: `abc123`
   - Why it works: [explanation]
   - Apply when: [conditions]

2. **[Pattern Name]**
   ...

### Failure Patterns (Anti-Patterns)
1. **[Anti-Pattern Name]**
   - Example: `def456` (reverted in `ghi789`)
   - Why it failed: [explanation]
   - Avoid when: [conditions]

### Extracted Rules
```yaml
commit_style:
  format: "type(scope): description"
  max_length: 72

pr_guidelines:
  max_lines: 200
  max_files: 10
  require_tests: true

code_patterns:
  error_handling: "[pattern]"
  naming_convention: "[pattern]"
```

### Recommendations for AI Agents
1. Always [recommendation from patterns]
2. Never [anti-pattern to avoid]
3. When [condition], follow [pattern]
```

## Integration with Other Skills/Agents

### With Architect Planner
- Planner reads genome to understand project conventions
- Plans align with historical success patterns

### With Code Worker
- Worker references genome before implementation
- Uses "gold" examples as templates

### With Code Judge
- Judge validates against genome patterns
- Flags deviations from established patterns

## Automation Script

Run this periodically to update genome:

```bash
#!/bin/bash
# genome-update.sh

PROJECT_ROOT=$(pwd)
GENOME_FILE="$HOME/.claude/session-memory/pr-genome-$(basename $PROJECT_ROOT).md"

echo "# PR Genome: $(basename $PROJECT_ROOT)" > $GENOME_FILE
echo "Updated: $(date)" >> $GENOME_FILE
echo "" >> $GENOME_FILE

echo "## Recent Commits" >> $GENOME_FILE
git log --oneline -30 >> $GENOME_FILE
echo "" >> $GENOME_FILE

echo "## Commit Message Patterns" >> $GENOME_FILE
git log --format="%s" -50 | sort | uniq -c | sort -rn | head -20 >> $GENOME_FILE
echo "" >> $GENOME_FILE

echo "## File Change Frequency" >> $GENOME_FILE
git log --name-only --format="" -50 | sort | uniq -c | sort -rn | head -20 >> $GENOME_FILE

echo "Genome updated: $GENOME_FILE"
```

## Memory Persistence

Store extracted patterns in Memory MCP:

```javascript
// Persist key patterns
memory.create({
  entity: "[project-name]-genome",
  entityType: "pattern-library",
  observations: [
    "Commit format: type(scope): description",
    "Typical PR size: 50-200 lines",
    "Error pattern: throw new CustomError(message, code)",
    "Test pattern: describe/it with beforeEach setup",
    "Review focus: edge cases, error handling, naming"
  ]
})
```

## Success Metrics

Track genome effectiveness:
- PR acceptance rate before/after genome use
- Number of review cycles before merge
- Revert frequency
- Time from PR open to merge

Target improvements (based on Roblox research):
- PR acceptance: 30% → 60%+
- Review cycles: 3+ → <2
- Revert rate: Decrease by 50%
