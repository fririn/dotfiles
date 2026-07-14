#!/bin/sh
# Watch for monitor connect/disconnect/mode-change events and re-pin
# workspaces to their configured outputs (see ReassignWorkspaces.sh).
# Started once at sway startup via `exec` in ../config.

dir="$(dirname "$0")"

swaymsg -t subscribe -m '["output"]' | while read -r _line; do
    # Hotplug can fire several output events in a burst; wait for it to
    # settle before re-pinning so we don't do it N times in a row.
    sleep 1
    "$dir/ReassignWorkspaces.sh"
done
