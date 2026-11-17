#!/usr/bin/env bash
# Launch a floating terminal at a random position on the focused monitor.
# mango port of ../../hypr/scripts/RandomTerminal.sh.
#
# Size and floating come from the window rule for app_id "kitty-random"
# (40% x 45%, centered); this script then nudges it by a random offset.

TERM_CMD="${1:-kitty}"
W_FRAC=40 # keep in sync with the window rule width
H_FRAC=45 # keep in sync with the window rule height

read -r MW MH < <(mmsg get all-monitors | jq -r '.monitors[] | select(.active) | "\(.width) \(.height)"')

W=$((MW * W_FRAC / 100))
H=$((MH * H_FRAC / 100))
# The window opens centered, so the free range is +/- half the leftover space.
DX=$((RANDOM % (MW - W + 1) - (MW - W) / 2))
DY=$((RANDOM % (MH - H + 1) - (MH - H) / 2))

systemd-run --user --scope --slice=app.slice --collect --quiet -- \
	"$TERM_CMD" --class kitty-random &
pid=$!

for _ in $(seq 50); do # ~5s
	id=$(mmsg get all-clients | jq -r --argjson pid "$pid" '.clients[] | select(.pid == $pid) | .id' | head -n1)
	if [[ -n $id ]]; then
		mmsg dispatch "movewin,$(printf '%+d,%+d' "$DX" "$DY")" "client,$id"
		exit 0
	fi
	sleep 0.1
done
