#!/bin/bash
# Janitor Protocol - Cleanup Audit Script
# Part of Silent Kernel Architecture v7.0
#
# Audits ~/.claude/ and project folders for cleanup opportunities
# NEVER deletes automatically - always reports for manual action

set -e

CLAUDE_DIR="$HOME/.claude"
PROJECTS_DIR="$HOME/projects"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
REPORT_FILE="$CLAUDE_DIR/cleanup-report-$(date '+%Y%m%d').md"

echo "# Janitor Audit Report" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**Generated**: $TIMESTAMP" >> "$REPORT_FILE"
echo "**Status**: REPORT ONLY - No automatic deletion" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# ============================================================
# 1. TEMPORARY FILES
# ============================================================
echo "## 1. Temporary Files" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Find temp files in projects
TEMP_FILES=$(find "$PROJECTS_DIR" -type f \( -name "*.tmp" -o -name "*~" -o -name "*.bak" -o -name "*.swp" -o -name ".DS_Store" \) 2>/dev/null | head -50)
TEMP_COUNT=$(echo "$TEMP_FILES" | grep -c . || echo 0)

if [ "$TEMP_COUNT" -gt 0 ]; then
    echo "Found **$TEMP_COUNT** temporary files:" >> "$REPORT_FILE"
    echo "\`\`\`" >> "$REPORT_FILE"
    echo "$TEMP_FILES" | head -20 >> "$REPORT_FILE"
    if [ "$TEMP_COUNT" -gt 20 ]; then
        echo "... and $((TEMP_COUNT - 20)) more" >> "$REPORT_FILE"
    fi
    echo "\`\`\`" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "**Cleanup command** (review first):" >> "$REPORT_FILE"
    echo "\`\`\`bash" >> "$REPORT_FILE"
    echo "find $PROJECTS_DIR -type f \\( -name \"*.tmp\" -o -name \"*~\" -o -name \"*.bak\" \\) -delete" >> "$REPORT_FILE"
    echo "\`\`\`" >> "$REPORT_FILE"
else
    echo "No temporary files found." >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# ============================================================
# 2. LARGE DIRECTORIES
# ============================================================
echo "## 2. Large Directories" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "### ~/.claude/ subdirectories:" >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
du -sh "$CLAUDE_DIR"/* 2>/dev/null | sort -rh | head -10 >> "$REPORT_FILE"
echo "\`\`\`" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Check debug folder specifically
if [ -d "$CLAUDE_DIR/debug" ]; then
    DEBUG_SIZE=$(du -sh "$CLAUDE_DIR/debug" 2>/dev/null | cut -f1)
    DEBUG_MB=$(du -sm "$CLAUDE_DIR/debug" 2>/dev/null | cut -f1)
    if [ "$DEBUG_MB" -gt 100 ]; then
        echo "**Warning**: Debug folder is $DEBUG_SIZE (consider cleanup)" >> "$REPORT_FILE"
        echo "\`\`\`bash" >> "$REPORT_FILE"
        echo "# Review and clean debug folder:" >> "$REPORT_FILE"
        echo "ls -la $CLAUDE_DIR/debug/ | head -20" >> "$REPORT_FILE"
        echo "# rm -rf $CLAUDE_DIR/debug/*  # CAREFUL!" >> "$REPORT_FILE"
        echo "\`\`\`" >> "$REPORT_FILE"
    fi
fi

# Check session-env folder
if [ -d "$CLAUDE_DIR/session-env" ]; then
    SESSION_COUNT=$(ls -1 "$CLAUDE_DIR/session-env" 2>/dev/null | wc -l)
    if [ "$SESSION_COUNT" -gt 100 ]; then
        echo "**Warning**: $SESSION_COUNT session environments (consider pruning old ones)" >> "$REPORT_FILE"
    fi
fi
echo "" >> "$REPORT_FILE"

# ============================================================
# 3. NODE_MODULES IN PROJECTS
# ============================================================
echo "## 3. Node Modules" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

NODE_MODULES=$(find "$PROJECTS_DIR" -type d -name "node_modules" -prune 2>/dev/null)
NODE_COUNT=$(echo "$NODE_MODULES" | grep -c . || echo 0)

if [ "$NODE_COUNT" -gt 0 ]; then
    echo "Found **$NODE_COUNT** node_modules directories:" >> "$REPORT_FILE"
    echo "\`\`\`" >> "$REPORT_FILE"
    for nm in $NODE_MODULES; do
        SIZE=$(du -sh "$nm" 2>/dev/null | cut -f1)
        echo "$SIZE  $nm" >> "$REPORT_FILE"
    done
    echo "\`\`\`" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "**Tip**: Remove unused project node_modules to save space" >> "$REPORT_FILE"
else
    echo "No node_modules directories found." >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# ============================================================
# 4. PYTHON VIRTUAL ENVIRONMENTS
# ============================================================
echo "## 4. Python Virtual Environments" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

VENVS=$(find "$PROJECTS_DIR" -type d \( -name ".venv" -o -name "venv" -o -name ".env" \) -prune 2>/dev/null | head -20)
VENV_COUNT=$(echo "$VENVS" | grep -c . || echo 0)

if [ "$VENV_COUNT" -gt 0 ]; then
    echo "Found **$VENV_COUNT** virtual environments:" >> "$REPORT_FILE"
    echo "\`\`\`" >> "$REPORT_FILE"
    for venv in $VENVS; do
        SIZE=$(du -sh "$venv" 2>/dev/null | cut -f1)
        echo "$SIZE  $venv" >> "$REPORT_FILE"
    done
    echo "\`\`\`" >> "$REPORT_FILE"
else
    echo "No virtual environments found." >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# ============================================================
# 5. OLD LOG FILES
# ============================================================
echo "## 5. Log Files" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

LOG_FILES=$(find "$CLAUDE_DIR" "$PROJECTS_DIR" -type f \( -name "*.log" -o -name "*.log.*" \) -mtime +7 2>/dev/null | head -20)
LOG_COUNT=$(echo "$LOG_FILES" | grep -c . || echo 0)

if [ "$LOG_COUNT" -gt 0 ]; then
    echo "Found **$LOG_COUNT** log files older than 7 days:" >> "$REPORT_FILE"
    echo "\`\`\`" >> "$REPORT_FILE"
    echo "$LOG_FILES" >> "$REPORT_FILE"
    echo "\`\`\`" >> "$REPORT_FILE"
else
    echo "No old log files found." >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# ============================================================
# 6. DUPLICATE/BACKUP FILES
# ============================================================
echo "## 6. Potential Duplicates" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

BACKUP_FILES=$(find "$PROJECTS_DIR" -type f \( -name "*.backup" -o -name "*.old" -o -name "*-backup.*" -o -name "*-old.*" -o -name "*.orig" \) 2>/dev/null | head -20)
BACKUP_COUNT=$(echo "$BACKUP_FILES" | grep -c . || echo 0)

if [ "$BACKUP_COUNT" -gt 0 ]; then
    echo "Found **$BACKUP_COUNT** backup/old files:" >> "$REPORT_FILE"
    echo "\`\`\`" >> "$REPORT_FILE"
    echo "$BACKUP_FILES" >> "$REPORT_FILE"
    echo "\`\`\`" >> "$REPORT_FILE"
else
    echo "No obvious backup files found." >> "$REPORT_FILE"
fi
echo "" >> "$REPORT_FILE"

# ============================================================
# 7. UNCOMMITTED CHANGES
# ============================================================
echo "## 7. Uncommitted Git Changes" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

for project in "$PROJECTS_DIR"/*/; do
    if [ -d "$project/.git" ]; then
        PROJECT_NAME=$(basename "$project")
        UNCOMMITTED=$(cd "$project" && git status --porcelain 2>/dev/null | wc -l)
        if [ "$UNCOMMITTED" -gt 0 ]; then
            echo "**$PROJECT_NAME**: $UNCOMMITTED uncommitted files" >> "$REPORT_FILE"
        fi
    fi
done
echo "" >> "$REPORT_FILE"

# ============================================================
# 8. ORPHANED CLAUDE DIRECTORIES
# ============================================================
echo "## 8. Project Status" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "Projects with .claude/ directory:" >> "$REPORT_FILE"
for project in "$PROJECTS_DIR"/*/; do
    PROJECT_NAME=$(basename "$project")
    if [ -d "$project/.claude" ]; then
        echo "- [x] $PROJECT_NAME (has .claude/)" >> "$REPORT_FILE"
    else
        echo "- [ ] $PROJECT_NAME (no .claude/ - consider adding)" >> "$REPORT_FILE"
    fi
done
echo "" >> "$REPORT_FILE"

# ============================================================
# SUMMARY
# ============================================================
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| Category | Count | Action |" >> "$REPORT_FILE"
echo "|----------|-------|--------|" >> "$REPORT_FILE"
echo "| Temp files | $TEMP_COUNT | Review and delete |" >> "$REPORT_FILE"
echo "| node_modules | $NODE_COUNT | Remove unused |" >> "$REPORT_FILE"
echo "| Virtual envs | $VENV_COUNT | Remove unused |" >> "$REPORT_FILE"
echo "| Old logs | $LOG_COUNT | Archive or delete |" >> "$REPORT_FILE"
echo "| Backup files | $BACKUP_COUNT | Review and delete |" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*Report saved to: $REPORT_FILE*" >> "$REPORT_FILE"
echo "*Review carefully before any cleanup action*" >> "$REPORT_FILE"

# Output location
echo ""
echo "Janitor audit complete!"
echo "Report saved to: $REPORT_FILE"
echo ""
echo "To view: cat $REPORT_FILE"
