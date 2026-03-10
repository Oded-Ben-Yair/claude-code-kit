#!/usr/bin/env bash
# Hook: tool-failure-tracker.sh
# Event: PostToolUseFailure
# Purpose: Log tool failures for debugging patterns.
#
# Data arrives via STDIN as JSON with fields:
#   tool_name, tool_input, tool_response, session_id
#
# Appends JSONL to ~/.claude/telemetry/tool-failures-YYYY-MM-DD.jsonl

trap 'exit 0' ERR

TELEMETRY_DIR="/home/odedbe/.claude/telemetry"
mkdir -p "$TELEMETRY_DIR"

LOGFILE="$TELEMETRY_DIR/tool-failures-$(date +%Y-%m-%d).jsonl"

# Read JSON from stdin
STDIN_DATA=""
if [[ ! -t 0 ]]; then
    STDIN_DATA="$(cat)"
fi

# No input = nothing to do
if [[ -z "${STDIN_DATA}" ]]; then
    exit 0
fi

# Extract fields and write JSONL entry
echo "${STDIN_DATA}" | python3 -c "
import json, sys
from datetime import datetime, timezone

try:
    d = json.load(sys.stdin)
    tool_response = d.get('tool_response', {})
    error_msg = tool_response.get('stderr', '') or tool_response.get('error', '') or ''

    # Classify error type from the message
    error_type = 'unknown'
    error_lower = error_msg.lower()
    if 'timeout' in error_lower:
        error_type = 'timeout'
    elif 'permission' in error_lower or 'denied' in error_lower:
        error_type = 'permission'
    elif 'not found' in error_lower or 'no such' in error_lower:
        error_type = 'not_found'
    elif 'connection' in error_lower or 'network' in error_lower:
        error_type = 'network'
    elif 'syntax' in error_lower or 'parse' in error_lower:
        error_type = 'syntax'
    elif error_msg:
        error_type = 'runtime'

    entry = {
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'event': 'tool_failure',
        'tool_name': d.get('tool_name', 'unknown'),
        'error_type': error_type,
        'error_message': error_msg[:500],
        'session_id': d.get('session_id', 'unknown')
    }
    print(json.dumps(entry))
except Exception:
    pass
" >> "$LOGFILE" 2>/dev/null

exit 0
