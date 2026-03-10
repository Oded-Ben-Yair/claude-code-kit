#!/usr/bin/env bash
# Hook: deploy-gate.sh (v2.0 — stdin JSON)
# Event: PreToolUse (Bash)
# Purpose: Prevent running verification queries before deployment pipeline completes.
# Exit 2 = BLOCK, Exit 0 = PASS

trap 'exit 0' ERR

TELEMETRY_DIR="/home/odedbe/.claude/telemetry"
VIOLATIONS_LOG="${TELEMETRY_DIR}/violations.jsonl"
PUSH_FLAG="/tmp/claude-last-push.flag"
PIPELINE_COOLDOWN_SECONDS=300  # 5 minutes

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

# Read JSON from stdin
stdin_data=""
if [[ ! -t 0 ]]; then
    stdin_data="$(cat)"
fi

# Extract tool_name and command from stdin JSON
tool_name=""
command_text=""
if [[ -n "${stdin_data}" ]]; then
    eval "$(echo "${stdin_data}" | python3 -c '
import json, sys, shlex
try:
    d = json.load(sys.stdin)
    tool = d.get("tool_name", "")
    cmd = d.get("tool_input", {}).get("command", "")
    print(f"tool_name={shlex.quote(tool)}")
    print(f"command_text={shlex.quote(cmd)}")
except Exception:
    print("tool_name=")
    print("command_text=")
' 2>/dev/null)" || exit 0
fi

# Only process Bash tool calls
if [[ "${tool_name}" != "Bash" ]]; then
    exit 0
fi

if [[ -z "${command_text}" ]]; then
    exit 0
fi

# PHASE 1: Detect git push and record timestamp
if echo "${command_text}" | grep -qPi 'git\s+push\b'; then
    date +%s > "${PUSH_FLAG}"
    exit 0
fi

# PHASE 2: Check if this is a verification command after a recent push
is_verification=false

# curl to production URLs
if echo "${command_text}" | grep -qPi 'curl\s+.*https://(icy-coast|yellow-hill|.*azurestaticapps\.net|.*azurewebsites\.net)'; then
    is_verification=true
fi

# az webapp show/list commands
if echo "${command_text}" | grep -qPi 'az\s+(webapp\s+show|webapp\s+list|functionapp\s+show|staticwebapp\s+show)'; then
    is_verification=true
fi

# Database queries that look like post-deploy verification
if echo "${command_text}" | grep -qPi '(psql|pg_isready|SELECT.*FROM).*'; then
    if echo "${command_text}" | grep -qPi '(deploy|version|migration|health|status)'; then
        is_verification=true
    fi
fi

# az pipelines check is explicitly ALLOWED
if echo "${command_text}" | grep -qPi 'az\s+pipelines\s+(runs|show|list)'; then
    is_verification=false
fi

if [[ "${is_verification}" == "false" ]]; then
    exit 0
fi

# Check if a recent push happened
if [[ ! -f "${PUSH_FLAG}" ]]; then
    exit 0
fi

push_timestamp="$(cat "${PUSH_FLAG}" 2>/dev/null || echo "0")"
now="$(date +%s)"
elapsed=$(( now - push_timestamp ))

if [[ "${elapsed}" -lt "${PIPELINE_COOLDOWN_SECONDS}" ]]; then
    remaining=$(( PIPELINE_COOLDOWN_SECONDS - elapsed ))
    error_msg="BLOCKED: git push detected ${elapsed}s ago (cooldown: ${PIPELINE_COOLDOWN_SECONDS}s, ${remaining}s remaining). Pipeline may still be running. Check pipeline status first: az pipelines runs list --org https://dev.azure.com/Corp-domain --project Corp-AI --top 1 -o table"

    log_violation "deploy-gate" "premature_verification" "${error_msg}" "${command_text}"

    echo '{"error":"premature_verification","elapsed_seconds":'"${elapsed}"',"cooldown_seconds":'"${PIPELINE_COOLDOWN_SECONDS}"',"message":"'"${error_msg}"'"}' >&2
    exit 2
fi

# Cooldown passed, allow verification and clean up flag
rm -f "${PUSH_FLAG}"
exit 0
