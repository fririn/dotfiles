#!/usr/bin/env bash
# Show active wifi SSID or wired indicator
WIFI="$(networksetup -getairportnetwork en0 2>/dev/null | awk -F': ' '{print $2}')"

if [ -n "$WIFI" ] && [ "$WIFI" != "You are not associated with an AirPort network." ]; then
  sketchybar --set "$NAME" label="$WIFI" icon="󰖩"
else
  # Check for wired
  if ipconfig getifaddr en1 &>/dev/null || ipconfig getifaddr en2 &>/dev/null; then
    sketchybar --set "$NAME" label="Wired" icon="󰈀"
  else
    sketchybar --set "$NAME" label="Off" icon="󰖪" icon.color=0xfff38ba8
  fi
fi
