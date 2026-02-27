#!/bin/bash
# Claude Code Session Start Hook (Lean v2)
# Injects: git state, previous session, project status, health alerts

trap 'exit 0' ERR
OUTPUT=""
CWD=$(pwd)
PROJECT_NAME=$(basename "$CWD")
CLAUDE_DIR="$HOME/.claude"
PROJECT_CLAUDE_DIR="$CWD/.claude"

# ============================================================
# 1. GIT CONTEXT
# ============================================================
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l)
    RECENT_COMMITS=$(git log --oneline -3 2>/dev/null)
    OUTPUT+="## Session Context\n"
    OUTPUT+="**Project**: $PROJECT_NAME | **Branch**: $BRANCH | **Uncommitted**: $UNCOMMITTED files\n"
    if [ -n "$RECENT_COMMITS" ]; then
        OUTPUT+="\`\`\`\n$RECENT_COMMITS\n\`\`\`\n"
    fi
fi

# ============================================================
# 2. PREVIOUS SESSION (from session-index.json)
# ============================================================
SESSION_INDEX="$CLAUDE_DIR/session-index.json"
if [ -f "$SESSION_INDEX" ] && command -v jq &>/dev/null; then
    LAST_SESSION=$(jq -r --arg proj "$PROJECT_NAME" '
        .sessions
        | map(select(.project == $proj))
        | sort_by(.date)
        | reverse
        | .[0] // empty
    ' "$SESSION_INDEX" 2>/dev/null)

    if [ -n "$LAST_SESSION" ] && [ "$LAST_SESSION" != "null" ]; then
        LAST_ID=$(echo "$LAST_SESSION" | jq -r '.session_id // "unknown"')
        LAST_HEALTH=$(echo "$LAST_SESSION" | jq -r '.health_score // "?"')
        LAST_P0=$(echo "$LAST_SESSION" | jq -r '.p0_next // "None"')
        LAST_DATE=$(echo "$LAST_SESSION" | jq -r '.date // "unknown"' | cut -dT -f1)

        OUTPUT+="\n### Previous Session ($LAST_DATE)\n"
        OUTPUT+="**ID**: \`$LAST_ID\` | **Health**: $LAST_HEALTH/100\n"
        OUTPUT+="**P0**: $LAST_P0\n"
    fi
fi

# ============================================================
# 3. PROJECT STATUS
# ============================================================
if [[ "$CWD" == "$HOME/projects/"* ]] && [ ! -d "$PROJECT_CLAUDE_DIR" ]; then
    mkdir -p "$PROJECT_CLAUDE_DIR"
fi

if [ -f "$PROJECT_CLAUDE_DIR/status.json" ] && command -v jq &>/dev/null; then
    STATUS_SUMMARY=$(jq -r '.currentState.summary // "No summary"' "$PROJECT_CLAUDE_DIR/status.json" 2>/dev/null)
    BLOCKERS_COUNT=$(jq -r '.blockers | map(select(.status == "active")) | length // 0' "$PROJECT_CLAUDE_DIR/status.json" 2>/dev/null)
    OUTPUT+="\n### Project Status\n"
    OUTPUT+="**State**: $STATUS_SUMMARY | **Blockers**: $BLOCKERS_COUNT\n"
fi

# ============================================================
# 4. CRASH RECOVERY (detect orphaned pre-compact snapshots)
# ============================================================
MEMORY_DIR="$CLAUDE_DIR/session-memory"
if [ -d "$MEMORY_DIR" ]; then
    # Find pre-compact files newer than last session-index entry
    LATEST_PRECOMPACT=$(ls -t "$MEMORY_DIR"/pre-compact-*.md 2>/dev/null | head -1)
    if [ -n "$LATEST_PRECOMPACT" ] && [ -f "$LATEST_PRECOMPACT" ]; then
        PC_TIMESTAMP=$(stat -c %Y "$LATEST_PRECOMPACT" 2>/dev/null || echo 0)
        PC_DATE=$(date -d @"$PC_TIMESTAMP" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "unknown")
        PC_PROJECT=$(grep "Working Directory" "$LATEST_PRECOMPACT" 2>/dev/null | head -1 | sed 's/.*: //')
        PC_BRANCH=$(grep "Branch" "$LATEST_PRECOMPACT" 2>/dev/null | head -1 | sed 's/.*: //' | sed 's/\*\*//g')

        # Check if there's a session-index entry AFTER this pre-compact (clean close)
        CLEAN_CLOSE=false
        if [ -f "$SESSION_INDEX" ] && command -v jq &>/dev/null; then
            LAST_INDEX_DATE=$(jq -r '.sessions | sort_by(.date) | reverse | .[0].date // "1970-01-01"' "$SESSION_INDEX" 2>/dev/null)
            LAST_INDEX_TS=$(date -d "$LAST_INDEX_DATE" '+%s' 2>/dev/null || echo 0)
            if [ "$LAST_INDEX_TS" -gt "$PC_TIMESTAMP" ]; then
                CLEAN_CLOSE=true
            fi
        fi

        if [ "$CLEAN_CLOSE" = false ]; then
            OUTPUT+="\n### Crash Recovery Available\n"
            OUTPUT+="Found pre-compact snapshot from **$PC_DATE**\n"
            OUTPUT+="- Project: $PC_PROJECT\n"
            OUTPUT+="- Branch: $PC_BRANCH\n"
            OUTPUT+="- File: \`$LATEST_PRECOMPACT\`\n"
            OUTPUT+="Previous session may have crashed. Read the snapshot for context recovery.\n"
        fi
    fi
fi

# ============================================================
# 5. HEALTH ALERTS (only if issues found)
# ============================================================
HEALTH_ISSUES=""

TEMP_COUNT=$(find "$CWD" -maxdepth 3 -name "*.tmp" -o -name "*~" -o -name "*.bak" 2>/dev/null | wc -l)
if [ "$TEMP_COUNT" -gt 5 ]; then
    HEALTH_ISSUES+="- $TEMP_COUNT orphaned temp files\n"
fi

if [ -d "$CLAUDE_DIR/debug" ]; then
    DEBUG_MB=$(du -sm "$CLAUDE_DIR/debug" 2>/dev/null | cut -f1)
    if [ "${DEBUG_MB:-0}" -gt 100 ]; then
        HEALTH_ISSUES+="- Debug folder: ${DEBUG_MB}M (consider /clean-env)\n"
    fi
fi

if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    if [ "$(git status --porcelain 2>/dev/null | wc -l)" -gt 0 ]; then
        HEALTH_ISSUES+="- Uncommitted changes exist\n"
    fi
fi

if [ -n "$HEALTH_ISSUES" ]; then
    OUTPUT+="\n### Health Alerts\n$HEALTH_ISSUES"
fi

# ============================================================
# 6. FIRST SESSION OF DAY
# ============================================================
TODAY=$(date +%Y-%m-%d)
LAST_SESSION_FILE="$CLAUDE_DIR/.last-session-date"
LAST_SESSION_DATE=""
[ -f "$LAST_SESSION_FILE" ] && LAST_SESSION_DATE=$(cat "$LAST_SESSION_FILE")
echo "$TODAY" > "$LAST_SESSION_FILE"

if [ "$LAST_SESSION_DATE" != "$TODAY" ]; then
    OUTPUT+="\n---\nGood morning! First session of the day.\n"
fi

# ============================================================
# 7. OUTPUT
# ============================================================
echo -e "$OUTPUT"
exit 0
