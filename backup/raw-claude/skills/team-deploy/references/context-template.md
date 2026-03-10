# Team Context: {team-name}

## Goal

{Specific, measurable objective for this team. What does "done" look like?}

## Current State

- **Project**: {project-name} ({project-path})
- **Branch**: {git branch}
- **Uncommitted changes**: {count}
- **Tests**: {pass/fail status}
- **Build**: {OK/broken}
- **Last deploy**: {date and status}

## Key Files

| File | Purpose | Owner |
|------|---------|-------|
| {file-path} | {what it does} | {teammate-name} |
| {file-path} | {what it does} | {teammate-name} |

## Patterns to Follow

- {Pattern 1 from existing codebase — naming, structure, error handling}
- {Pattern 2}
- {Pattern 3}

## Decisions Made (This Session)

- {Decision 1}: {rationale}
- {Decision 2}: {rationale}

## Decisions Pending (For Team to Resolve)

- {Open question 1}: {context, present options to lead}
- {Open question 2}: {context}

## Constraints

- File ownership: Each teammate owns distinct files. No two teammates edit the same file.
- Model: ALL teammates use Opus 4.6 (Rule 13).
- Max teammates: 4 (cost + rate limit control).
- Shared memory: Read/write ~/.claude/teams/{team-name}/team-memory.md for coordination.
- Plan approval: Required for any changes to `shared/` or database schemas.
- No mock data: Use real files, real errors, real test results (Rule 1).
- No GitHub: Azure DevOps only (Rule 8).

## Dependencies

- {External dependency 1}: {status — available/blocked/pending}
- {External dependency 2}: {status}

## Success Criteria

1. {Criterion 1 — specific, testable}
2. {Criterion 2}
3. {Criterion 3}
