#!/usr/bin/env bash
# Launch a floating terminal at a random position on the focused monitor.

TERM_CMD="${1:-kitty}"
W_FRAC=40 # window width, % of monitor
H_FRAC=45 # window height, % of monitor

# Logical size of the focused monitor. width/height are the raw mode, so divide by the
# scale and swap them for 90°/270° transforms (odd values, e.g. the portrait DP-2).
read -r MW MH < <(hyprctl monitors -j | jq -r '.[] | select(.focused)
	| [(.width / .scale | floor), (.height / .scale | floor)] as $s
	| if .transform % 2 == 1 then $s | reverse else $s end
	| "\(.[0]) \(.[1])"')

W=$((MW * W_FRAC / 100))
H=$((MH * H_FRAC / 100))
X=$((RANDOM % (MW - W + 1))) # move is relative to the monitor
Y=$((RANDOM % (MH - H + 1)))

hyprctl dispatch "hl.dsp.exec_cmd('systemd-run --user --scope --slice=app.slice --collect --quiet -- $TERM_CMD', { float = true, size = '$W $H', move = '$X $Y' })" >/dev/null
