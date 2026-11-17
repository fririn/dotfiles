#!/usr/bin/env bash
# Toggle the kitty-scratch named scratchpad, always shown fullscreen.
#
# - No kitty-scratch window: launches kitty attached to the tmux session
#   "scratch" (created if missing), so closing kitty keeps your tmux state.
# - mango's show_scratchpad() always clears fullscreen when a scratchpad is
#   shown (a window rule can't prevent it), so we re-apply it after each show.

APP_ID="kitty-scratch"
TERM_CMD="${1:-kitty}"
SESSION="scratch"
LAUNCH="systemd-run --user --scope --slice=app.slice --collect --quiet -- $TERM_CMD --class $APP_ID -e tmux new-session -A -s $SESSION"

scratch() {
	mmsg get all-clients | jq -r --arg a "$APP_ID" \
		'.clients[] | select(.appid == $a) | "\(.id) \(.is_visible) \(.is_fullscreen)"' | head -n1
}

read -r id visible _ < <(scratch)

# Visible -> hide. mango's togglefullscreen drops the window out of the
# scratchpad, so toggle_named_scratchpad would re-show it instead of hiding.
# "minimized" hides it and puts it back into the scratchpad.
if [[ -n $id && $visible == true ]]; then
	mmsg dispatch minimized "client,$id" >/dev/null
	exit 0
fi

mmsg dispatch "toggle_named_scratchpad,$APP_ID,none,$LAUNCH" >/dev/null

# Shown (or launching): wait until it's visible, then make it fullscreen.
for _ in $(seq 50); do # ~5s, covers a fresh kitty launch
	read -r id visible fullscreen < <(scratch)
	if [[ -n $id && $visible == true ]]; then
		[[ $fullscreen != true ]] && mmsg dispatch togglefullscreen "client,$id" >/dev/null
		exit 0
	fi
	sleep 0.1
done
