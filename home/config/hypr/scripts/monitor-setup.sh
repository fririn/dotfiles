#!/bin/bash
# Workspace layout setup.
# eDP-1 is the built-in laptop screen and is always treated as secondary.
# The "primary" monitor is whatever external display is connected (DP-1,
# DP-3, HDMI-A-1, ...), so we never hardcode its name.

LAPTOP="DP-1"

# First connected monitor whose name is not the laptop panel.
get_external() {
    hyprctl monitors -j | jq -r --arg laptop "$LAPTOP" \
        'map(select(.name != $laptop)) | .[0].name // empty'
}

# Give an external monitor a moment to come up (e.g. on hotplug/startup).
external=""
for _ in $(seq 1 20); do
    external="$(get_external)"
    [ -n "$external" ] && break
    sleep 0.5
done

if [ -n "$external" ]; then
    for i in $(seq 1 10); do
        hyprctl keyword workspace "$i, monitor:$external, persistent:true"
    done
    hyprctl keyword workspace "11, monitor:$LAPTOP, persistent:true"
    hyprctl keyword workspace "12, monitor:$LAPTOP, persistent:true"
    hyprctl dispatch focusmonitor "$external"
else
    for i in $(seq 1 12); do
        hyprctl keyword workspace "$i, monitor:$LAPTOP, persistent:true"
    done
fi
