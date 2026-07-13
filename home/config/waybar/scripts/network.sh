#!/bin/sh
# waybar custom/network
# Combines ~/.config/i3blocks/scripts/wireless and .../ethernet into one
# waybar module: show whichever interface is actually connected, preferring
# a wired link over Wi-Fi when both are up.

ETH_IF=$(for f in /sys/class/net/*; do
    d=$(basename "$f")
    case "$d" in lo|wl*|ww*) continue ;; esac
    [ -d "$f/wireless" ] && continue
    echo "$d"
    break
done)

if [ -n "$ETH_IF" ] && [ "$(cat "/sys/class/net/$ETH_IF/operstate" 2>/dev/null)" = "up" ]; then
    IP=$(ip -4 addr show "$ETH_IF" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)
    if [ -n "$IP" ]; then
        SPEED=$(ethtool "$ETH_IF" 2>/dev/null | awk -F': ' '/Speed:/{print $2}')
        printf '{"text":"E: %s (%s)","tooltip":"%s","class":"up"}\n' "$IP" "$SPEED" "$ETH_IF"
        exit 0
    fi
fi

WIFI_IF=$(for f in /sys/class/net/*/wireless; do basename "${f%/wireless}"; break; done)

if [ -n "$WIFI_IF" ]; then
    IP=$(ip -4 addr show "$WIFI_IF" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)
    if [ -n "$IP" ]; then
        LINK=$(iw dev "$WIFI_IF" link 2>/dev/null)
        ESSID=$(echo "$LINK" | awk -F'SSID: ' '/SSID:/{print $2}')
        DBM=$(echo "$LINK" | awk '/signal:/{print $2}')
        QUALITY=$(awk -v d="$DBM" 'BEGIN { q = (d+100)*2; if (q>100) q=100; if (q<0) q=0; printf "%d", q }')
        printf '{"text":"%s","tooltip":"Signal: %s%%\\nIP: %s","class":"up"}\n' "$ESSID" "$QUALITY" "$IP"
        exit 0
    fi
fi

[ -z "$ETH_IF" ] && [ -z "$WIFI_IF" ] && exit 0

printf '{"text":"down","class":"down"}\n'
