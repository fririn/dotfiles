#!/bin/sh
# waybar custom/ethernet
# Native rewrite of ~/.config/i3blocks/scripts/ethernet for waybar.
# Mirrors i3status's `ethernet` block: "E: ip (speed)"

IF=$(for f in /sys/class/net/*; do
    d=$(basename "$f")
    case "$d" in lo|wl*|ww*) continue ;; esac
    [ -d "$f/wireless" ] && continue
    echo "$d"
    break
done)
[ -z "$IF" ] && exit 0

if [ "$(cat "/sys/class/net/$IF/operstate" 2>/dev/null)" != "up" ]; then
    printf '{"text":"E: down","class":"down"}\n'
    exit 0
fi

IP=$(ip -4 addr show "$IF" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)
SPEED=$(ethtool "$IF" 2>/dev/null | awk -F': ' '/Speed:/{print $2}')

printf '{"text":"E: %s (%s)","tooltip":"%s","class":"up"}\n' "$IP" "$SPEED" "$IF"
