#!/usr/bin/env bash
# Hook: task-completed-verify.sh
trap 'exit 0' ERR
# Event: TaskCompleted
# Purpose: Quality gate before any task can be marked complete.
# Checks task subject keywords to determine required evidence.
# Exit 2 = BLOCK, Exit 0 = PASS

TELEMETRY_DIR="/home/odedbe/.claude/telemetry"
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

# Extract task info (best effort)
task_id=""
task_subject=""
teammate_name=""
if [[ -n "${input}" ]]; then
    task_id="$(echo "${input}" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("task_id",""))' 2>/dev/null || echo "")"
    task_subject="$(echo "${input}" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("task_subject",""))' 2>/dev/null || echo "")"
    teammate_name="$(echo "${input}" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("teammate_name",""))' 2>/dev/null || echo "")"
fi

subject_lower="$(echo "${task_subject}" | tr '[:upper:]' '[:lower:]')"

# Determine required evidence based on task subject
requires_tests=false
requires_screenshot=false
requires_pipeline=false

# Implementation tasks require test evidence
if echo "${subject_lower}" | grep -qPi '\b(implement|build|create|fix|develop|code|refactor|feature|bug)\b'; then
    requires_tests=true
fi

# Visual/UI tasks require screenshot + vision analysis
if echo "${subject_lower}" | grep -qPi '\b(ui|design|frontend|visual|css|layout|component|page|screen)\b'; then
    requires_screenshot=true
fi

# Deploy tasks require pipeline verification
if echo "${subject_lower}" | grep -qPi '\b(deploy|pipeline|release|push|production|staging)\b'; then
    requires_pipeline=true
fi

# If no specific requirements detected, allow through
if [[ "${requires_tests}" == "false" ]] && [[ "${requires_screenshot}" == "false" ]] && [[ "${requires_pipeline}" == "false" ]]; then
    exit 0
fi

# Check for evidence in telemetry logs
has_test_evidence=false
has_screenshot_evidence=false
has_pipeline_evidence=false

if [[ -f "${TOOL_LOG}" ]]; then
    # Test evidence
    if tail -100 "${TOOL_LOG}" | grep -q '"tool":"Bash".*\(pytest\|jest\|npm.test\|cargo.test\|go.test\|vitest\|mocha\)'; then
        has_test_evidence=true
    fi

    # Screenshot evidence
    if tail -100 "${TOOL_LOG}" | grep -q 'browser_take_screenshot'; then
        has_screenshot_evidence=true
    fi
    if tail -100 "${TOOL_LOG}" | grep -q 'gemini-analyze-image\|gemini_analyze_image'; then
        has_screenshot_evidence=true
    fi

    # Pipeline evidence
    if tail -100 "${TOOL_LOG}" | grep -q 'az pipelines\|pipeline.*run\|pipeline.*status'; then
        has_pipeline_evidence=true
    fi
fi

# Also check agent-specific verification flag
agent_id="${CLAUDE_SESSION_ID:-global}"
VERIFICATION_FLAG="/tmp/claude-verify-${agent_id}.flag"
VERIFICATION_FLAG_GLOBAL="/tmp/claude-verification-done.flag"

if [[ -f "${VERIFICATION_FLAG}" ]] || [[ -f "${VERIFICATION_FLAG_GLOBAL}" ]]; then
    has_test_evidence=true
fi

# Build missing evidence list
missing=""

if [[ "${requires_tests}" == "true" ]] && [[ "${has_test_evidence}" == "false" ]]; then
    missing="test execution (pytest/jest/etc)"
fi

if [[ "${requires_screenshot}" == "true" ]] && [[ "${has_screenshot_evidence}" == "false" ]]; then
    if [[ -n "${missing}" ]]; then missing="${missing}, "; fi
    missing="${missing}screenshot + vision analysis (playwright + gemini)"
fi

if [[ "${requires_pipeline}" == "true" ]] && [[ "${has_pipeline_evidence}" == "false" ]]; then
    if [[ -n "${missing}" ]]; then missing="${missing}, "; fi
    missing="${missing}pipeline verification (az pipelines)"
fi

if [[ -z "${missing}" ]]; then
    exit 0
fi

# Evidence missing — block completion
error_msg="BLOCKED: Task '${task_subject:-unknown}' (${task_id:-?}) cannot be marked complete. Missing: ${missing}. Provide verification evidence before completing."

mkdir -p "${TELEMETRY_DIR}"
printf '{"timestamp":"%s","hook_name":"task-completed-verify","violation_type":"unverified_completion","task_id":"%s","task_subject":"%s","teammate":"%s","missing":"%s"}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "${task_id:-unknown}" \
    "$(echo "${task_subject:-unknown}" | head -c 100 | sed 's/"/\\"/g')" \
    "${teammate_name:-unknown}" \
    "${missing}" \
    >> "${VIOLATIONS_LOG}"

echo "${error_msg}" >&2
exit 2
