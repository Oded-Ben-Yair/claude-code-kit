#!/usr/bin/env bash
# gcp-adc-check.sh — PreToolUse hook
# Verifies GCP Application Default Credentials are valid before gcloud commands.
#
# Event: PreToolUse (Bash)
# When: Detects gcloud or gsutil commands that require authentication.

set -euo pipefail

TOOL_INPUT="$${TOOL_INPUT:-}"

# Only check for gcloud/gsutil commands (not gcloud config or gcloud version)
if echo "$$TOOL_INPUT" | grep -qiE "^(gcloud (run|builds|logging|secrets|projects|compute|sql|functions)|gsutil)" ; then
    # Skip info-only commands
    if echo "$$TOOL_INPUT" | grep -qiE "(--version|config list|config get|info)"; then
        exit 0
    fi

    # Verify ADC token is available
    if ! gcloud auth application-default print-access-token &>/dev/null 2>&1; then
        echo "WARNING: GCP Application Default Credentials not configured or expired."
        echo "Run: gcloud auth application-default login"
        echo ""
        echo "Proceeding anyway -- the gcloud command may fail with auth errors."
        # Don't block, just warn. The actual command will fail with a clear error.
    fi
fi

exit 0
