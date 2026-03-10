#!/bin/bash
# LunarCrush MCP Server Launcher
# Loads API key from secure env file at startup

set -e

ENV_FILE="/home/odedbe/.claude/.env.secrets"

if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: Secrets file not found: $ENV_FILE" >&2
    exit 1
fi

# Load secrets
set -a
source "$ENV_FILE"
set +a

if [ -z "$LUNARCRUSH_API_KEY" ]; then
    echo "ERROR: LUNARCRUSH_API_KEY not set in $ENV_FILE" >&2
    exit 1
fi

# Launch the MCP server
exec node /home/odedbe/.claude/mcp-servers/lunarcrush/node_modules/@lunarcrush/mcp-server/index.js
