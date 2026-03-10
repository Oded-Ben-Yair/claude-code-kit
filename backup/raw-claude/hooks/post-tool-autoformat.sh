#!/bin/bash
#
# PostToolUse Hook: Auto-Format
# Automatically formats code after Claude writes/edits files
# Exit 0 = success, Exit 2 = block (feedback to Claude)
# Input: stdin JSON from Claude Code hooks API
#

# SAFETY: internal failures must never crash Claude Code UI.
trap 'exit 0' ERR

# Read stdin JSON (Claude Code hooks API)
_STDIN=""
[[ ! -t 0 ]] && _STDIN="$(cat)" || true

TOOL_NAME="$(echo "$_STDIN" | jq -r '.tool_name // empty' 2>/dev/null)"

# Only process Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
    exit 0
fi

# Extract file path
FILE_PATH="$(echo "$_STDIN" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)"

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"
FORMATTED=false
FORMAT_TOOL=""

# =============================================================================
# PYTHON FILES - Format with black or ruff
# =============================================================================

if [[ "$EXT" == "py" ]]; then
    if command -v ruff &>/dev/null; then
        if ruff format "$FILE_PATH" --quiet 2>/dev/null; then
            FORMATTED=true
            FORMAT_TOOL="ruff"
        fi
    elif command -v black &>/dev/null; then
        if black "$FILE_PATH" --quiet 2>/dev/null; then
            FORMATTED=true
            FORMAT_TOOL="black"
        fi
    fi
fi

# =============================================================================
# TYPESCRIPT/JAVASCRIPT FILES - Format with prettier
# =============================================================================

if [[ "$EXT" == "ts" || "$EXT" == "tsx" || "$EXT" == "js" || "$EXT" == "jsx" ]]; then
    if command -v prettier &>/dev/null; then
        if prettier --write "$FILE_PATH" --log-level silent 2>/dev/null; then
            FORMATTED=true
            FORMAT_TOOL="prettier"
        fi
    fi
fi

# =============================================================================
# JSON FILES - Format with jq or prettier
# =============================================================================

if [[ "$EXT" == "json" ]]; then
    if command -v jq &>/dev/null; then
        TEMP_FILE=$(mktemp)
        if jq '.' "$FILE_PATH" > "$TEMP_FILE" 2>/dev/null; then
            mv "$TEMP_FILE" "$FILE_PATH"
            FORMATTED=true
            FORMAT_TOOL="jq"
        else
            rm -f "$TEMP_FILE"
        fi
    elif command -v prettier &>/dev/null; then
        if prettier --write "$FILE_PATH" --log-level silent 2>/dev/null; then
            FORMATTED=true
            FORMAT_TOOL="prettier"
        fi
    fi
fi

# =============================================================================
# YAML FILES - Validate syntax
# =============================================================================

if [[ "$EXT" == "yaml" || "$EXT" == "yml" ]]; then
    if command -v python3 &>/dev/null; then
        if ! python3 -c "import yaml; yaml.safe_load(open('$FILE_PATH'))" 2>/dev/null; then
            echo "YAML syntax warning - file may have issues" >&2
        fi
    fi
fi

# =============================================================================
# MARKDOWN FILES - No auto-formatting (preserve intentional formatting)
# =============================================================================

if [[ "$EXT" == "md" ]]; then
    exit 0
fi

# =============================================================================
# POST-FORMAT SYNTAX VALIDATION
# Verify formatted code still compiles/parses (catch broken syntax from formatter)
# =============================================================================

SYNTAX_OK=true
SYNTAX_ERROR=""

if [[ "$EXT" == "py" ]] && command -v python3 &>/dev/null; then
    if ! python3 -c "import ast; ast.parse(open('$FILE_PATH').read())" 2>/tmp/syntax_check_err; then
        SYNTAX_OK=false
        SYNTAX_ERROR=$(head -1 /tmp/syntax_check_err 2>/dev/null || echo "Python syntax error")
    fi
    rm -f /tmp/syntax_check_err
fi

if [[ "$EXT" == "ts" || "$EXT" == "tsx" ]] && command -v npx &>/dev/null; then
    # Quick syntax check via tsc --noEmit if tsconfig exists
    FILE_DIR=$(dirname "$FILE_PATH")
    if [[ -f "$FILE_DIR/tsconfig.json" || -f "$FILE_DIR/../tsconfig.json" ]]; then
        if ! npx tsc --noEmit "$FILE_PATH" 2>/tmp/syntax_check_err; then
            # Only warn, don't block — tsc errors can be type errors not syntax
            SYNTAX_ERROR=$(head -1 /tmp/syntax_check_err 2>/dev/null || echo "TypeScript check warning")
        fi
        rm -f /tmp/syntax_check_err
    fi
fi

if [[ "$EXT" == "js" || "$EXT" == "jsx" ]] && command -v node &>/dev/null; then
    if ! node --check "$FILE_PATH" 2>/tmp/syntax_check_err; then
        SYNTAX_OK=false
        SYNTAX_ERROR=$(head -1 /tmp/syntax_check_err 2>/dev/null || echo "JavaScript syntax error")
    fi
    rm -f /tmp/syntax_check_err
fi

# =============================================================================
# RESPONSE
# =============================================================================

if [[ "$SYNTAX_OK" == false ]]; then
    echo "WARNING: Syntax error after formatting with $FORMAT_TOOL: $SYNTAX_ERROR" >&2
fi

exit 0
