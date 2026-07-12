#!/bin/sh
# waybar custom/tailscale
# Native rewrite of the [tailscale] block from ~/.config/i3blocks/config.

command -v tailscale >/dev/null 2>&1 || exit 0

J=$(tailscale status --json 2>/dev/null)
STATE=$(echo "$J" | jq -r '.BackendState')

if [ "$STATE" != "Running" ]; then
    printf '{"text":"tailscale down","class":"down"}\n'
    exit 0
fi

EXIT=$(echo "$J" | jq -r '[.Peer[]? | select(.ExitNode==true) | .HostName][0] // empty')
[ -z "$EXIT" ] && exit 0

printf '{"text":"Exit: %s","class":"exit"}\n' "$EXIT"
