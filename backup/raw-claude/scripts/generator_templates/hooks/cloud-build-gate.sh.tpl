#!/usr/bin/env bash
# cloud-build-gate.sh — PreToolUse hook
# Blocks premature verification after Cloud Build trigger.
# Enforces Rule 6: NO verifying before pipeline completes.
#
# Event: PreToolUse (Bash)
# When: Detects curl/gcloud commands targeting production URLs
#        within 120 seconds of a Cloud Build trigger.

set -euo pipefail

GATE_FILE="/tmp/.cloud-build-gate"
GATE_TIMEOUT=120  # seconds

# Check if we're in a gate period
if [ -f "$$GATE_FILE" ]; then
    gate_time=$$(cat "$$GATE_FILE")
    now=$$(date +%s)
    elapsed=$$((now - gate_time))

    if [ "$$elapsed" -lt "$$GATE_TIMEOUT" ]; then
        # Check if the command looks like a verification attempt
        TOOL_INPUT="$${TOOL_INPUT:-}"
        if echo "$$TOOL_INPUT" | grep -qiE "(curl.*run\.app|gcloud run services describe|health|status)"; then
            echo "BLOCKED: Cloud Build triggered $$elapsed seconds ago. Wait $$((GATE_TIMEOUT - elapsed))s before verifying."
            echo "Reason: Verification before pipeline completes shows PRE-deployment state."
            exit 1
        fi
    else
        # Gate expired, clean up
        rm -f "$$GATE_FILE"
    fi
fi

# Detect Cloud Build triggers (gcloud builds submit, git push)
TOOL_INPUT="$${TOOL_INPUT:-}"
if echo "$$TOOL_INPUT" | grep -qiE "(gcloud builds submit|gcloud run deploy|git push)"; then
    date +%s > "$$GATE_FILE"
fi

exit 0
