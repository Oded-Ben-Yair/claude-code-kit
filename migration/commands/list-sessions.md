---
description: Browse and filter session history from session-index.json
argument-hint: [--project=NAME] [--health=MIN] [--days=N] [--limit=N]
allowed-tools: Bash(jq:*), Read
---

# List Sessions Command

Query the session index to find past sessions by project, date, health score, or other criteria.

## Usage

```
/list-sessions                     # Show last 10 sessions
/list-sessions --project=sentimark # Filter by project
/list-sessions --health=75         # Only sessions with health >= 75
/list-sessions --days=7            # Sessions from last 7 days
/list-sessions --limit=20          # Show more results
```

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `--project=NAME` | Filter by project name | All projects |
| `--health=MIN` | Minimum health score | 0 |
| `--days=N` | Only sessions from last N days | All time |
| `--limit=N` | Maximum results to show | 10 |
| `--blockers` | Only sessions that had blockers | false |
| `--json` | Output raw JSON | false |

## Execution

### Step 1: Read Session Index

```bash
INDEX_FILE="$HOME/.claude/session-index.json"
if [ ! -f "$INDEX_FILE" ]; then
    echo "No session index found. Run /end-of-session to create entries."
    exit 0
fi
```

### Step 2: Apply Filters (using jq)

**All sessions (default):**
```bash
jq '.sessions | sort_by(.date) | reverse | .[0:10]' "$INDEX_FILE"
```

**Filter by project:**
```bash
jq --arg proj "$PROJECT" '.sessions | map(select(.project == $proj)) | sort_by(.date) | reverse' "$INDEX_FILE"
```

**Filter by health score:**
```bash
jq --arg min "$MIN_HEALTH" '.sessions | map(select(.health_score >= ($min | tonumber))) | sort_by(.date) | reverse' "$INDEX_FILE"
```

**Filter by date (last N days):**
```bash
CUTOFF=$(date -d "-${DAYS} days" -Iseconds)
jq --arg cutoff "$CUTOFF" '.sessions | map(select(.date >= $cutoff)) | sort_by(.date) | reverse' "$INDEX_FILE"
```

**Sessions with blockers:**
```bash
jq '.sessions | map(select(.blockers != null and (.blockers | length) > 0))' "$INDEX_FILE"
```

### Step 3: Format Output

**Table format (default):**
```
Session History (10 most recent)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| Date       | Project           | Health | Goals   | P0 Next                    |
|------------|-------------------|--------|---------|----------------------------|
| 2026-01-15 | automation-fabric | 85     | 4/5     | Get Key Vault access       |
| 2026-01-14 | sentimark         | 92     | 3/3     | None - session complete    |
| 2026-01-14 | qc-call-analyzer  | 68     | 2/4     | Fix transcript rendering   |

Total: 48 sessions | Avg Health: 78 | Most Active: automation-fabric
```

**JSON format (--json):**
```bash
jq '.sessions | sort_by(.date) | reverse | .[0:10]' "$INDEX_FILE"
```

## Quick Access Commands

**Resume most recent session:**
```
/list-sessions --limit=1
# Then use the session_id to search Memory MCP
```

**Find problematic sessions:**
```
/list-sessions --health=40 --limit=20
```

**Project history:**
```
/list-sessions --project=sentimark --days=30
```

## Memory MCP Integration

To resume a session from the list:

1. Get session_id from list output
2. Search Memory MCP: `mcp__memory__search_nodes("[session_id]")`
3. Read handover file at listed path
4. Continue with P0 task

## Stats Summary

Always show at end:
- Total sessions in index
- Average health score
- Most active project (by session count)
- Sessions this week

## Example Output

```
=== Session History ===

Recent Sessions (showing 5):

1. automation-fabric-session-20260115-a1b2c3
   Date: 2026-01-15 16:30 UTC
   Health: 85/100 (Good)
   Goals: 4/5 achieved
   P0: Get Key Vault access from admin
   Handover: .claude/handover-20260115-a1b2c3.md

2. sentimark-session-20260114-def456
   Date: 2026-01-14 14:22 UTC
   Health: 92/100 (Excellent)
   Goals: 3/3 achieved
   P0: None - all goals complete
   Handover: .claude/handover-20260114-def456.md

3. qc-call-analyzer-session-20260114-789abc
   Date: 2026-01-14 10:15 UTC
   Health: 68/100 (Acceptable)
   Goals: 2/4 achieved
   P0: Fix transcript rendering bug
   Handover: .claude/handover-20260114-789abc.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Stats:
  Total Sessions: 48
  Average Health: 78/100
  This Week: 12 sessions
  Most Active: automation-fabric (15 sessions)

Tip: Use session_id with Memory MCP to load full context
```

## Related Commands

- `/end-of-session` - Create new session entry
- `/go [id]` - Load session from Memory MCP
- `/session-health` - Check current session health
