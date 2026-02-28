#!/usr/bin/env bash
#
# Periodic Commit Check Hook
# Runs after each Claude response. Commits every N exchanges if there are changes.
#
# This hook uses a counter file to track exchanges and commits periodically.
#

# SAFETY: If this hook crashes for ANY reason, pass through -- never crash the UI.
trap 'exit 0' ERR

# Configuration
COMMIT_INTERVAL=${COMMIT_INTERVAL:-15}  # Commit every N exchanges
COUNTER_FILE="/tmp/claude-commit-counter-$$"
PRIMARY_REMOTE="${CLAUDE_GIT_REMOTE:-origin}"
FALLBACK_REMOTE="origin"

# Get project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

# Check if git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    exit 0
fi

# Read current counter (use session-based counter file)
SESSION_COUNTER="/tmp/claude-commit-counter-$(basename "$PROJECT_DIR")"
COUNT=$(cat "$SESSION_COUNTER" 2>/dev/null || echo "0")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$SESSION_COUNTER"

# Only proceed if we've hit the interval
if [ $((COUNT % COMMIT_INTERVAL)) -ne 0 ]; then
    exit 0
fi

# Check for uncommitted changes
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    exit 0
fi

# Determine remote (prefer configured primary, fallback to origin)
if git remote | grep -q "^${PRIMARY_REMOTE}$"; then
    REMOTE="$PRIMARY_REMOTE"
elif git remote | grep -q "^${FALLBACK_REMOTE}$"; then
    REMOTE="$FALLBACK_REMOTE"
else
    exit 0
fi

# Get branch
BRANCH=$(git branch --show-current 2>/dev/null)
if [ -z "$BRANCH" ]; then
    exit 0
fi

# Stage changes safely (exclude secrets and sensitive files)
git add --all -- \
    ':!.env' ':!.env.*' ':!*.key' ':!*.pem' ':!.secrets' ':!credentials*' \
    ':!*.secret' ':!*secret*.json' ':!*secret*.yaml' ':!*secret*.yml'

# Check if there's anything staged
if git diff --cached --quiet; then
    exit 0
fi

# Generate commit message
TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
FILE_COUNT=$(git diff --cached --name-only | wc -l)

COMMIT_MSG="chore: periodic save [$TIMESTAMP] - $FILE_COUNT files

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Code <noreply@anthropic.com>"

# Commit and push
git commit -m "$COMMIT_MSG" >/dev/null 2>&1
git push "$REMOTE" "$BRANCH" >/dev/null 2>&1

echo "Auto-saved $FILE_COUNT files to $REMOTE"
exit 0
