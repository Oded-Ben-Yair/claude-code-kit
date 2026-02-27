#!/bin/bash
#
# PreToolUse Hook: File Guard
# Protects sensitive files from being written/modified
#
# Returns JSON response:
#   {"decision": "allow", "reason": "..."}
#   {"decision": "block", "reason": "..."}
#
# Hook receives tool context via environment variables:
#   CLAUDE_TOOL_NAME - Name of tool being invoked
#   CLAUDE_TOOL_INPUT - JSON input to the tool
#

# SAFETY: internal failures must never crash Claude Code UI.
trap 'exit 0' ERR

# Extract tool info from hook context
TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Only check Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
    echo '{"decision": "allow", "reason": "Tool not a file writer"}'
    exit 0
fi

# Extract file path from tool input
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // .path // ""' 2>/dev/null || echo "")

if [[ -z "$FILE_PATH" ]]; then
    echo '{"decision": "allow", "reason": "No file path detected"}'
    exit 0
fi

# Get just the filename for pattern matching
FILENAME=$(basename "$FILE_PATH")
DIRNAME=$(dirname "$FILE_PATH")

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
# PRODUCTION FILE PROTECTION - Require confirmation for production configs
# =============================================================================

PRODUCTION_INDICATORS=(
    "prod"
    "production"
    "live"
)

# Check if path contains production indicators
for indicator in "${PRODUCTION_INDICATORS[@]}"; do
    if [[ "$FILE_PATH" == *"$indicator"* ]]; then
        # For now, allow but log warning
        echo "{\"decision\": \"allow\", \"reason\": \"Production file - proceed with caution: $FILE_PATH\"}"
        exit 0
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

echo '{"decision": "allow", "reason": "File write permitted"}'
exit 0
