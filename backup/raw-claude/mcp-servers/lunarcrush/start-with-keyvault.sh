#!/bin/bash
# LunarCrush MCP Server - Fetches API key from Azure Key Vault
# Crypto social intelligence: sentiment, AltRank, Galaxy Score, mentions

# Fetch API key from Key Vault
export LUNARCRUSH_API_KEY=$(az keyvault secret show --vault-name kv-seekapa-apps --name LunarCrush-ApiKey --query value -o tsv 2>/dev/null)

if [ -z "$LUNARCRUSH_API_KEY" ]; then
  echo "ERROR: Failed to fetch LunarCrush API key from Key Vault" >&2
  exit 1
fi

# Install package if not present
PACKAGE_DIR="/home/odedbe/.claude/mcp-servers/lunarcrush/node_modules/@lunarcrush/mcp-server"
if [ ! -d "$PACKAGE_DIR" ]; then
  npm install --prefix /home/odedbe/.claude/mcp-servers/lunarcrush @lunarcrush/mcp-server >/dev/null 2>&1
fi

# Run the official LunarCrush MCP server
exec node "$PACKAGE_DIR/index.js"
