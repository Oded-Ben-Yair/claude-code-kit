#!/bin/bash
# Claude Code Notification Hook
# Sends desktop notification when Claude needs user input
# Uses notify-send (Linux native)

TITLE="Claude Code"
MESSAGE="${1:-Awaiting your input}"
URGENCY="${2:-normal}"  # low, normal, critical

# Check if notify-send is available
if command -v notify-send &> /dev/null; then
    notify-send -u "$URGENCY" "$TITLE" "$MESSAGE"

    # Also play a sound if paplay is available (PulseAudio)
    if command -v paplay &> /dev/null; then
        # Try to play a notification sound
        for sound in "/usr/share/sounds/freedesktop/stereo/message.oga" \
                     "/usr/share/sounds/ubuntu/stereo/message.ogg" \
                     "/usr/share/sounds/gnome/default/alerts/drip.ogg"; do
            if [ -f "$sound" ]; then
                paplay "$sound" 2>/dev/null &
                break
            fi
        done
    fi
else
    # Fallback: write to stderr (will be visible in terminal)
    echo "[NOTIFICATION] $TITLE: $MESSAGE" >&2
fi

exit 0
