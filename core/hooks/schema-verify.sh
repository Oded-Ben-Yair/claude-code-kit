#!/usr/bin/env bash
# Hook: schema-verify.sh
# Event: PreToolUse (Bash tools with SQL-like commands)
# Purpose: Warn when SQL queries reference tables without prior schema verification.
# Exit 2 = BLOCK, Exit 0 = PASS
# Input: stdin JSON from Claude Code hooks API

trap 'exit 0' ERR

TELEMETRY_DIR="${CLAUDE_HOME:-$HOME/.claude}/telemetry"
VIOLATIONS_LOG="${TELEMETRY_DIR}/violations.jsonl"
VERIFIED_TABLES_FILE="/tmp/claude-schema-verified-tables.txt"

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

command_upper="$(echo "${command_text}" | tr '[:lower:]' '[:upper:]')"

# Check if this is a schema verification query itself
if echo "${command_text}" | grep -qPi 'information_schema\.(columns|tables)|\\d\s+\w|\\dt|pg_catalog|SHOW\s+COLUMNS|DESCRIBE\s+'; then
    # Extract table name being verified and record it
    tables_being_verified="$(echo "${command_text}" | grep -oPi "table_name\s*=\s*'([^']+)'" | grep -oPi "'[^']+'" | tr -d "'" || true)"
    if [[ -z "${tables_being_verified}" ]]; then
        # Try \d tablename pattern
        tables_being_verified="$(echo "${command_text}" | grep -oPi '\\d\s+(\w+)' | awk '{print $2}' || true)"
    fi
    if [[ -n "${tables_being_verified}" ]]; then
        touch "${VERIFIED_TABLES_FILE}"
        echo "${tables_being_verified}" >> "${VERIFIED_TABLES_FILE}"
    fi
    exit 0
fi

# Check if command contains SQL keywords
if ! echo "${command_upper}" | grep -qP '\b(SELECT|INSERT|UPDATE|DELETE|ALTER|CREATE\s+TABLE)\b'; then
    exit 0
fi

# Extract table names from SQL
# Patterns: FROM table, JOIN table, INTO table, UPDATE table, TABLE table, DELETE FROM table
tables_referenced="$(echo "${command_text}" | grep -oPi '\b(?:FROM|JOIN|INTO|UPDATE|TABLE|DELETE\s+FROM)\s+([a-zA-Z_][a-zA-Z0-9_.]*)\b' | \
    grep -oPi '[a-zA-Z_][a-zA-Z0-9_.]*$' | \
    sort -u || true)"

if [[ -z "${tables_referenced}" ]]; then
    exit 0
fi

# Load verified tables
verified_tables=""
if [[ -f "${VERIFIED_TABLES_FILE}" ]]; then
    verified_tables="$(cat "${VERIFIED_TABLES_FILE}")"
fi

# Check each referenced table
unverified_tables=""
while IFS= read -r table; do
    [[ -z "${table}" ]] && continue
    # Skip common non-table keywords that might be false positives
    case "${table}" in
        set|as|where|and|or|not|null|true|false|select|from|join|into|values|default|index|key|primary|constraint)
            continue
            ;;
    esac
    if ! echo "${verified_tables}" | grep -qxi "${table}"; then
        unverified_tables="${unverified_tables} ${table}"
    fi
done <<< "${tables_referenced}"

unverified_tables="$(echo "${unverified_tables}" | xargs)"

if [[ -n "${unverified_tables}" ]]; then
    # Build help message with first unverified table
    first_table="$(echo "${unverified_tables}" | awk '{print $1}')"
    error_msg="BLOCKED: Query references unverified table(s): ${unverified_tables}. Run schema verification first: SELECT column_name, data_type FROM information_schema.columns WHERE table_name='${first_table}'"

    log_violation "schema-verify" "unverified_table" "${error_msg}" "${command_text}"

    echo "${error_msg}" >&2
    exit 2
fi

exit 0
