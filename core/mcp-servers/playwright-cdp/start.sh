#!/bin/bash
# Playwright MCP - Launch Windows Edge directly from WSL
#
# Solution: Use --executable-path to run Windows Edge exe directly
# This bypasses all CDP networking issues between WSL and Windows

EDGE_PATH="/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
PROFILE_DIR="/tmp/edge-playwright-profile"

# Ensure profile directory exists
mkdir -p "$PROFILE_DIR"

echo "[browser-control] Launching Windows Edge via executable-path" >&2

# Launch Playwright MCP with Windows Edge executable
exec npx @playwright/mcp@latest \
    --browser msedge \
    --executable-path "$EDGE_PATH" \
    --user-data-dir "$PROFILE_DIR" \
    --headless false
