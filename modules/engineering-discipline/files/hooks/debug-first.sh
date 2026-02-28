#!/usr/bin/env bash
# Hook: debug-first.sh
# Event: PreToolUse (Bash tools containing "git commit")
# Purpose: If tests were recently failing, ensure debug steps happened before commit.
# Exit 2 = BLOCK, Exit 0 = PASS

# Safety: internal failures must never crash Claude Code UI.
trap 'exit 0' ERR

TELEMETRY_DIR="${CLAUDE_HOME:-$HOME/.claude}/telemetry"
VIOLATIONS_LOG="${TELEMETRY_DIR}/violations.jsonl"
# Agent-ID prefixed flags for multi-agent isolation
agent_id="${CLAUDE_SESSION_ID:-global}"
TEST_FAILURE_FLAG="/tmp/claude-testfail-${agent_id}.flag"
TEST_FAILURE_FLAG_GLOBAL="/tmp/claude-test-failure.flag"
DEBUG_TRACE_FLAG="/tmp/claude-debug-${agent_id}.flag"
DEBUG_TRACE_FLAG_GLOBAL="/tmp/claude-debug-trace.flag"

log_violation() {
    local hook_name="$1"
    local violation_type="$2"
    local message="$3"
    local input_snippet="${4:-}"
    local timestamp
    timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    mkdir -p "${TELEMETRY_DIR}"
    printf '{"timestamp":"%s","hook_name":"%s","violation_type":"%s","message":"%s","tool_input_snippet":"%s"}\n' \
        "${timestamp}" "${hook_name}" "${violation_type}" \
        "$(echo "${message}" | head -c 200 | sed 's/"/\\"/g')" \
        "$(echo "${input_snippet}" | head -c 200 | sed 's/"/\\"/g')" \
        >> "${VIOLATIONS_LOG}"
}

# Only process Bash tool calls
tool_name="${CLAUDE_TOOL_USE_NAME:-}"
if [[ "${tool_name}" != "Bash" ]]; then
    exit 0
fi

# Read tool input
input="${CLAUDE_TOOL_USE_INPUT:-}"
if [[ -z "${input}" ]]; then
    exit 0
fi

# Check if this is a git commit command
if ! echo "${input}" | grep -qi 'git commit'; then
    exit 0
fi

# Check if tests were recently failing (agent-specific first, then global)
active_failure_flag=""
for flag_path in "${TEST_FAILURE_FLAG}" "${TEST_FAILURE_FLAG_GLOBAL}"; do
    if [[ -f "${flag_path}" ]]; then
        flag_age_seconds=0
        if command -v stat &>/dev/null; then
            flag_mtime="$(stat -c %Y "${flag_path}" 2>/dev/null || echo "0")"
            now="$(date +%s)"
            flag_age_seconds=$(( now - flag_mtime ))
        fi
        # If flag is older than 2 hours (7200 seconds), consider it stale
        if [[ "${flag_age_seconds}" -gt 7200 ]]; then
            rm -f "${flag_path}"
        else
            active_failure_flag="${flag_path}"
            break
        fi
    fi
done

# No recent test failures, allow commit
if [[ -z "${active_failure_flag}" ]]; then
    exit 0
fi

# Tests were recently failing - check if debugging happened (agent-specific first, then global)
active_debug_flag=""
for flag_path in "${DEBUG_TRACE_FLAG}" "${DEBUG_TRACE_FLAG_GLOBAL}"; do
    if [[ -f "${flag_path}" ]]; then
        active_debug_flag="${flag_path}"
        break
    fi
done

if [[ -z "${active_debug_flag}" ]]; then
    error_msg="BLOCKED: Tests were failing. Debug first - read error logs, investigate root cause, and fix the issue before committing a bypass."

    log_violation "debug-first" "commit_without_debug" "${error_msg}" "${input}"

    echo '{"error":"commit_without_debug","message":"'"${error_msg}"'"}' >&2
    exit 2
fi

# Debug trace exists - check it's newer than the test failure flag
debug_time="$(stat -c %Y "${active_debug_flag}" 2>/dev/null || echo "0")"
failure_time="$(stat -c %Y "${active_failure_flag}" 2>/dev/null || echo "0")"

if [[ "${debug_time}" -lt "${failure_time}" ]]; then
    error_msg="BLOCKED: Debug trace is older than test failure. Re-investigate the failing tests before committing."

    log_violation "debug-first" "stale_debug_trace" "${error_msg}" "${input}"

    echo '{"error":"stale_debug_trace","message":"'"${error_msg}"'"}' >&2
    exit 2
fi

# Debugging happened after failure - allow commit and clean up flags (agent + global)
rm -f "${TEST_FAILURE_FLAG}" "${TEST_FAILURE_FLAG_GLOBAL}" "${DEBUG_TRACE_FLAG}" "${DEBUG_TRACE_FLAG_GLOBAL}"
exit 0
