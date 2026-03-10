#!/bin/bash
# Post-Compact Context Recovery Hook
# Runs on SessionStart with "compact" matcher
# Re-injects critical state after context compaction

trap 'exit 0' ERR
OUTPUT=""
CWD=$(pwd)
CLAUDE_DIR="$HOME/.claude"
MEMORY_DIR="$CLAUDE_DIR/session-memory"

# 1. Find and inject latest pre-compact snapshot
if [ -d "$MEMORY_DIR" ]; then
    LATEST=$(ls -t "$MEMORY_DIR"/pre-compact-*.md 2>/dev/null | head -1)
    if [ -n "$LATEST" ] && [ -f "$LATEST" ]; then
        PC_DATE=$(date -d @"$(stat -c %Y "$LATEST" 2>/dev/null || echo 0)" '+%H:%M:%S' 2>/dev/null || echo "unknown")
        OUTPUT+="## Post-Compact Recovery (snapshot from $PC_DATE)\n"

        # Extract key sections from pre-compact snapshot
        GIT_STATE=$(sed -n '/## Git State/,/^##/p' "$LATEST" 2>/dev/null | head -10)
        if [ -n "$GIT_STATE" ]; then
            OUTPUT+="$GIT_STATE\n"
        fi

        PLAN=$(sed -n '/## Active Plan/,/^##/p' "$LATEST" 2>/dev/null | head -15)
        if [ -n "$PLAN" ]; then
            OUTPUT+="$PLAN\n"
        fi

        TODOS=$(sed -n '/## Active Todos/,/^##/p' "$LATEST" 2>/dev/null | head -20)
        if [ -n "$TODOS" ]; then
            OUTPUT+="$TODOS\n"
        fi

        PROJECT_STATUS=$(sed -n '/## Project Status/,/^---/p' "$LATEST" 2>/dev/null | head -10)
        if [ -n "$PROJECT_STATUS" ]; then
            OUTPUT+="$PROJECT_STATUS\n"
        fi
    fi
fi

# 2. Inject current project status if available
PROJECT_STATUS_FILE="$CWD/.claude/status.json"
if [ -f "$PROJECT_STATUS_FILE" ] && command -v jq &>/dev/null; then
    SUMMARY=$(jq -r '.currentState.summary // empty' "$PROJECT_STATUS_FILE" 2>/dev/null)
    NEXT=$(jq -r '.nextSteps[0].description // empty' "$PROJECT_STATUS_FILE" 2>/dev/null)
    if [ -n "$SUMMARY" ]; then
        OUTPUT+="\n### Current Project\n"
        OUTPUT+="**State**: $SUMMARY\n"
        [ -n "$NEXT" ] && OUTPUT+="**Next**: $NEXT\n"
    fi
fi

# 3. Reminder about on-demand docs
OUTPUT+="\n---\n"
OUTPUT+="Context was compacted. Pre-compact snapshot saved at: $LATEST\n"
OUTPUT+="Read it with Read tool if you need detailed recovery.\n"

echo -e "$OUTPUT"
exit 0
