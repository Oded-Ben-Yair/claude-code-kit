#!/bin/bash
#
# PreToolUse Hook: File Guard
# Protects sensitive files from being written/modified
# Exit 2 = BLOCK (stderr shown to Claude), Exit 0 = ALLOW
# Input: stdin JSON from Claude Code hooks API
#

# SAFETY: internal failures must never crash Claude Code UI.
trap 'exit 0' ERR

# Read stdin JSON (Claude Code hooks API)
_STDIN=""
[[ ! -t 0 ]] && _STDIN="$(cat)" || true

TOOL_NAME="$(echo "$_STDIN" | jq -r '.tool_name // empty' 2>/dev/null)"

# Only check Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
    exit 0
fi

# Extract file path from tool input
FILE_PATH="$(echo "$_STDIN" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)"

if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Get just the filename for pattern matching
FILENAME=$(basename "$FILE_PATH")

# =============================================================================
# BLOCKED PATTERNS - Always block these files
# =============================================================================

# Environment and secrets files
BLOCKED_PATTERNS=(
    "\.env$"
    "\.env\..*"
    "credentials\.json$"
    "secrets\.json$"
    "secrets\.yaml$"
    "secrets\.yml$"
    "\.pem$"
    "\.key$"
    "id_rsa$"
    "id_ed25519$"
    "\.ssh/.*"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
    if [[ "$FILENAME" =~ $pattern || "$FILE_PATH" =~ $pattern ]]; then
        echo "BLOCKED: Protected file pattern: $pattern" >&2
        exit 2
    fi
done

# =============================================================================
# CROSS-PROJECT PROTECTION - Prevent writes outside current project
# =============================================================================

CURRENT_DIR="${PWD}"
PROJECTS_ROOT="$HOME/projects"

# If we're in a project directory, block writes to other projects
if [[ "$CURRENT_DIR" == "$PROJECTS_ROOT/"* ]]; then
    CURRENT_PROJECT=$(echo "$CURRENT_DIR" | sed "s|$PROJECTS_ROOT/||" | cut -d'/' -f1)

    if [[ "$FILE_PATH" == "$PROJECTS_ROOT/"* ]]; then
        TARGET_PROJECT=$(echo "$FILE_PATH" | sed "s|$PROJECTS_ROOT/||" | cut -d'/' -f1)

        if [[ "$TARGET_PROJECT" != "$CURRENT_PROJECT" && -n "$TARGET_PROJECT" ]]; then
            echo "BLOCKED: Cross-project write blocked: from $CURRENT_PROJECT to $TARGET_PROJECT" >&2
            exit 2
        fi
    fi
fi

# =============================================================================
# DEFAULT: ALLOW
# =============================================================================

exit 0
