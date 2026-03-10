---
name: clean-env
description: |
  Deep WSL + Windows cleanup. Kills orphan processes, clears caches, reclaims memory.
  Keywords: clean, cleanup, environment, slow, stuck, heavy, fresh
argument-hint: "[--dry-run | --wsl-only | --windows-only | --aggressive]"
allowed-tools: Bash(*), Read
disable-model-invocation: true
metadata:
  version: "2.0.0"
  author: odedbe
---

# /clean-env — Environment Cleanup Skill

You are running the `/clean-env` skill. Follow these phases in order.

## Arguments

Parse `$ARGUMENTS` for flags:
- `--dry-run`: Show what would be cleaned without making changes
- `--wsl-only`: Skip Windows cleanup
- `--windows-only`: Skip WSL cleanup
- `--aggressive`: Include node_modules removal, shorter cache thresholds (WSL only)

If no arguments, run full cleanup (WSL + Windows) with confirmation.

## Phase 1: Assess [5s]

Run the assessment script and capture to file (direct stdout unreliable due to sleep commands):

```bash
bash /home/odedbe/.claude/scripts/clean-assess.sh > /tmp/clean-assess-before.txt 2>&1
```

Then read `/tmp/clean-assess-before.txt` and present to the user as a formatted table. Highlight:
- Memory status (critical if <500MB available)
- Orphaned processes count and RAM usage
- Largest caches

## Phase 2: Confirm

**Skip confirmation if** `--dry-run` OR `--aggressive` was passed — these are explicit intents.

Otherwise, ask the user what to clean:
- Show the assessment results summary
- Ask: "What should I clean?" with options based on what was found

## Phase 3: Clean WSL [30s]

Skip if `--windows-only` was passed.

**CRITICAL: Always redirect to file** — the script contains sleep commands that cause the Bash tool to return empty output when run directly. Use:

```bash
bash /home/odedbe/.claude/scripts/clean-wsl.sh [--dry-run] [--aggressive] > /tmp/clean-wsl-output.txt 2>&1
```

Then `Read /tmp/clean-wsl-output.txt` and present the results.

Pass `--dry-run` if the user chose dry-run mode.
Pass `--aggressive` if the user chose aggressive mode or passed `--aggressive`.

**FAIL MODE**: If the output file is empty or the script errors, report and continue.

## Phase 4: Clean Windows [20s]

Skip if `--wsl-only` was passed.

```bash
bash /home/odedbe/.claude/scripts/clean-windows.sh [--dry-run] > /tmp/clean-windows-output.txt 2>&1
```

Then `Read /tmp/clean-windows-output.txt` and present the results.

**FAIL MODE**: If the script errors or cmd.exe is unavailable, report and continue.

## Phase 5: Verify [5s]

Re-run the assessment:

```bash
bash /home/odedbe/.claude/scripts/clean-assess.sh > /tmp/clean-assess-after.txt 2>&1
```

Read both `/tmp/clean-assess-before.txt` and `/tmp/clean-assess-after.txt`. Present a before/after comparison showing:
- Memory freed
- Disk reclaimed
- Processes killed
- Current system status

## Error Handling

- If ANY script fails, report the error clearly and continue to the next phase
- Never abort the entire cleanup because one phase failed
- Scripts use `set +e` (not `trap ERR`) so individual command failures are handled inline
- **Always redirect script output to /tmp files** — sleep commands in scripts cause empty Bash tool output
