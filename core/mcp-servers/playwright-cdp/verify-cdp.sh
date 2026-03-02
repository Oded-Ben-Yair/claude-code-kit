#!/bin/bash
# Verify CDP connection to Windows Edge
# Returns exit 0 if connected, exit 1 if not

WIN_HOST=$(ip route show | grep -i default | awk '{print $3}')

echo "=== CDP Connection Verification ==="
echo "Windows Host IP: $WIN_HOST"
echo ""

# Test CDP endpoint
if response=$(curl -s --connect-timeout 3 "http://${WIN_HOST}:9222/json/version" 2>&1); then
    browser=$(echo "$response" | grep -o '"Browser":"[^"]*"' | cut -d'"' -f4)
    if [[ "$browser" == *"Edge"* ]]; then
        echo "CONNECTED to Microsoft Edge via CDP"
        echo "Browser: $browser"
        echo ""

        # List open tabs
        echo "Open tabs:"
        curl -s "http://${WIN_HOST}:9222/json/list" 2>/dev/null | grep -o '"title":"[^"]*"' | head -5 | while read line; do
            title=$(echo "$line" | cut -d'"' -f4)
            echo "  - $title"
        done
        exit 0
    else
        echo "WARNING: Connected but browser is NOT Edge: $browser"
        exit 1
    fi
else
    echo "NOT CONNECTED"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Run setup-windows.ps1 as Administrator on Windows"
    echo "2. Double-click Edge-CDP.bat on Windows Desktop"
    echo "3. Verify Edge is running with: Get-Process msedge"
    echo "4. Check firewall allows port 9222"
    echo "5. Check netsh portproxy: netsh interface portproxy show all"
    exit 1
fi
