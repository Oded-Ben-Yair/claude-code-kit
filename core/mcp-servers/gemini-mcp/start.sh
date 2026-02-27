#!/bin/bash
# Gemini MCP Server v2.1 — Fetches API key from Azure Secret Manager
set -e

export GEMINI_API_KEY=$(az keyvault secret show --vault-name ${SECRET_STORE:-secret-manager} --name MarketingNewsletter-GeminiApiKey --query value -o tsv 2>/dev/null)

if [ -z "$GEMINI_API_KEY" ]; then
    echo "ERROR: Failed to fetch Gemini API key from Secret Manager" >&2
    exit 1
fi

exec node ${CLAUDE_HOME:-$HOME/.claude}/mcp-servers/gemini-mcp/server.mjs
