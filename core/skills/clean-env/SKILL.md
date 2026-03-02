---
name: clean-env
description: |
  Deep WSL + Windows cleanup. Kills orphan processes, clears caches, reclaims memory.
  Keywords: clean, cleanup, environment, slow, stuck, heavy, fresh
argument-hint: "[--dry-run | --wsl-only | --windows-only | --aggressive]"
allowed-tools: Bash(*), Read
disable-model-invocation: true
metadata:
  version: "1.0.0"
  author: odedbe
---

# /clean-env — Environment Cleanup Skill

You are running the `/clean-env` skill. Follow these phases in order.

## Arguments

Parse `$ARGUMENTS` for flags:
- `--dry-run`: Show what would be cleaned without making changes
- `--wsl-only`: Skip Windows cleanup
- `--windows-only`: Skip WSL cleanup
- `--aggressive`: Include node_modules removal (WSL only)

If no arguments, run full cleanup (WSL + Windows) with confirmation.

## Phase 1: Assess [5s]

Run the assessment script:

```bash
bash ${CLAUDE_HOME:-$HOME/.claude}/scripts/clean-assess.sh
```

Present the output to the user as a formatted table. Highlight:
- Memory status (critical if <500MB available)
- Orphaned processes count and RAM usage
- Largest caches

## Phase 2: Confirm

Unless `--dry-run` was passed, ask the user what to clean:
- Show the assessment results summary
- Ask: "What should I clean?" with options based on what was found
- If `--dry-run`, skip confirmation and just run with --dry-run flags

## Phase 3: Clean WSL [30s]

Skip if `--windows-only` was passed.

Run WSL cleanup with appropriate flags:

```bash
bash ${CLAUDE_HOME:-$HOME/.claude}/scripts/clean-wsl.sh [--dry-run] [--aggressive]
```

Pass `--dry-run` if the user chose dry-run mode.
Pass `--aggressive` if the user chose aggressive mode or passed `--aggressive`.

**FAIL MODE**: If the script errors, report the error and continue to Phase 4.

## Phase 4: Clean Windows [20s]

Skip if `--wsl-only` was passed.

Run Windows cleanup:

```bash
bash ${CLAUDE_HOME:-$HOME/.claude}/scripts/clean-windows.sh [--dry-run]
```

**FAIL MODE**: If the script errors or cmd.exe is unavailable, report and continue.

## Phase 5: Verify [5s]

Re-run the assessment to show before/after:

```bash
bash ${CLAUDE_HOME:-$HOME/.claude}/scripts/clean-assess.sh
```

Present a before/after comparison showing:
- Memory freed
- Disk reclaimed
- Processes killed
- Current system status

## Error Handling

- If ANY script fails, report the error clearly and continue to the next phase
- Never abort the entire cleanup because one phase failed
- All scripts use `trap 'exit 0' ERR` so they should not crash, but handle gracefully anyway
