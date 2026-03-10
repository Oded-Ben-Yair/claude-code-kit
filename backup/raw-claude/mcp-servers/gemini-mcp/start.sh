#!/bin/bash
# Gemini MCP Server v2.1 — Fetches API key from Azure Key Vault
set -e

export GEMINI_API_KEY=$(az keyvault secret show --vault-name kv-seekapa-apps --name MarketingNewsletter-GeminiApiKey --query value -o tsv 2>/dev/null)

if [ -z "$GEMINI_API_KEY" ]; then
    echo "ERROR: Failed to fetch Gemini API key from Key Vault" >&2
    exit 1
fi

exec node /home/odedbe/.claude/mcp-servers/gemini-mcp/server.mjs
