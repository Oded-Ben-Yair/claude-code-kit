#!/usr/bin/env bash
# Claude Code Pre-Compact Memory Save Hook
# Saves critical state before context compaction occurs
# This helps preserve important decisions and context

MEMORY_DIR="$HOME/.claude/session-memory"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
SESSION_ID="${CLAUDE_SESSION_ID:-$$}"
MEMORY_FILE="$MEMORY_DIR/pre-compact-$TIMESTAMP.md"

# Create memory directory if it doesn't exist
mkdir -p "$MEMORY_DIR"

# Dedup: skip if another pre-compact file was written in the last 30 seconds
LATEST_EXISTING=$(ls -t "$MEMORY_DIR"/pre-compact-*.md 2>/dev/null | head -1)
if [ -n "$LATEST_EXISTING" ]; then
    EXISTING_AGE=$(( $(date +%s) - $(stat -c %Y "$LATEST_EXISTING" 2>/dev/null || echo 0) ))
    if [ "$EXISTING_AGE" -lt 30 ]; then
        echo "Pre-compact: skipping duplicate (last snapshot ${EXISTING_AGE}s ago)" >&2
        exit 0
    fi
fi

# Collect information to save
{
    echo "# Pre-Compaction Memory Snapshot"
    echo "**Timestamp**: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "**Session ID**: $SESSION_ID"
    echo "**Working Directory**: $(pwd)"
    echo ""

    # Git state if in a repo
    if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
        echo "## Git State"
        echo "- **Branch**: $(git branch --show-current 2>/dev/null)"
        echo "- **Last Commit**: $(git log --oneline -1 2>/dev/null)"
        echo ""

        # Staged changes
        STAGED=$(git diff --cached --name-only 2>/dev/null)
        if [ -n "$STAGED" ]; then
            echo "### Staged Changes:"
            echo "\`\`\`"
            echo "$STAGED"
            echo "\`\`\`"
            echo ""
        fi

        # Modified files
        MODIFIED=$(git diff --name-only 2>/dev/null)
        if [ -n "$MODIFIED" ]; then
            echo "### Modified Files:"
            echo "\`\`\`"
            echo "$MODIFIED"
            echo "\`\`\`"
            echo ""
        fi
    fi

    # Check for any plan files
    if [ -d "$HOME/.claude/plans" ]; then
        RECENT_PLAN=$(ls -t "$HOME/.claude/plans"/*.md 2>/dev/null | head -1)
        if [ -n "$RECENT_PLAN" ] && [ -f "$RECENT_PLAN" ]; then
            echo "## Active Plan"
            echo "**File**: $RECENT_PLAN"
            echo ""
            echo "### Plan Summary (first 50 lines):"
            echo "\`\`\`markdown"
            head -50 "$RECENT_PLAN"
            echo "\`\`\`"
            echo ""
        fi
    fi

    # Todo list state
    if [ -f "$HOME/.claude/todos.json" ]; then
        echo "## Active Todos"
        echo "\`\`\`json"
        cat "$HOME/.claude/todos.json" 2>/dev/null
        echo "\`\`\`"
        echo ""
    fi

    # Project status summary if available
    PROJECT_STATUS="$(pwd)/.claude/status.json"
    if [ -f "$PROJECT_STATUS" ] && command -v jq &>/dev/null; then
        echo "## Project Status"
        SUMMARY=$(jq -r '.currentState.summary // "No summary"' "$PROJECT_STATUS" 2>/dev/null)
        NEXT_STEPS=$(jq -r '.nextSteps[]?.description // empty' "$PROJECT_STATUS" 2>/dev/null | head -3)
        echo "- **Summary**: $SUMMARY"
        if [ -n "$NEXT_STEPS" ]; then
            echo "- **Next Steps**:"
            echo "$NEXT_STEPS" | while read -r step; do echo "  - $step"; done
        fi
        echo ""
    fi

    echo "---"
    echo "*Pre-compact snapshot created $(date '+%Y-%m-%d %H:%M:%S'). Session: $SESSION_ID*"
    echo "*Read this file if the previous session crashed without /end-of-session.*"

} > "$MEMORY_FILE"

# Clean up old memory files (keep last 10)
ls -t "$MEMORY_DIR"/pre-compact-*.md 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null

# Log that we saved
echo "Pre-compact memory saved to: $MEMORY_FILE" >&2

exit 0
