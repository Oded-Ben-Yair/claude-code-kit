#!/bin/bash
# Playwright MCP with Edge CDP - Auto-launcher
# This script ensures Edge is running with CDP before starting Playwright MCP

CDP_PORT=9222
EDGE_PATH="/opt/microsoft/msedge/microsoft-edge"
USER_DATA="$HOME/.config/microsoft-edge-playwright"
export DISPLAY=:0

# Check if Edge CDP is already running
if curl -s --connect-timeout 1 "http://127.0.0.1:${CDP_PORT}/json/version" >/dev/null 2>&1; then
    echo "[edge-mcp] Edge CDP already running on port ${CDP_PORT}" >&2
else
    echo "[edge-mcp] Starting Edge with CDP on port ${CDP_PORT}..." >&2
    mkdir -p "$USER_DATA"

    # Launch Edge with CDP in background
    "$EDGE_PATH" \
        --remote-debugging-port=${CDP_PORT} \
        --user-data-dir="$USER_DATA" \
        --no-first-run \
        --disable-sync \
        --disable-background-networking \
        about:blank >/dev/null 2>&1 &

    # Wait for CDP to be ready
    for i in {1..10}; do
        if curl -s --connect-timeout 1 "http://127.0.0.1:${CDP_PORT}/json/version" >/dev/null 2>&1; then
            echo "[edge-mcp] Edge CDP ready" >&2
            break
        fi
        sleep 0.5
    done
fi

# Start Playwright MCP connecting to Edge CDP
exec npx @playwright/mcp@latest --cdp-endpoint "http://127.0.0.1:${CDP_PORT}"
