#!/usr/bin/env bash
# Hook: subagent-stop-tracker.sh
# Event: SubagentStop
# Purpose: Log subagent duration and metadata to telemetry.
#
# Data arrives via STDIN as JSON with fields:
#   tool_name, tool_input, tool_response, session_id
#
# Appends JSONL to ~/.claude/telemetry/subagent-YYYY-MM-DD.jsonl

trap 'exit 0' ERR

TELEMETRY_DIR="${CLAUDE_HOME:-$HOME/.claude}/telemetry"
mkdir -p "$TELEMETRY_DIR"

LOGFILE="$TELEMETRY_DIR/subagent-$(date +%Y-%m-%d).jsonl"

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
    tool_input = d.get('tool_input', {})
    tool_response = d.get('tool_response', {})

    agent_name = tool_input.get('agent_name', '') or tool_input.get('prompt', '')[:80] if tool_input.get('prompt') else 'unknown'
    duration_ms = tool_response.get('duration_ms', 0) or 0
    status = 'success' if not tool_response.get('error') else 'failed'

    entry = {
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'event': 'subagent_stop',
        'agent_name': agent_name,
        'duration_ms': duration_ms,
        'status': status,
        'session_id': d.get('session_id', 'unknown')
    }
    print(json.dumps(entry))
except Exception:
    pass
" >> "$LOGFILE" 2>/dev/null

exit 0
