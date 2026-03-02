#!/usr/bin/env bash
# Launch multi-provider-ai MCP server with GCP Application Default Credentials
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Verify ADC is configured
if ! gcloud auth application-default print-access-token &>/dev/null; then
    echo "ERROR: GCP ADC not configured. Run: gcloud auth application-default login" >&2
    exit 1
fi

# Load environment variables if .env exists
if [ -f "$SCRIPT_DIR/.env" ]; then
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
fi

# Verify required env vars
if [ -z "${GCP_PROJECT:-}" ]; then
    echo "ERROR: GCP_PROJECT not set. Set it in $SCRIPT_DIR/.env or environment." >&2
    exit 1
fi

exec python3 "$SCRIPT_DIR/server.py"
