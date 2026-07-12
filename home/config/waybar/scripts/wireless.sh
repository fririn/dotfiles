#!/bin/sh
# waybar custom/wireless
# Native rewrite of ~/.config/i3blocks/scripts/wireless for waybar.
# Mirrors i3status's `wireless` block: "W: (quality% at essid) ip"

IF=$(for f in /sys/class/net/*/wireless; do basename "${f%/wireless}"; break; done)
[ -z "$IF" ] && exit 0

IP=$(ip -4 addr show "$IF" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)
if [ -z "$IP" ]; then
    printf '{"text":"W: down","class":"down"}\n'
    exit 0
fi

LINK=$(iw dev "$IF" link 2>/dev/null)
ESSID=$(echo "$LINK" | awk -F'SSID: ' '/SSID:/{print $2}')
DBM=$(echo "$LINK" | awk '/signal:/{print $2}')
QUALITY=$(awk -v d="$DBM" 'BEGIN { q = (d+100)*2; if (q>100) q=100; if (q<0) q=0; printf "%d", q }')

printf '{"text":"W: (%s%% at %s) %s","tooltip":"%s","class":"up"}\n' "$QUALITY" "$ESSID" "$IP" "$IF"
