#!/bin/sh
# Toggle the special:terminal workspace: jump to it, or if already focused,
# return to whichever workspace was focused before (scoped alternative to
# the global workspace_auto_back_and_forth option).

special="terminal"
current=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')

if [ "$current" = "$special" ]; then
    swaymsg workspace back_and_forth
else
    swaymsg workspace "$special"
fi
