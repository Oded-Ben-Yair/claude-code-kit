#!/bin/bash
# Launch Edge with CDP (Chrome DevTools Protocol) for browser automation
# This allows Playwright to connect to your existing authenticated sessions

EDGE_PATH="/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
CDP_PORT=9222

# Check if Edge is already running with CDP
if curl -s "http://127.0.0.1:$CDP_PORT/json/version" > /dev/null 2>&1; then
    echo "Edge already running with CDP on port $CDP_PORT"
    curl -s "http://127.0.0.1:$CDP_PORT/json/version" | jq -r '.Browser'
    exit 0
fi

# Launch Edge with remote debugging
echo "Launching Edge with CDP on port $CDP_PORT..."
"$EDGE_PATH" --remote-debugging-port=$CDP_PORT &

# Wait for CDP to be available
echo "Waiting for CDP connection..."
for i in {1..10}; do
    if curl -s "http://127.0.0.1:$CDP_PORT/json/version" > /dev/null 2>&1; then
        echo "Edge CDP ready!"
        curl -s "http://127.0.0.1:$CDP_PORT/json/version" | jq -r '.Browser'
        exit 0
    fi
    sleep 1
done

echo "Failed to connect to Edge CDP after 10 seconds"
exit 1
