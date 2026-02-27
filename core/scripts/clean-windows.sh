#!/usr/bin/env bash
# clean-windows.sh — Windows cleanup via cmd.exe (NOT PowerShell)
# Usage: bash ~/.claude/scripts/clean-windows.sh [--dry-run]

trap 'exit 0' ERR
sed -i 's/\r$//' "$0" 2>/dev/null || true

DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
    esac
done

# Check if cmd.exe is available
if ! command -v cmd.exe > /dev/null 2>&1; then
    echo "cmd.exe not available — skipping Windows cleanup"
    echo "(This is expected in non-WSL environments)"
    exit 0
fi

if [ "$DRY_RUN" = true ]; then
    echo "[DRY-RUN MODE — no changes will be made]"
    echo ""
fi

echo "=== WINDOWS CLEANUP ==="
echo ""

# --- Windows Temp ---
echo "--- Windows TEMP ---"
TEMP_PATH=$(cmd.exe /c echo %TEMP% 2>/dev/null | tr -d '\r\n' || true)
if [ -n "$TEMP_PATH" ]; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] Would clean Windows TEMP: $TEMP_PATH"
        cmd.exe /c "dir /s \"$TEMP_PATH\" 2>nul" 2>/dev/null | tail -2 | head -1 || true
    else
        echo "Cleaning Windows TEMP: $TEMP_PATH"
        cmd.exe /c "del /q /f \"$TEMP_PATH\\*.tmp\" 2>nul" 2>/dev/null || true
        cmd.exe /c "del /q /f \"$TEMP_PATH\\*.log\" 2>nul" 2>/dev/null || true
        cmd.exe /c "for /d %d in (\"$TEMP_PATH\\*\") do @rmdir /s /q \"%d\" 2>nul" 2>/dev/null || true
        echo "  Done"
    fi
else
    echo "Could not determine TEMP path"
fi
echo ""

# --- Edge Cache ---
echo "--- Edge Browser Cache ---"
LOCALAPPDATA=$(cmd.exe /c echo %LOCALAPPDATA% 2>/dev/null | tr -d '\r\n' || true)
if [ -n "$LOCALAPPDATA" ]; then
    EDGE_CACHE="${LOCALAPPDATA}\\Microsoft\\Edge\\User Data\\Default\\Cache"
    EDGE_CODE_CACHE="${LOCALAPPDATA}\\Microsoft\\Edge\\User Data\\Default\\Code Cache"

    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] Would clean Edge cache at: $EDGE_CACHE"
        echo "[DRY] Would clean Edge code cache at: $EDGE_CODE_CACHE"
    else
        echo "Cleaning Edge cache..."
        cmd.exe /c "if exist \"$EDGE_CACHE\" (rmdir /s /q \"$EDGE_CACHE\" 2>nul)" 2>/dev/null || true
        cmd.exe /c "if exist \"$EDGE_CODE_CACHE\" (rmdir /s /q \"$EDGE_CODE_CACHE\" 2>nul)" 2>/dev/null || true
        echo "  Done (cache rebuilds on next launch)"
    fi
else
    echo "Could not determine LOCALAPPDATA path"
fi
echo ""

# --- VS Code Cache ---
echo "--- VS Code Cache ---"
if [ -n "$LOCALAPPDATA" ]; then
    VSCODE_CACHE="${LOCALAPPDATA}\\Code\\Cache"
    VSCODE_CACHEDDATA="${LOCALAPPDATA}\\Code\\CachedData"

    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] Would clean VS Code cache at: $VSCODE_CACHE"
        echo "[DRY] Would clean VS Code cached data at: $VSCODE_CACHEDDATA"
    else
        echo "Cleaning VS Code cache..."
        cmd.exe /c "if exist \"$VSCODE_CACHE\" (rmdir /s /q \"$VSCODE_CACHE\" 2>nul)" 2>/dev/null || true
        cmd.exe /c "if exist \"$VSCODE_CACHEDDATA\" (rmdir /s /q \"$VSCODE_CACHEDDATA\" 2>nul)" 2>/dev/null || true
        echo "  Done"
    fi
fi
echo ""

# --- Windows Update Cleanup ---
echo "--- Windows Update Cleanup ---"
if [ "$DRY_RUN" = true ]; then
    echo "[DRY] Would run Windows disk cleanup (cleanmgr)"
else
    echo "Running disk cleanup (background, may take a minute)..."
    cmd.exe /c "cleanmgr /d C /sagerun:1 2>nul" 2>/dev/null || echo "  cleanmgr not available or requires elevation"
fi
echo ""

# --- Windows Prefetch (if accessible) ---
echo "--- Windows Prefetch ---"
WINDIR=$(cmd.exe /c echo %WINDIR% 2>/dev/null | tr -d '\r\n' || true)
if [ -n "$WINDIR" ]; then
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY] Would clean prefetch at: ${WINDIR}\\Prefetch"
    else
        echo "Cleaning prefetch..."
        cmd.exe /c "del /q /f \"${WINDIR}\\Prefetch\\*.pf\" 2>nul" 2>/dev/null || echo "  Requires elevation — skipped"
    fi
fi
echo ""

echo "=== WINDOWS CLEANUP COMPLETE ==="
