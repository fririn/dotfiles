#!/usr/bin/env bash
# Start apps and put each one's first window on a tag, without focusing it.
# Replaces Hyprland's `exec-once = [workspace N silent] cmd`.
#
# A window rule can't do this: both zen profiles share the app_id "zen", and
# rules would also keep forcing every later window of the app onto that tag.
# Instead each window is found by PID (falling back to a new window with the
# expected app_id) and moved with `tagsilent`.

run=(systemd-run --user --scope --slice=app.slice --collect --quiet --)
main_monitor=HDMI-A-1

clients() { mmsg get all-clients 2>/dev/null; }

# place <tag> <app_id regex> <cmd...>
place() {
	local tag=$1 appid=$2
	shift 2
	local before
	before=$(clients | jq -c '[.clients[].id]')
	"${run[@]}" "$@" &
	local pid=$! id
	for _ in $(seq 150); do # ~30s
		id=$(clients | jq -r --argjson pid "$pid" --arg re "$appid" --argjson before "${before:-[]}" '
			.clients[]
			| select(.pid == $pid or ((.appid // "" | test($re)) and (.id as $i | $before | index($i) | not)))
			| .id' | head -n1)
		if [[ -n $id ]]; then
			mmsg dispatch "tagsilent,$tag" "client,$id"
			return 0
		fi
		sleep 0.2
	done
	echo "autostart: no window for '$*' after 30s" >&2
}

mmsg dispatch "focusmon,$main_monitor"

# Sequential on purpose: the second zen must not be mistaken for the first.
place 1 '^zen' zen-browser --no-remote -P "work"
place 2 '^[Ss]lack$' slack
place 4 '^zen' zen-browser --no-remote -P "Default (release)"
place 5 '^org\.telegram\.desktop$' telegram-desktop
place 7 '^anki$' anki
place 9 '^[Ss]team$' steam
