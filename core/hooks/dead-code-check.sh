#!/usr/bin/env bash
# Hook: dead-code-check.sh
# Event: PreToolUse (Bash tools containing "git commit")
# Purpose: Block commits that include new Python files with zero imports from other files.
# Exit 2 = BLOCK, Exit 0 = PASS
# Input: stdin JSON from Claude Code hooks API

trap 'exit 0' ERR

TELEMETRY_DIR="${CLAUDE_HOME:-$HOME/.claude}/telemetry"
VIOLATIONS_LOG="${TELEMETRY_DIR}/violations.jsonl"

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

# Read stdin JSON (Claude Code hooks API)
_STDIN=""
[[ ! -t 0 ]] && _STDIN="$(cat)" || true

tool_name="$(echo "$_STDIN" | jq -r '.tool_name // empty' 2>/dev/null)"
if [[ "${tool_name}" != "Bash" ]]; then
    exit 0
fi

command_text="$(echo "$_STDIN" | jq -r '.tool_input.command // empty' 2>/dev/null)"
if [[ -z "${command_text}" ]]; then
    exit 0
fi

# Check if command contains git commit
if ! echo "${command_text}" | grep -qi 'git commit'; then
    exit 0
fi

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    exit 0
fi

# Get list of staged new .py files
new_py_files="$(git diff --cached --name-only --diff-filter=A -- '*.py' 2>/dev/null || true)"

if [[ -z "${new_py_files}" ]]; then
    exit 0
fi

# Excluded file patterns (basenames)
is_excluded() {
    local filename
    filename="$(basename "$1")"
    case "${filename}" in
        __init__.py|conftest.py|function_app.py|app.py|main.py|manage.py|setup.py|wsgi.py|asgi.py)
            return 0
            ;;
        test_*|*_test.py)
            return 0
            ;;
    esac
    return 1
}

orphan_files=""
while IFS= read -r py_file; do
    [[ -z "${py_file}" ]] && continue

    # Skip excluded files
    if is_excluded "${py_file}"; then
        continue
    fi

    # Get module name (basename without .py)
    module_name="$(basename "${py_file}" .py)"

    # Check if any other tracked or staged .py file imports this module
    # Search patterns: "from X import", "from path.X import", "import X"
    import_count="$(git grep -l -E "(from\s+\S*${module_name}\s+import|import\s+\S*${module_name})" -- '*.py' 2>/dev/null | \
        grep -v "^${py_file}$" | \
        wc -l || echo "0")"

    if [[ "${import_count}" -eq 0 ]]; then
        # Also check staged files that aren't yet tracked
        staged_import="$(git diff --cached -U0 -- '*.py' 2>/dev/null | \
            grep -E "^\+(from\s+\S*${module_name}\s+import|import\s+\S*${module_name})" | \
            wc -l || echo "0")"

        if [[ "${staged_import}" -eq 0 ]]; then
            orphan_files="${orphan_files}\n  - ${py_file} (module: ${module_name})"
        fi
    fi
done <<< "${new_py_files}"

if [[ -n "${orphan_files}" ]]; then
    error_msg="BLOCKED: New Python files with zero imports detected (dead code). Wire them into production code before committing:${orphan_files}"

    log_violation "dead-code-check" "orphan_python_file" "$(echo -e "${error_msg}")" "${command_text}"

    echo -e "${error_msg}" >&2
    exit 2
fi

exit 0
