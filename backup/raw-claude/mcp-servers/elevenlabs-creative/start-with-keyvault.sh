#!/bin/bash
# ElevenLabs Creative MCP Server Launcher
# Fetches API key from Key Vault at startup for secure credential management

set -e

# Key Vault configuration
VAULT_NAME="kv-seekapa-apps"
SECRET_NAME="ElevenLabs-ApiKey"

# Fetch API key from Key Vault
export ELEVENLABS_API_KEY=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "$SECRET_NAME" --query value -o tsv 2>/dev/null)

if [ -z "$ELEVENLABS_API_KEY" ]; then
    echo "ERROR: Failed to fetch ElevenLabs API key from Key Vault" >&2
    exit 1
fi

# Launch the MCP server
exec node /home/odedbe/.claude/mcp-servers/elevenlabs-creative/dist/index.js
