#!/usr/bin/env bash
# Hook: teammate-idle-verify.sh
trap 'exit 0' ERR
# Event: TeammateIdle
# Purpose: Prevent teammates from going idle without proof of work.
# Extends stop-verify.sh logic but scoped to teammates.
# Exit 2 = BLOCK, Exit 0 = PASS

TELEMETRY_DIR="${CLAUDE_HOME:-$HOME/.claude}/telemetry"
VIOLATIONS_LOG="${TELEMETRY_DIR}/violations.jsonl"
TODAY="$(date +%Y-%m-%d)"
TOOL_LOG="${TELEMETRY_DIR}/execution-${TODAY}.jsonl"

# Read hook input from stdin
input=""
if [[ -t 0 ]]; then
    input=""
else
    input="$(cat)"
fi

# Extract teammate info (best effort)
teammate_name=""
if [[ -n "${input}" ]]; then
    teammate_name="$(echo "${input}" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("teammate_name",""))' 2>/dev/null || echo "")"
fi

# Agent-ID prefixed flag support (Phase 2.5)
agent_id="${CLAUDE_SESSION_ID:-global}"
VERIFICATION_FLAG="/tmp/claude-verify-${agent_id}.flag"
VERIFICATION_FLAG_GLOBAL="/tmp/claude-verification-done.flag"

# Check for verification evidence
has_verification=false

# Check 1: Agent-specific verification flag
if [[ -f "${VERIFICATION_FLAG}" ]]; then
    flag_mtime="$(stat -c %Y "${VERIFICATION_FLAG}" 2>/dev/null || echo "0")"
    now="$(date +%s)"
    flag_age=$(( now - flag_mtime ))
    if [[ "${flag_age}" -lt 1800 ]]; then
        has_verification=true
    fi
fi

# Check 2: Global verification flag (backward compat)
if [[ "${has_verification}" == "false" ]] && [[ -f "${VERIFICATION_FLAG_GLOBAL}" ]]; then
    flag_mtime="$(stat -c %Y "${VERIFICATION_FLAG_GLOBAL}" 2>/dev/null || echo "0")"
    now="$(date +%s)"
    flag_age=$(( now - flag_mtime ))
    if [[ "${flag_age}" -lt 1800 ]]; then
        has_verification=true
    fi
fi

# Check 3: Telemetry logs for test/screenshot/analysis tools in last 15 min
if [[ "${has_verification}" == "false" ]] && [[ -f "${TOOL_LOG}" ]]; then
    if tail -50 "${TOOL_LOG}" | grep -q '"tool":"Bash".*\(pytest\|jest\|npm.test\|cargo.test\|go.test\)'; then
        has_verification=true
    fi
    if tail -50 "${TOOL_LOG}" | grep -q 'browser_take_screenshot\|browser_snapshot'; then
        has_verification=true
    fi
    if tail -50 "${TOOL_LOG}" | grep -q 'gemini-analyze-image\|gemini_analyze_image'; then
        has_verification=true
    fi
fi

if [[ "${has_verification}" == "true" ]]; then
    exit 0
fi

# Check 4: Role-based exemption for non-implementation teammates
# Reviewers, analysts, writers, auditors, and planners verify by producing output, not running tests
if [[ -n "${teammate_name}" ]]; then
    teammate_lower="$(echo "${teammate_name}" | tr '[:upper:]' '[:lower:]')"
    non_impl_roles='reviewer|judge|writer|analyst|researcher|auditor|planner|architect|hunter|aligner|reader|checker|inspector|evaluator'
    if echo "${teammate_lower}" | grep -qPi "(${non_impl_roles})"; then
        # Non-implementation role: allow idle without test evidence
        # These roles read, analyze, and report — they don't run pytest/jest
        exit 0
    fi
fi

# No verification evidence found (implementation teammate)
error_msg="BLOCKED: Teammate '${teammate_name:-unknown}' attempting to go idle without verification evidence. Run tests, take screenshots, or analyze visuals before going idle."

mkdir -p "${TELEMETRY_DIR}"
printf '{"timestamp":"%s","hook_name":"teammate-idle-verify","violation_type":"unverified_idle","teammate":"%s"}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "${teammate_name:-unknown}" \
    >> "${VIOLATIONS_LOG}"

echo "${error_msg}" >&2
exit 2
