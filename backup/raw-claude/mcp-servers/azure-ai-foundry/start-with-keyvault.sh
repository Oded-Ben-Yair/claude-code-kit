#!/bin/bash
# Azure AI Foundry MCP Server Launcher
# Fetches API key from Key Vault at startup for secure credential management

set -e

# Key Vault configuration
VAULT_NAME="kv-seekapa-apps"
SECRET_NAME="AzureAIFoundry-ApiKey"

# Fetch API key from Key Vault
export AZURE_OPENAI_KEY=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "$SECRET_NAME" --query value -o tsv 2>/dev/null)

if [ -z "$AZURE_OPENAI_KEY" ]; then
    echo "ERROR: Failed to fetch API key from Key Vault" >&2
    exit 1
fi

# Set endpoint (cognitiveservices endpoint for newer models)
export AZURE_OPENAI_ENDPOINT="https://brn-azai.cognitiveservices.azure.com/"

# Launch the MCP server
exec node /home/odedbe/.claude/mcp-servers/azure-ai-foundry/index.js
