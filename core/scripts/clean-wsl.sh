#!/usr/bin/env bash
# clean-wsl.sh v4.0 — WSL cleanup: stale sessions, Edge, zombies, caches, memory
# Usage: bash ~/.claude/scripts/clean-wsl.sh [--dry-run] [--aggressive]
#
# What it cleans:
#   Phase 1: Orphaned Claude processes (ppid=1)
#   Phase 2: Stale Claude sessions (all MCPs from non-current sessions)
#   Phase 3: Edge/Playwright browser processes
#   Phase 4: Zombie processes
#   Phase 5: Caches (npm, pip, yarn, debug logs, .next, __pycache__, .pytest_cache)
#   Phase 6: Temp files (/tmp/claude-*, old .tmp, telemetry)
#   Phase 7: Memory recovery (drop caches, fstrim)
#
# v4.0 changes:
#   - Replaced trap 'exit 0' ERR with set +e (was causing silent exit)
#   - Removed sed -i self-modification (was triggering ERR trap)
#   - sudo uses echo "1" | sudo -S consistently
#   - Aggressive mode: debug logs >6h (was >48h), telemetry >7d (was >30d)

set +e  # Continue on errors — handle them inline with || true

DRY_RUN=false
AGGRESSIVE=false

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --aggressive) AGGRESSIVE=true ;;
    esac
done

if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN MODE — no changes will be made]"
    echo ""
fi

TOTAL_FREED=0
MY_PID=$$
MY_PPID=$(ps -o ppid= -p $$ 2>/dev/null | tr -d ' ')

# Find the Claude process that owns THIS session
find_my_claude_pid() {
    local pid=$MY_PPID
    local depth=0
    while [ "$pid" != "1" ] && [ "$pid" != "0" ] && [ -n "$pid" ] && [ "$depth" -lt 10 ]; do
        local cmd
        cmd=$(ps -o comm= -p "$pid" 2>/dev/null || true)
        if [ "$cmd" = "claude" ]; then
            echo "$pid"
            return
        fi
        pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
        depth=$((depth + 1))
    done
    echo ""
}

MY_CLAUDE_PID=$(find_my_claude_pid)
if [ -n "$MY_CLAUDE_PID" ]; then
    MY_TTY=$(ps -o tty= -p "$MY_CLAUDE_PID" 2>/dev/null | tr -d ' ')
    echo "Current session: Claude PID $MY_CLAUDE_PID on $MY_TTY"
else
    MY_TTY=""
    echo "Warning: Could not find parent Claude process (running standalone)"
fi
echo ""

# ============================================================
# PHASE 1: Kill Orphaned Claude Processes (ppid=1)
# ============================================================
echo "=== PHASE 1: Orphaned Claude Processes ==="

ORPHAN_PIDS=$(ps -eo pid,ppid,command 2>/dev/null | grep -E '[c]laude.*--dangerously-skip-permissions|[c]laude.*subagent|[n]ode.*claude' | awk '$2 == 1 {print $1}' || true)

if [ -n "$ORPHAN_PIDS" ]; then
    ORPHAN_COUNT=$(echo "$ORPHAN_PIDS" | wc -w)
    ORPHAN_RSS=$(ps -o rss= -p $(echo "$ORPHAN_PIDS" | tr '\n' ',') 2>/dev/null | awk '{sum += $1} END {printf "%.0f", sum/1024}' || echo "0")

    echo "Found $ORPHAN_COUNT orphaned processes (~${ORPHAN_RSS}MB RAM)"

    for PID in $ORPHAN_PIDS; do
        CMD=$(ps -p "$PID" -o command= 2>/dev/null | head -c 80 || echo "unknown")
        RSS=$(ps -p "$PID" -o rss= 2>/dev/null | awk '{printf "%.0f", $1/1024}' || echo "?")
        CHILDREN=$(pgrep -P "$PID" 2>/dev/null || true)

        if [ "$DRY_RUN" = true ]; then
            echo "  [DRY] Would kill PID $PID (${RSS}MB): $CMD"
            [ -n "$CHILDREN" ] && echo "  [DRY]   + $(echo "$CHILDREN" | wc -w) child processes"
        else
            echo "  Killing PID $PID (${RSS}MB): $CMD"
            if [ -n "$CHILDREN" ]; then
                for CHILD in $CHILDREN; do
                    kill -TERM "$CHILD" 2>/dev/null || true
                done
            fi
            kill -TERM "$PID" 2>/dev/null || true
        fi
    done

    if [ "$DRY_RUN" = false ]; then
        echo "  Waiting 3s for graceful shutdown..."
        sleep 3
        for PID in $ORPHAN_PIDS; do
            if kill -0 "$PID" 2>/dev/null; then
                echo "  Force killing PID $PID"
                kill -9 "$PID" 2>/dev/null || true
                CHILDREN=$(pgrep -P "$PID" 2>/dev/null || true)
                for CHILD in $CHILDREN; do
                    kill -9 "$CHILD" 2>/dev/null || true
                done
            fi
        done
        TOTAL_FREED=$((TOTAL_FREED + ${ORPHAN_RSS:-0}))
        echo "  Freed ~${ORPHAN_RSS}MB RAM"
    fi
else
    echo "No orphaned Claude processes found"
fi
echo ""

# ============================================================
# PHASE 2: Kill Stale Claude Sessions (duplicate MCPs)
# ============================================================
echo "=== PHASE 2: Stale Claude Sessions ==="

ALL_CLAUDE=$(ps -eo pid,tty,rss,command 2>/dev/null | grep '[c]laude.*--dangerously-skip-permissions' | grep -v "grep" || true)
CLAUDE_COUNT=$(echo "$ALL_CLAUDE" | grep -c "claude" 2>/dev/null) || CLAUDE_COUNT=0

if [ "$CLAUDE_COUNT" -gt 1 ] && [ -n "$MY_CLAUDE_PID" ]; then
    echo "Found $CLAUDE_COUNT Claude sessions. Current session PID: $MY_CLAUDE_PID"
    echo "$ALL_CLAUDE" | while read -r line; do
        PID=$(echo "$line" | awk '{print $1}')
        TTY=$(echo "$line" | awk '{print $2}')
        RSS=$(echo "$line" | awk '{printf "%.0f", $3/1024}')

        if [ "$PID" = "$MY_CLAUDE_PID" ]; then
            echo "  [KEEP] PID $PID ($TTY, ${RSS}MB) — current session"
        else
            CHILD_COUNT=$(pgrep -P "$PID" 2>/dev/null | wc -l || echo "0")
            CHILD_RSS=$(pgrep -P "$PID" 2>/dev/null | xargs -I{} ps -o rss= -p {} 2>/dev/null | awk '{sum += $1} END {printf "%.0f", sum/1024}' || echo "0")

            if [ "$DRY_RUN" = true ]; then
                echo "  [DRY] Would kill PID $PID ($TTY, ${RSS}MB) + $CHILD_COUNT children (~${CHILD_RSS}MB)"
            else
                echo "  Killing stale session PID $PID ($TTY, ${RSS}MB) + $CHILD_COUNT children (~${CHILD_RSS}MB)"
                for CHILD in $(pgrep -P "$PID" 2>/dev/null || true); do
                    kill -TERM "$CHILD" 2>/dev/null || true
                done
                kill -TERM "$PID" 2>/dev/null || true
                TOTAL_FREED=$((TOTAL_FREED + RSS + CHILD_RSS))
            fi
        fi
    done

    if [ "$DRY_RUN" = false ]; then
        sleep 2
        echo "$ALL_CLAUDE" | while read -r line; do
            PID=$(echo "$line" | awk '{print $1}')
            [ "$PID" = "$MY_CLAUDE_PID" ] && continue
            if kill -0 "$PID" 2>/dev/null; then
                kill -9 "$PID" 2>/dev/null || true
                for CHILD in $(pgrep -P "$PID" 2>/dev/null || true); do
                    kill -9 "$CHILD" 2>/dev/null || true
                done
            fi
        done
    fi
elif [ "$CLAUDE_COUNT" -le 1 ]; then
    echo "Only 1 Claude session running (good)"
else
    echo "Multiple sessions found but couldn't identify current — skipping (safety)"
fi
echo ""

# ============================================================
# PHASE 3: Edge/Playwright Browser Processes
# ============================================================
echo "=== PHASE 3: Edge/Playwright Browser Cleanup ==="

# IMPORTANT: Use `pgrep msedge` (binary name match), NOT `pgrep -f "microsoft-edge"`
# pgrep -f matches against /proc/pid/cmdline which includes this script's source text,
# causing pkill to kill the script itself (exit code 144 = SIGTERM self-kill).
EDGE_PIDS=$(pgrep msedge 2>/dev/null || true)
EDGE_COUNT=0
[ -n "$EDGE_PIDS" ] && EDGE_COUNT=$(echo "$EDGE_PIDS" | wc -w)

if [ "$EDGE_COUNT" -gt 0 ]; then
    EDGE_RSS=$(echo "$EDGE_PIDS" | xargs -I{} ps -o rss= -p {} 2>/dev/null | awk '{sum += $1} END {printf "%.0f", sum/1024}' || echo "0")

    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] Would kill $EDGE_COUNT Edge browser processes (~${EDGE_RSS}MB)"
    else
        echo "Killing $EDGE_COUNT Edge browser processes (~${EDGE_RSS}MB)..."
        for _ep in $EDGE_PIDS; do
            kill -TERM "$_ep" 2>/dev/null || true
        done
        sleep 2
        for _ep in $EDGE_PIDS; do
            kill -0 "$_ep" 2>/dev/null && kill -9 "$_ep" 2>/dev/null || true
        done
        TOTAL_FREED=$((TOTAL_FREED + ${EDGE_RSS:-0}))
        echo "  Freed ~${EDGE_RSS}MB"
    fi
else
    echo "No Edge browser processes found"
fi

# Also clean Playwright lock/profile data if aggressive
if [ "$AGGRESSIVE" = true ]; then
    PW_CACHE=$(du -sm ~/.config/microsoft-edge-playwright/Default/Cache 2>/dev/null | awk '{print $1}' || echo "0")
    if [ "${PW_CACHE:-0}" -gt 10 ]; then
        if [ "$DRY_RUN" = true ]; then
            echo "[DRY] Would clean Playwright browser cache (~${PW_CACHE}MB)"
        else
            echo "Cleaning Playwright browser cache (~${PW_CACHE}MB)..."
            rm -rf ~/.config/microsoft-edge-playwright/Default/Cache 2>/dev/null || true
            rm -rf ~/.config/microsoft-edge-playwright/Default/Code\ Cache 2>/dev/null || true
            TOTAL_FREED=$((TOTAL_FREED + PW_CACHE))
        fi
    else
        echo "Playwright browser cache: ${PW_CACHE:-0}MB (below threshold)"
    fi
fi
echo ""

# ============================================================
# PHASE 4: Zombie Processes
# ============================================================
echo "=== PHASE 4: Zombie Processes ==="

ZOMBIES=$(ps -eo pid,ppid,stat,command 2>/dev/null | awk '$3 ~ /Z/' || true)
ZOMBIE_COUNT=$(echo "$ZOMBIES" | grep -c "[0-9]" 2>/dev/null) || ZOMBIE_COUNT=0

if [ "$ZOMBIE_COUNT" -gt 0 ]; then
    echo "Found $ZOMBIE_COUNT zombie processes:"
    echo "$ZOMBIES" | while read -r line; do
        ZPID=$(echo "$line" | awk '{print $1}')
        ZPPID=$(echo "$line" | awk '{print $2}')
        ZCMD=$(echo "$line" | awk '{$1=$2=$3=""; print}' | sed 's/^  *//')

        if [ "$DRY_RUN" = true ]; then
            echo "  [DRY] Would reap zombie PID $ZPID (parent $ZPPID): $ZCMD"
        else
            echo "  Reaping zombie PID $ZPID (parent $ZPPID): $ZCMD"
            kill -SIGCHLD "$ZPPID" 2>/dev/null || true
            sleep 1
            if ps -p "$ZPID" -o stat= 2>/dev/null | grep -q "Z"; then
                echo "    Zombie persists (parent must reap it)"
            fi
        fi
    done
else
    echo "No zombie processes found"
fi
echo ""

# ============================================================
# PHASE 5: Clean Caches
# ============================================================
echo "=== PHASE 5: Clean Caches ==="

# npm cache
NPM_BEFORE=$(du -sm ~/.npm 2>/dev/null | awk '{print $1}' || echo "0")
if [ "${NPM_BEFORE:-0}" -gt 0 ] 2>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] Would clean npm cache (~${NPM_BEFORE}MB)"
    else
        echo "Cleaning npm cache (~${NPM_BEFORE}MB)..."
        npm cache clean --force 2>/dev/null || true
        NPM_AFTER=$(du -sm ~/.npm 2>/dev/null | awk '{print $1}' || echo "0")
        SAVED=$((NPM_BEFORE - NPM_AFTER))
        [ "$SAVED" -lt 0 ] && SAVED=0
        TOTAL_FREED=$((TOTAL_FREED + SAVED))
        echo "  Freed ${SAVED}MB"
    fi
fi

# pip cache
PIP_BEFORE=$(du -sm ~/.cache/pip 2>/dev/null | awk '{print $1}' || echo "0")
if [ "${PIP_BEFORE:-0}" -gt 0 ] 2>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] Would clean pip cache (~${PIP_BEFORE}MB)"
    else
        echo "Cleaning pip cache (~${PIP_BEFORE}MB)..."
        pip cache purge 2>/dev/null || true
        PIP_AFTER=$(du -sm ~/.cache/pip 2>/dev/null | awk '{print $1}' || echo "0")
        SAVED=$((PIP_BEFORE - PIP_AFTER))
        [ "$SAVED" -lt 0 ] && SAVED=0
        TOTAL_FREED=$((TOTAL_FREED + SAVED))
        echo "  Freed ${SAVED}MB"
    fi
fi

# yarn cache
YARN_BEFORE=$(du -sm ~/.cache/yarn 2>/dev/null | awk '{print $1}' || echo "0")
if [ "${YARN_BEFORE:-0}" -gt 0 ] 2>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] Would clean yarn cache (~${YARN_BEFORE}MB)"
    else
        echo "Cleaning yarn cache (~${YARN_BEFORE}MB)..."
        yarn cache clean 2>/dev/null || true
        YARN_AFTER=$(du -sm ~/.cache/yarn 2>/dev/null | awk '{print $1}' || echo "0")
        SAVED=$((YARN_BEFORE - YARN_AFTER))
        [ "$SAVED" -lt 0 ] && SAVED=0
        TOTAL_FREED=$((TOTAL_FREED + SAVED))
        echo "  Freed ${SAVED}MB"
    fi
fi

# Claude debug logs — aggressive: >6 hours, normal: >48 hours
DEBUG_BEFORE=$(du -sm ~/.claude/debug 2>/dev/null | awk '{print $1}' || echo "0")
if [ "${DEBUG_BEFORE:-0}" -gt 1 ] 2>/dev/null; then
    if [ "$AGGRESSIVE" = true ]; then
        DEBUG_THRESHOLD="-mmin +360"
        DEBUG_LABEL="6 hours"
    else
        DEBUG_THRESHOLD="-mtime +1"
        DEBUG_LABEL="48 hours"
    fi
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] Would clean Claude debug logs older than $DEBUG_LABEL (~${DEBUG_BEFORE}MB total)"
    else
        echo "Cleaning Claude debug logs older than $DEBUG_LABEL (~${DEBUG_BEFORE}MB total)..."
        find ${CLAUDE_HOME:-$HOME/.claude}/debug -type f $DEBUG_THRESHOLD -delete 2>/dev/null || true
        DEBUG_AFTER=$(du -sm ~/.claude/debug 2>/dev/null | awk '{print $1}' || echo "0")
        SAVED=$((DEBUG_BEFORE - DEBUG_AFTER))
        [ "$SAVED" -lt 0 ] && SAVED=0
        TOTAL_FREED=$((TOTAL_FREED + SAVED))
        echo "  Freed ${SAVED}MB (kept files <$DEBUG_LABEL old)"
    fi
fi

# .next build caches
for proj_dir in $HOME/projects/*/; do
    if [ -d "${proj_dir}.next" ]; then
        NEXT_SIZE=$(du -sm "${proj_dir}.next" 2>/dev/null | awk '{print $1}' || echo "0")
        proj_name=$(basename "$proj_dir")
        if [ "$DRY_RUN" = true ]; then
            echo "[DRY] Would remove ${proj_name}/.next (~${NEXT_SIZE}MB)"
        else
            echo "Removing ${proj_name}/.next (~${NEXT_SIZE}MB)..."
            rm -rf "${proj_dir}.next" 2>/dev/null || true
            TOTAL_FREED=$((TOTAL_FREED + NEXT_SIZE))
        fi
    fi
done

# __pycache__ directories
PYCACHE_SIZE=$(find $HOME/projects -maxdepth 4 -name "__pycache__" -type d -print0 2>/dev/null | xargs -0 -r du -sm 2>/dev/null | awk '{sum += $1} END {print sum+0}')
if [ "${PYCACHE_SIZE:-0}" -gt 0 ] 2>/dev/null; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] Would remove all __pycache__ dirs (~${PYCACHE_SIZE}MB)"
    else
        echo "Removing all __pycache__ dirs (~${PYCACHE_SIZE}MB)..."
        find $HOME/projects -maxdepth 4 -name "__pycache__" -type d -print0 2>/dev/null | xargs -0 -r rm -rf 2>/dev/null || true
        TOTAL_FREED=$((TOTAL_FREED + PYCACHE_SIZE))
    fi
fi

# .pytest_cache
for proj_dir in $HOME/projects/*/; do
    if [ -d "${proj_dir}.pytest_cache" ]; then
        PYTEST_SIZE=$(du -sm "${proj_dir}.pytest_cache" 2>/dev/null | awk '{print $1}' || echo "0")
        proj_name=$(basename "$proj_dir")
        if [ "$DRY_RUN" = true ]; then
            echo "[DRY] Would remove ${proj_name}/.pytest_cache (~${PYTEST_SIZE}MB)"
        else
            echo "Removing ${proj_name}/.pytest_cache (~${PYTEST_SIZE}MB)..."
            rm -rf "${proj_dir}.pytest_cache" 2>/dev/null || true
            TOTAL_FREED=$((TOTAL_FREED + PYTEST_SIZE))
        fi
    fi
done

# node_modules (aggressive only)
if [ "$AGGRESSIVE" = true ]; then
    echo ""
    echo "--- AGGRESSIVE: node_modules ---"
    NM_FOUND=false
    for proj_dir in $HOME/projects/*/; do
        if [ -d "${proj_dir}node_modules" ]; then
            NM_FOUND=true
            NM_SIZE=$(du -sm "${proj_dir}node_modules" 2>/dev/null | awk '{print $1}' || echo "0")
            proj_name=$(basename "$proj_dir")
            if [ "$DRY_RUN" = true ]; then
                echo "[DRY] Would remove ${proj_name}/node_modules (~${NM_SIZE}MB)"
            else
                echo "Removing ${proj_name}/node_modules (~${NM_SIZE}MB)..."
                rm -rf "${proj_dir}node_modules" 2>/dev/null || true
                TOTAL_FREED=$((TOTAL_FREED + NM_SIZE))
            fi
        fi
    done
    if [ "$NM_FOUND" = false ]; then
        echo "No node_modules directories found"
    fi
fi

echo ""

# ============================================================
# PHASE 6: Clean Temp Files
# ============================================================
echo "=== PHASE 6: Clean Temp Files ==="

# /tmp/claude-*.flag
CLAUDE_FLAGS=$(find /tmp -maxdepth 1 -name "claude-*.flag" -type f 2>/dev/null || true)
if [ -n "$CLAUDE_FLAGS" ]; then
    FLAG_COUNT=$(echo "$CLAUDE_FLAGS" | wc -l)
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] Would remove $FLAG_COUNT claude flag files from /tmp"
    else
        echo "Removing $FLAG_COUNT claude flag files from /tmp..."
        echo "$CLAUDE_FLAGS" | xargs -r rm -f 2>/dev/null || true
    fi
fi

# /tmp/*.tmp files older than 1 day
OLD_TMP=$(find /tmp -maxdepth 1 -name "*.tmp" -type f -mtime +1 2>/dev/null || true)
if [ -n "$OLD_TMP" ]; then
    TMP_COUNT=$(echo "$OLD_TMP" | wc -l)
    TMP_SIZE=$(echo "$OLD_TMP" | xargs -r du -sm 2>/dev/null | awk '{sum += $1} END {print sum+0}' || echo "0")
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] Would remove $TMP_COUNT old .tmp files (~${TMP_SIZE}MB)"
    else
        echo "Removing $TMP_COUNT old .tmp files (~${TMP_SIZE}MB)..."
        echo "$OLD_TMP" | xargs -r rm -f 2>/dev/null || true
        TOTAL_FREED=$((TOTAL_FREED + TMP_SIZE))
    fi
fi

# Old telemetry JSONL files — aggressive: >7 days, normal: >30 days
if [ -d ${CLAUDE_HOME:-$HOME/.claude}/telemetry ]; then
    if [ "$AGGRESSIVE" = true ]; then
        TELEM_THRESHOLD="-mtime +7"
        TELEM_LABEL="7 days"
    else
        TELEM_THRESHOLD="-mtime +30"
        TELEM_LABEL="30 days"
    fi
    OLD_TELEM=$(find ${CLAUDE_HOME:-$HOME/.claude}/telemetry -name "*.jsonl" -type f $TELEM_THRESHOLD 2>/dev/null || true)
    if [ -n "$OLD_TELEM" ]; then
        TELEM_COUNT=$(echo "$OLD_TELEM" | wc -l)
        TELEM_SIZE=$(echo "$OLD_TELEM" | xargs -r du -sm 2>/dev/null | awk '{sum += $1} END {print sum+0}' || echo "0")
        if [ "$DRY_RUN" = true ]; then
            echo "[DRY] Would remove $TELEM_COUNT telemetry files older than $TELEM_LABEL (~${TELEM_SIZE}MB)"
        else
            echo "Removing $TELEM_COUNT telemetry files older than $TELEM_LABEL (~${TELEM_SIZE}MB)..."
            echo "$OLD_TELEM" | xargs -r rm -f 2>/dev/null || true
            TOTAL_FREED=$((TOTAL_FREED + TELEM_SIZE))
        fi
    else
        echo "No telemetry files older than $TELEM_LABEL"
    fi
fi

# Orphaned temp files in /tmp from Claude
CLAUDE_TMP=$(find /tmp -maxdepth 2 \( -name "claude*" -o -name "mcp-*" \) 2>/dev/null | grep -v "\.flag$" || true)
if [ -n "$CLAUDE_TMP" ]; then
    CTMP_COUNT=$(echo "$CLAUDE_TMP" | wc -l)
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] Would remove $CTMP_COUNT Claude temp files/dirs from /tmp"
    else
        echo "Removing $CTMP_COUNT Claude temp files/dirs from /tmp..."
        echo "$CLAUDE_TMP" | xargs -r rm -rf 2>/dev/null || true
    fi
else
    echo "No Claude temp files in /tmp"
fi

echo ""

# ============================================================
# PHASE 7: Memory Recovery
# ============================================================
echo "=== PHASE 7: Memory Recovery ==="

if [ "$DRY_RUN" = true ]; then
    echo "[DRY] Would drop filesystem caches (sudo)"
    echo "[DRY] Would run fstrim for VHD compaction (sudo)"
else
    echo "Dropping filesystem caches..."
    sync
    echo "1" | sudo -S sh -c 'echo 3 > /proc/sys/vm/drop_caches' 2>/dev/null || echo "  (sudo unavailable — skipped)"

    echo "Running fstrim for VHD compaction..."
    echo "1" | sudo -S fstrim / 2>/dev/null || echo "  (sudo unavailable — skipped)"

    MEM_AFTER=$(free -m 2>/dev/null | awk '/Mem:/ {print $7}' || echo "?")
    SWAP_AFTER=$(free -m 2>/dev/null | awk '/Swap:/ {print $3}' || echo "?")
    echo "Memory available now: ${MEM_AFTER}MB | Swap used: ${SWAP_AFTER}MB"
fi

echo ""

# ============================================================
# HEALTH CHECK
# ============================================================
echo "=== HEALTH CHECK ==="

MEM_TOTAL=$(free -m 2>/dev/null | awk '/Mem:/ {print $2}')
MEM_AVAIL=$(free -m 2>/dev/null | awk '/Mem:/ {print $7}')
if [ -n "$MEM_TOTAL" ] && [ "$MEM_TOTAL" -gt 0 ] 2>/dev/null; then
    MEM_PCT=$((MEM_AVAIL * 100 / MEM_TOTAL))
else
    MEM_PCT=0
fi
SWAP_USED=$(free -m 2>/dev/null | awk '/Swap:/ {print $3}')

if [ "$MEM_PCT" -lt 20 ]; then
    echo "WARNING: Memory pressure HIGH (${MEM_PCT}% available, ${SWAP_USED}MB swap used)"
    echo "  Consider: close other terminals, restart WSL, or increase .wslconfig memory"
elif [ "$MEM_PCT" -lt 40 ]; then
    echo "Memory: OK but tight (${MEM_PCT}% available, ${SWAP_USED}MB swap used)"
else
    echo "Memory: Healthy (${MEM_PCT}% available, ${SWAP_USED}MB swap used)"
fi

PROC_COUNT=$(ps aux 2>/dev/null | grep -E "node|claude" | grep -v grep | wc -l)
echo "Claude/Node processes: $PROC_COUNT"

CLAUDE_SESSIONS=$(ps -eo command 2>/dev/null | grep -c '[c]laude.*--dangerously-skip-permissions') || CLAUDE_SESSIONS=0
if [ "$CLAUDE_SESSIONS" -gt 1 ]; then
    echo "WARNING: $CLAUDE_SESSIONS Claude sessions still running — duplicates waste ~1GB each"
fi

EDGE_RUNNING=$(pgrep -c -f "microsoft-edge" 2>/dev/null) || EDGE_RUNNING=0
if [ "$EDGE_RUNNING" -gt 0 ]; then
    echo "Note: $EDGE_RUNNING Edge processes running (Playwright)"
fi

echo ""

# ============================================================
# SUMMARY
# ============================================================
echo "=== CLEANUP COMPLETE ==="
if [ "$DRY_RUN" = true ]; then
    echo "Mode: DRY RUN (no changes made)"
    echo "Run without --dry-run to apply changes"
else
    echo "Total freed: ~${TOTAL_FREED}MB"
    echo "Memory status:"
    free -h 2>/dev/null | head -2 || true
fi

WSL_MEM=$(awk '/MemTotal/ {printf "%.0f", $2/1024/1024}' /proc/meminfo 2>/dev/null)
if [ "${WSL_MEM:-0}" -lt 8 ]; then
    echo ""
    echo "TIP: WSL is limited to ${WSL_MEM}GB RAM. Edit %USERPROFILE%\\.wslconfig to increase."
    echo "     Recommended: memory=10GB for Claude Code with MCPs."
    echo "     After editing, run: wsl --shutdown && restart WSL"
fi

echo ""
