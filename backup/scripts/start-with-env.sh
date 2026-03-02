#!/bin/bash
# Grok MCP Server Launcher
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

if [ -z "$XAI_API_KEY" ]; then
    echo "ERROR: XAI_API_KEY not set in $ENV_FILE" >&2
    exit 1
fi

# Launch the MCP server
exec node /home/odedbe/.claude/mcp-servers/grok/dist/index.js
