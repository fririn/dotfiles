#!/usr/bin/env bash
# Launch a floating terminal at a random position on the focused monitor.

TERM_CMD="${1:-kitty}"
W_FRAC=40   # window width, % of monitor
H_FRAC=45   # window height, % of monitor

read -r MW MH < <(hyprctl monitors -j | jq -r '.[] | select(.focused) | "\((.width / .scale) | floor) \((.height / .scale) | floor)"')

W=$(( MW * W_FRAC / 100 ))
H=$(( MH * H_FRAC / 100 ))
X=$(( RANDOM % (MW - W + 1) ))   # move is relative to the monitor
Y=$(( RANDOM % (MH - H + 1) ))

# kitty asks to start maximized; suppress that so size/move apply
hyprctl dispatch "hl.dsp.exec_cmd('systemd-run --user --scope --slice=app.slice --collect --quiet -- $TERM_CMD', { float = true, suppress_event = 'maximize', size = '$W $H', move = '$X $Y' })" >/dev/null
