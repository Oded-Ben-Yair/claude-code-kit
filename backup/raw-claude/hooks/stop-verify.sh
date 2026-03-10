#!/usr/bin/env bash
# Hook: stop-verify.sh (v2.1)
# Event: Stop
# Purpose: Block Claude from claiming "done" without ACTUAL verification tool usage.
# v2 change: Checks telemetry logs for real tool calls, not just response text.
# v2.1: Removed set -euo pipefail — internal failures must never crash Claude Code UI.
# Exit 2 = BLOCK, Exit 0 = PASS

# SAFETY: If this hook crashes for ANY reason, pass through (exit 0) — never crash the UI.
trap 'exit 0' ERR

TELEMETRY_DIR="/home/odedbe/.claude/telemetry"
VIOLATIONS_LOG="${TELEMETRY_DIR}/violations.jsonl"
TODAY="$(date +%Y-%m-%d)"
TOOL_LOG="${TELEMETRY_DIR}/execution-${TODAY}.jsonl"
# Agent-ID prefixed flags for multi-agent isolation (Phase 2.5)
agent_id="${CLAUDE_SESSION_ID:-global}"
VERIFICATION_FLAG="/tmp/claude-verify-${agent_id}.flag"
VERIFICATION_FLAG_GLOBAL="/tmp/claude-verification-done.flag"

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

# Read the assistant's final response from environment variable
body="${CLAUDE_STOP_HOOK_BODY:-}"

# If no body provided, pass through
if [[ -z "${body}" ]]; then
    exit 0
fi

body_length="${#body}"

# Very short messages or simple acknowledgments - allow
if [[ "${body_length}" -lt 50 ]]; then
    exit 0
fi

# Check for simple acknowledgment patterns (case-insensitive)
body_lower="$(echo "${body}" | tr '[:upper:]' '[:lower:]')"

# Simple acks - allow regardless
if echo "${body_lower}" | grep -qP '^\s*(ok|okay|sure|done|understood|got it|will do|noted|ack|yes|no|right|correct)\s*\.?\s*$'; then
    exit 0
fi

# Check for completion language
has_completion=false
completion_patterns="complete|completed|done|fixed|working now|implemented|finished|resolved|all set|task complete|implementation complete|changes applied|bug fixed|issue resolved|all hooks.*pass|all tests.*pass|everything.*working"
if echo "${body_lower}" | grep -qPi "(${completion_patterns})"; then
    has_completion=true
fi

# If no completion language, allow
if [[ "${has_completion}" == "false" ]]; then
    exit 0
fi

# === V2: Check ACTUAL tool usage from telemetry, not just response text ===

verification_tool_used=false

# Check 1: Was a verification flag explicitly set? (by test-result-tracker or manual)
# Check agent-specific flag first, then fall back to global
for flag_path in "${VERIFICATION_FLAG}" "${VERIFICATION_FLAG_GLOBAL}"; do
    if [[ -f "${flag_path}" ]]; then
        flag_age_seconds=0
        if command -v stat &>/dev/null; then
            flag_mtime="$(stat -c %Y "${flag_path}" 2>/dev/null || echo "0")"
            now="$(date +%s)"
            flag_age_seconds=$(( now - flag_mtime ))
        fi
        # Flag valid for 30 minutes
        if [[ "${flag_age_seconds}" -lt 1800 ]]; then
            verification_tool_used=true
            break
        fi
    fi
done

# Check 2: Check telemetry logs for actual verification tool calls in last 15 min
if [[ "${verification_tool_used}" == "false" ]] && [[ -f "${TOOL_LOG}" ]]; then
    fifteen_min_ago="$(date -u -d '15 minutes ago' +%Y-%m-%dT%H:%M 2>/dev/null || date -u +%Y-%m-%dT%H:%M)"

    # Look for test runners (Bash with pytest/jest/npm test)
    if tail -50 "${TOOL_LOG}" | grep -q '"tool":"Bash".*\(pytest\|jest\|npm.test\|cargo.test\|go.test\)'; then
        verification_tool_used=true
    fi

    # Look for playwright screenshots
    if tail -50 "${TOOL_LOG}" | grep -q 'browser_take_screenshot\|browser_snapshot'; then
        verification_tool_used=true
    fi

    # Look for gemini image analysis
    if tail -50 "${TOOL_LOG}" | grep -q 'gemini-analyze-image\|gemini_analyze_image'; then
        verification_tool_used=true
    fi
fi

# Check 3: Fallback — check response text for CONCRETE proof (not just keywords)
# Must contain actual output like exit codes, file paths, or command results
if [[ "${verification_tool_used}" == "false" ]]; then
    concrete_proof_patterns='exit code|Exit code|\$ pytest|\$ npm test|PASSED|FAILED|[0-9]+ passed|[0-9]+ tests|\.png|\.jpg|screenshot saved|error: 0|errors: 0|warnings: 0'
    if echo "${body}" | grep -qPi "(${concrete_proof_patterns})"; then
        verification_tool_used=true
    fi
fi

# Check 4: Pipeline-specific output verification (fail-118)
# If response mentions pipeline/processing changes, require OUTPUT metrics not just status
if [[ "${verification_tool_used}" == "true" ]]; then
    pipeline_keywords='pipeline|processing|speaker detection|diarization|transcript|segmentation'
    if echo "${body_lower}" | grep -qPi "(${pipeline_keywords})"; then
        # Pipeline work detected — check for actual output metrics
        output_metrics='segment.*(count|[0-9]+)|speaker.*(label|count|[0-9]+)|[0-9]+ segments|[0-9]+ speakers|length ratio|hallucination|output.*inspect'
        if ! echo "${body_lower}" | grep -qPi "(${output_metrics})"; then
            warn_msg="WARNING: Pipeline changes detected but no output metrics reported. Remember fail-118: status=completed does NOT mean output is correct. Verify segment counts, speaker labels, and length ratios."
            echo "${warn_msg}" >&2
            # Warn only, don't block — the base verification check already passed
        fi
    fi
fi

if [[ "${verification_tool_used}" == "true" ]]; then
    # Clean up flags (agent + global)
    rm -f "${VERIFICATION_FLAG}" "${VERIFICATION_FLAG_GLOBAL}"
    exit 0
fi

# Completion language found WITHOUT real verification evidence - BLOCK
error_msg="BLOCKED: Response claims completion but no verification tools were used. Run tests (pytest/jest), take screenshots (playwright), or analyze visuals (gemini) BEFORE claiming done. Text like 'verified' is not enough — show actual tool output."

log_violation "stop-verify" "unverified_completion" "${error_msg}" "${body}"

echo '{"error":"unverified_completion","message":"'"${error_msg}"'"}' >&2
exit 2
