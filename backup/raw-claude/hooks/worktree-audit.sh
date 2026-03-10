#!/usr/bin/env bash
# Hook: worktree-audit.sh
# Event: WorktreeCreate, WorktreeRemove
# Purpose: Log worktree creation/removal for audit trail.
#
# Data arrives via STDIN as JSON with fields:
#   worktree_path, branch_name, session_id, event_type

trap 'exit 0' ERR

TELEMETRY_DIR="/home/odedbe/.claude/telemetry"
mkdir -p "$TELEMETRY_DIR"

LOGFILE="$TELEMETRY_DIR/worktree-$(date +%Y-%m-%d).jsonl"

# Read JSON from stdin
STDIN_DATA=""
if [[ ! -t 0 ]]; then
    STDIN_DATA="$(cat)"
fi

if [[ -z "${STDIN_DATA}" ]]; then
    exit 0
fi

# Log the worktree event
echo "${STDIN_DATA}" | python3 -c "
import json, sys
from datetime import datetime, timezone

try:
    d = json.load(sys.stdin)
    entry = {
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'event': d.get('event_type', 'worktree_unknown'),
        'worktree_path': d.get('worktree_path', 'unknown'),
        'branch_name': d.get('branch_name', 'unknown'),
        'session_id': d.get('session_id', 'unknown')
    }
    print(json.dumps(entry))
except Exception:
    pass
" >> "$LOGFILE" 2>/dev/null

echo "worktree audit logged"
exit 0
