#!/usr/bin/env bash
# Hook: config-change-audit.sh
# Event: ConfigChange
# Purpose: Log settings changes and warn on security-relevant modifications.
#
# Fires when settings.json or settings.local.json change during a session.
# Data arrives via STDIN as JSON with fields:
#   file_path, changes, session_id

trap 'exit 0' ERR

TELEMETRY_DIR="/home/odedbe/.claude/telemetry"
mkdir -p "$TELEMETRY_DIR"

LOGFILE="$TELEMETRY_DIR/config-changes-$(date +%Y-%m-%d).jsonl"

# Read JSON from stdin
STDIN_DATA=""
if [[ ! -t 0 ]]; then
    STDIN_DATA="$(cat)"
fi

if [[ -z "${STDIN_DATA}" ]]; then
    exit 0
fi

# Log the change and check for security-relevant modifications
RESULT=$(echo "${STDIN_DATA}" | python3 -c "
import json, sys
from datetime import datetime, timezone

try:
    d = json.load(sys.stdin)
    file_path = d.get('file_path', 'unknown')
    session_id = d.get('session_id', 'unknown')

    entry = {
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'event': 'config_change',
        'file_path': file_path,
        'session_id': session_id
    }

    # Write to telemetry log
    with open('$LOGFILE', 'a') as f:
        f.write(json.dumps(entry) + '\n')

    # Check for security-relevant changes
    raw = json.dumps(d).lower()
    security_keywords = ['permissions', 'deny', 'allow', 'mcpservers', 'hooks']
    warnings = [kw for kw in security_keywords if kw in raw]

    if warnings:
        print(f'WARNING: Config change in {file_path} affects security-relevant keys: {warnings}', file=sys.stderr)
except Exception:
    pass
" 2>&1)

# Surface warnings to user via stderr (shows in hook output)
if [[ -n "$RESULT" && "$RESULT" == WARNING* ]]; then
    echo "$RESULT" >&2
fi

exit 0
