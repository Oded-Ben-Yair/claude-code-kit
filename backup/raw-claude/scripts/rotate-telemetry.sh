#!/usr/bin/env bash
# Rotate telemetry, debug logs, and file-history to prevent unbounded growth.
# Run manually or add to cron: 0 3 * * 0 ~/.claude/scripts/rotate-telemetry.sh
#
# Retention: telemetry=30d, debug=7d, file-history=30d

set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"

echo "=== Telemetry Rotation ==="

# Telemetry: archive files >30 days
ARCHIVE_DIR="${CLAUDE_DIR}/telemetry/archive"
mkdir -p "$ARCHIVE_DIR"
find "${CLAUDE_DIR}/telemetry" -maxdepth 1 -name "*.jsonl" -mtime +30 -exec mv {} "$ARCHIVE_DIR/" \; 2>/dev/null
echo "Telemetry: archived files >30 days"

# Debug logs: remove >7 days
BEFORE=$(du -sh "${CLAUDE_DIR}/debug/" 2>/dev/null | cut -f1)
find "${CLAUDE_DIR}/debug/" -maxdepth 1 -name "*.txt" ! -name "latest" -mtime +7 -delete 2>/dev/null
AFTER=$(du -sh "${CLAUDE_DIR}/debug/" 2>/dev/null | cut -f1)
echo "Debug: ${BEFORE} -> ${AFTER}"

# File-history: remove dirs not modified in 30 days
BEFORE=$(du -sh "${CLAUDE_DIR}/file-history/" 2>/dev/null | cut -f1)
find "${CLAUDE_DIR}/file-history/" -mindepth 1 -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null
AFTER=$(du -sh "${CLAUDE_DIR}/file-history/" 2>/dev/null | cut -f1)
echo "File-history: ${BEFORE} -> ${AFTER}"

echo "=== Done ==="
