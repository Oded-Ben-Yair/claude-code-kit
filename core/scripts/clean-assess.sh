#!/usr/bin/env bash
# clean-assess.sh — Environment health assessment (read-only, no changes)
# Usage: bash ~/.claude/scripts/clean-assess.sh

trap 'exit 0' ERR
sed -i 's/\r$//' "$0" 2>/dev/null || true

echo "============================================"
echo "  Environment Health Assessment"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================"
echo ""

# --- Memory ---
echo "=== MEMORY ==="
free -h 2>/dev/null || echo "free command not available"
echo ""

# Swap details
SWAP_USED=$(free -m 2>/dev/null | awk '/Swap:/ {print $3}')
SWAP_TOTAL=$(free -m 2>/dev/null | awk '/Swap:/ {print $2}')
MEM_AVAIL=$(free -m 2>/dev/null | awk '/Mem:/ {print $7}')
MEM_TOTAL=$(free -m 2>/dev/null | awk '/Mem:/ {print $2}')
echo "Available: ${MEM_AVAIL:-?}MB / ${MEM_TOTAL:-?}MB | Swap: ${SWAP_USED:-?}MB / ${SWAP_TOTAL:-?}MB"
echo ""

# --- Orphaned Claude Processes ---
echo "=== ORPHANED CLAUDE PROCESSES (ppid=1) ==="
ORPHANS=$(ps -eo pid,ppid,rss,etime,command 2>/dev/null | grep -E '[c]laude|[n]ode.*claude' | awk '$2 == 1' || true)
if [ -n "$ORPHANS" ]; then
    ORPHAN_COUNT=$(echo "$ORPHANS" | wc -l)
    ORPHAN_RSS=$(echo "$ORPHANS" | awk '{sum += $3} END {printf "%.0f", sum/1024}')
    echo "Found $ORPHAN_COUNT orphaned processes using ~${ORPHAN_RSS}MB RAM"
    echo "PID     RSS(MB)  ELAPSED   COMMAND"
    echo "$ORPHANS" | awk '{printf "%-7s %-8.0f %-9s %s\n", $1, $3/1024, $4, substr($0, index($0,$5))}' || true
else
    echo "No orphaned Claude processes found"
fi
echo ""

# --- All Claude-related Processes ---
echo "=== ALL CLAUDE-RELATED PROCESSES ==="
CLAUDE_PROCS=$(ps -eo pid,ppid,rss,etime,command 2>/dev/null | grep -E '[c]laude|[n]ode.*mcp' | head -20 || true)
if [ -n "$CLAUDE_PROCS" ]; then
    TOTAL_CLAUDE_RSS=$(echo "$CLAUDE_PROCS" | awk '{sum += $3} END {printf "%.0f", sum/1024}')
    echo "Total Claude-related process memory: ~${TOTAL_CLAUDE_RSS}MB"
    echo "$CLAUDE_PROCS" | head -15 || true
    PROC_COUNT=$(echo "$CLAUDE_PROCS" | wc -l)
    if [ "$PROC_COUNT" -gt 15 ]; then
        echo "... and $((PROC_COUNT - 15)) more"
    fi
else
    echo "No Claude-related processes found"
fi
echo ""

# --- Disk Usage ---
echo "=== DISK USAGE ==="
df -h / 2>/dev/null | tail -1 | awk '{printf "Root (/): %s used of %s (%s), %s available\n", $3, $2, $5, $4}' || true
echo ""

# --- Cache Sizes ---
echo "=== CACHE SIZES ==="
printf "%-40s %s\n" "Location" "Size"
printf "%-40s %s\n" "--------" "----"

# npm cache
NPM_CACHE=$(du -sh ~/.npm 2>/dev/null | awk '{print $1}' || echo "0")
printf "%-40s %s\n" "npm cache (~/.npm)" "$NPM_CACHE"

# pip cache
PIP_CACHE=$(du -sh ~/.cache/pip 2>/dev/null | awk '{print $1}' || echo "0")
printf "%-40s %s\n" "pip cache (~/.cache/pip)" "$PIP_CACHE"

# yarn cache
YARN_CACHE=$(du -sh ~/.cache/yarn 2>/dev/null | awk '{print $1}' || echo "0")
printf "%-40s %s\n" "yarn cache (~/.cache/yarn)" "$YARN_CACHE"

# Claude debug
CLAUDE_DEBUG=$(du -sh ~/.claude/debug 2>/dev/null | awk '{print $1}' || echo "0")
printf "%-40s %s\n" "Claude debug (~/.claude/debug)" "$CLAUDE_DEBUG"

# Claude telemetry
CLAUDE_TELEM=$(du -sh ~/.claude/telemetry 2>/dev/null | awk '{print $1}' || echo "0")
printf "%-40s %s\n" "Claude telemetry (~/.claude/telemetry)" "$CLAUDE_TELEM"

# /tmp
TMP_SIZE=$(du -sh /tmp 2>/dev/null | awk '{print $1}' || echo "0")
TMP_OLD=$(find /tmp -maxdepth 1 -type f -mtime +1 2>/dev/null | wc -l || echo "0")
printf "%-40s %s (%s files >1 day old)\n" "/tmp" "$TMP_SIZE" "$TMP_OLD"

echo ""

# --- Project Build Caches (fast scan, >1MB only) ---
echo "=== PROJECT BUILD CACHES (>1MB) ==="
printf "%-50s %s\n" "Location" "Size"
printf "%-50s %s\n" "--------" "----"

# .next dirs (usually large)
for d in $HOME/projects/*/.next; do
    [ -d "$d" ] || continue
    SIZE=$(du -sm "$d" 2>/dev/null | awk '{print $1}')
    [ "${SIZE:-0}" -gt 1 ] 2>/dev/null && printf "%-50s %sMB\n" "$(basename "$(dirname "$d")")/.next" "$SIZE"
done

# node_modules (top-level only, usually large)
for d in $HOME/projects/*/node_modules; do
    [ -d "$d" ] || continue
    SIZE=$(du -sm "$d" 2>/dev/null | awk '{print $1}')
    [ "${SIZE:-0}" -gt 1 ] 2>/dev/null && printf "%-50s %sMB\n" "$(basename "$(dirname "$d")")/node_modules" "$SIZE"
done

# __pycache__ total across all projects (single find, fast)
PYCACHE_TOTAL=$(find $HOME/projects -maxdepth 4 -name "__pycache__" -type d -print0 2>/dev/null | xargs -0 -r du -sm 2>/dev/null | awk '{sum += $1} END {print sum+0}')
echo ""
echo "Total __pycache__ across all projects: ${PYCACHE_TOTAL:-0}MB"

# .pytest_cache total
PYTEST_TOTAL=$(find $HOME/projects -maxdepth 2 -name ".pytest_cache" -type d -print0 2>/dev/null | xargs -0 -r du -sm 2>/dev/null | awk '{sum += $1} END {print sum+0}')
echo "Total .pytest_cache across all projects: ${PYTEST_TOTAL:-0}MB"

echo ""

# --- Windows (quick check, no slow dir /s) ---
echo "=== WINDOWS ==="
if command -v cmd.exe > /dev/null 2>&1; then
    WIN_TEMP=$(cmd.exe /c echo %TEMP% 2>/dev/null | tr -d '\r\n' || true)
    WIN_LOCAL=$(cmd.exe /c echo %LOCALAPPDATA% 2>/dev/null | tr -d '\r\n' || true)
    echo "TEMP path: ${WIN_TEMP:-unavailable}"
    echo "LOCALAPPDATA: ${WIN_LOCAL:-unavailable}"
    echo "(Run clean-windows.sh for detailed Windows cleanup)"
else
    echo "cmd.exe not available — skipping Windows assessment"
fi

echo ""

# --- Summary ---
echo "=== SUMMARY ==="
echo "Memory available: ${MEM_AVAIL:-?}MB"
echo "Swap used: ${SWAP_USED:-?}MB"
echo "Orphaned processes: ${ORPHAN_COUNT:-0} (~${ORPHAN_RSS:-0}MB)"
echo "Reclaimable (estimated):"
echo "  - Orphaned processes: ~${ORPHAN_RSS:-0}MB (RAM, immediate)"
echo "  - Caches: run with --verbose for detailed breakdown"
echo "  - /tmp old files: ${TMP_OLD:-0} files"
echo ""
echo "Recommendation:"
if [ "${ORPHAN_COUNT:-0}" -gt 0 ] && [ "${MEM_AVAIL:-9999}" -lt 500 ]; then
    echo "  CRITICAL: Kill orphaned processes first (biggest memory win)"
elif [ "${MEM_AVAIL:-9999}" -lt 1000 ]; then
    echo "  WARNING: Low memory. Run clean-wsl.sh to reclaim resources"
else
    echo "  OK: System looks healthy"
fi
echo ""
