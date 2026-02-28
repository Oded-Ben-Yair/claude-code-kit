#!/usr/bin/env bash
# Hook: test-result-tracker.sh
# Event: PostToolUse (Bash)
# Purpose: Track test runner results. Creates flags for debug-first.sh and stop-verify.sh.
#
# Data arrives via STDIN as JSON with fields:
#   tool_name, tool_input.command, tool_response.stdout, tool_response.stderr
#
# When a test command exits with success: creates /tmp/claude-verification-done.flag
# When a test command exits with failure: creates /tmp/claude-test-failure.flag

trap 'exit 0' ERR

TELEMETRY_DIR="${CLAUDE_HOME:-$HOME/.claude}/telemetry"

# Read JSON from stdin
STDIN_DATA=""
if [[ ! -t 0 ]]; then
    STDIN_DATA="$(cat)"
fi

# No input = nothing to do
if [[ -z "${STDIN_DATA}" ]]; then
    exit 0
fi

# Extract fields using python3 (jq may not be available, python3 always is)
eval "$(echo "${STDIN_DATA}" | python3 -c '
import json, sys, shlex
try:
    d = json.load(sys.stdin)
    tool = d.get("tool_name", "")
    cmd = d.get("tool_input", {}).get("command", "")
    stdout = d.get("tool_response", {}).get("stdout", "")
    stderr = d.get("tool_response", {}).get("stderr", "")
    sid = d.get("session_id", "global")
    # Shell-safe output
    print(f"tool_name={shlex.quote(tool)}")
    print(f"command_text={shlex.quote(cmd)}")
    print(f"output_text={shlex.quote(stdout[:2000])}")
    print(f"stderr_text={shlex.quote(stderr[:500])}")
    print(f"session_id={shlex.quote(sid)}")
except Exception:
    print("tool_name=unknown")
    print("command_text=")
    print("output_text=")
    print("stderr_text=")
    print("session_id=global")
' 2>/dev/null)" || exit 0

# Only process Bash tool calls
if [[ "${tool_name}" != "Bash" ]]; then
    exit 0
fi

if [[ -z "${command_text}" ]]; then
    exit 0
fi

# Agent-ID prefixed flags for multi-agent isolation
agent_id="${session_id:-global}"
TEST_FAILURE_FLAG="/tmp/claude-testfail-${agent_id}.flag"
VERIFICATION_FLAG="/tmp/claude-verify-${agent_id}.flag"
DEBUG_TRACE_FLAG="/tmp/claude-debug-${agent_id}.flag"

# Backward compat: also write global flags
TEST_FAILURE_FLAG_GLOBAL="/tmp/claude-test-failure.flag"
VERIFICATION_FLAG_GLOBAL="/tmp/claude-verification-done.flag"
DEBUG_TRACE_FLAG_GLOBAL="/tmp/claude-debug-trace.flag"

# Check if this is a debug-related command (creates debug trace flag for debug-first.sh)
if echo "${command_text}" | grep -qPi '(print|log|breakpoint|pdb|console\.log|debug|logging\.|logger\.)'; then
    date +%s > "${DEBUG_TRACE_FLAG}"
    date +%s > "${DEBUG_TRACE_FLAG_GLOBAL}"
fi

# Check if this is a test runner command
is_test_command=false
if echo "${command_text}" | grep -qPi '(pytest|jest|npm\s+test|npm\s+run\s+test|cargo\s+test|go\s+test|python\s+-m\s+unittest|dotnet\s+test|mvn\s+test|rspec|phpunit|vitest|mocha)'; then
    is_test_command=true
fi

if [[ "${is_test_command}" == "false" ]]; then
    exit 0
fi

# Determine test result from output patterns
test_passed=false

# Check output for explicit pass/fail patterns
if [[ -n "${output_text}" ]]; then
    output_lower="$(echo "${output_text}" | tr '[:upper:]' '[:lower:]')"
    if echo "${output_lower}" | grep -qP '(\d+ passed|tests passed|test suites.*passed|all tests passed|ok \(|passed.*warning)'; then
        test_passed=true
    fi
    # Override to fail if actual non-zero failures exist (not "0 failed")
    if echo "${output_lower}" | grep -qP '[1-9]\d*\s+(failed|error|failure)'; then
        test_passed=false
    fi
fi

# Also check stderr for error indicators
if [[ -n "${stderr_text}" ]]; then
    stderr_lower="$(echo "${stderr_text}" | tr '[:upper:]' '[:lower:]')"
    if echo "${stderr_lower}" | grep -qP '[1-9]\d*\s+(failed|error)'; then
        test_passed=false
    fi
fi

if [[ "${test_passed}" == "true" ]]; then
    # Tests passed: set verification flag, clear failure flag (agent + global)
    date +%s > "${VERIFICATION_FLAG}"
    date +%s > "${VERIFICATION_FLAG_GLOBAL}"
    rm -f "${TEST_FAILURE_FLAG}" "${TEST_FAILURE_FLAG_GLOBAL}"

    mkdir -p "${TELEMETRY_DIR}"
    printf '{"timestamp":"%s","event":"test_pass","agent_id":"%s","command":"%s"}\n' \
        "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        "${agent_id}" \
        "$(echo "${command_text}" | head -c 100 | sed 's/"/\\"/g')" \
        >> "${TELEMETRY_DIR}/test-results.jsonl"
else
    # Tests failed or inconclusive: set failure flag, clear verification (agent + global)
    date +%s > "${TEST_FAILURE_FLAG}"
    date +%s > "${TEST_FAILURE_FLAG_GLOBAL}"
    rm -f "${VERIFICATION_FLAG}" "${VERIFICATION_FLAG_GLOBAL}"

    mkdir -p "${TELEMETRY_DIR}"
    printf '{"timestamp":"%s","event":"test_fail","agent_id":"%s","command":"%s"}\n' \
        "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        "${agent_id}" \
        "$(echo "${command_text}" | head -c 100 | sed 's/"/\\"/g')" \
        >> "${TELEMETRY_DIR}/test-results.jsonl"
fi

exit 0
