#!/bin/bash
# Claude Code Quality Validation PreToolUse Hook
# Validates tool usage for security and quality patterns
# Exit code 2 blocks the action, exit code 0 allows it

TOOL_NAME="$1"
TOOL_INPUT="$2"

# Function to block with error message
block_action() {
    echo "$1" >&2
    exit 2
}

# Function to warn but allow
warn_action() {
    echo "WARNING: $1" >&2
    exit 0
}

case "$TOOL_NAME" in
    "Bash")
        # Check for dangerous patterns in bash commands
        COMMAND=$(echo "$TOOL_INPUT" | jq -r '.command // empty' 2>/dev/null)

        if [ -n "$COMMAND" ]; then
            # Block: rm -rf without explicit path or with dangerous paths
            if echo "$COMMAND" | grep -qE 'rm\s+(-rf|-fr|-r\s+-f)\s+(/|~|\$HOME|\*|\.\./)'; then
                block_action "BLOCKED: Dangerous rm command detected. Specify explicit safe paths."
            fi

            # Block: git reset --hard on main/master
            if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard.*(main|master)'; then
                block_action "BLOCKED: git reset --hard on main/master. Use explicit commit hash if needed."
            fi

            # Block: git push --force to main/master
            if echo "$COMMAND" | grep -qE 'git\s+push\s+--force.*(main|master)'; then
                block_action "BLOCKED: Force push to main/master is not allowed."
            fi

            # Block: DROP DATABASE or DROP TABLE without confirmation
            if echo "$COMMAND" | grep -qiE '(DROP\s+DATABASE|DROP\s+TABLE)'; then
                block_action "BLOCKED: DROP DATABASE/TABLE requires explicit user confirmation."
            fi

            # Block: DELETE FROM without WHERE
            if echo "$COMMAND" | grep -qiE 'DELETE\s+FROM\s+\w+\s*;'; then
                block_action "BLOCKED: DELETE FROM without WHERE clause. Add WHERE condition."
            fi

            # Warn: curl to unknown hosts (potential data exfiltration)
            if echo "$COMMAND" | grep -qE 'curl.*https?://(?!github\.com|dev\.azure\.com|anthropic\.com)'; then
                warn_action "Curl to external host detected. Verify this is intentional."
            fi

            # Block: chmod 777
            if echo "$COMMAND" | grep -qE 'chmod\s+777'; then
                block_action "BLOCKED: chmod 777 is insecure. Use more restrictive permissions."
            fi

            # Block: Accessing .env files with cat/echo (potential secret exposure)
            if echo "$COMMAND" | grep -qE '(cat|echo|less|more|head|tail).*\.env'; then
                warn_action "Reading .env file detected. Ensure no secrets are exposed in output."
            fi
        fi
        ;;

    "Write"|"Edit")
        # Check for writing to sensitive files
        FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // .path // empty' 2>/dev/null)
        NEW_CONTENT=$(echo "$TOOL_INPUT" | jq -r '.content // .new_string // empty' 2>/dev/null)

        # Warn: .format() on Python files handling user text
        if echo "$FILE_PATH" | grep -qE '\.py$'; then
            if echo "$NEW_CONTENT" | grep -qE '\.format\('; then
                if echo "$NEW_CONTENT" | grep -qiE 'transcript|translation|user_text|user_input|content|message|arabic|hebrew'; then
                    warn_action "Python .format() near user-generated text. Use str.replace() with %%DELIM%% instead — .format() crashes on braces in user text (fail-099)."
                fi
            fi
        fi

        if [ -n "$FILE_PATH" ]; then
            # Block: Writing to .env files
            if echo "$FILE_PATH" | grep -qE '\.env$|\.env\.[^/]+$'; then
                warn_action "Modifying .env file. Ensure no secrets are being committed."
            fi

            # Block: Writing to /etc or system directories
            if echo "$FILE_PATH" | grep -qE '^/etc/|^/usr/|^/bin/|^/sbin/'; then
                block_action "BLOCKED: Cannot modify system files."
            fi

            # Block: Writing to .git directory
            if echo "$FILE_PATH" | grep -qE '\.git/'; then
                block_action "BLOCKED: Cannot directly modify .git directory."
            fi
        fi
        ;;
esac

# Allow action by default
exit 0
