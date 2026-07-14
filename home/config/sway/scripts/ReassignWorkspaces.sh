#!/bin/sh
# Re-pin every workspace to the first currently-active output in its
# preference list (mirrors the "workspace N output ..." lines in the sway
# config). Those config lines only apply when a workspace is *created*, so
# on monitor connect/disconnect existing workspaces don't move on their own
# -- this script forces that move. Safe to call any time (e.g. from a
# swaymsg -t subscribe -m '["output"]' watcher).

set -eu

# Keep in sync with the "workspace N output ..." lines in ../config.
workspaces="1 2 3 4 5 6 7 8 9 10 11 terminal"
outputs_for() {
    case "$1" in
        1|2|3|4|5|6|7|8) echo "DP-1 HDMI-A-1 eDP-1" ;;
        9|10)            echo "eDP-1 DP-1" ;;
        11)              echo "HDMI-A-1 eDP-1 DP-1" ;;
        terminal)        echo "DP-1 HDMI-A-1 eDP-1" ;;
    esac
}

active_outputs=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name')
current_focused=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')

for ws in $workspaces; do
    for out in $(outputs_for "$ws"); do
        if printf '%s\n' "$active_outputs" | grep -qx "$out"; then
            swaymsg "workspace $([ "$ws" = terminal ] && echo "$ws" || echo "number $ws"); move workspace to output $out" >/dev/null
            break
        fi
    done
done

[ -n "$current_focused" ] && swaymsg "workspace $([ "$current_focused" = terminal ] && echo "$current_focused" || echo "number $current_focused")" >/dev/null
