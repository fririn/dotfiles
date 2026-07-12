#!/bin/sh
# waybar custom/powerprofile
# Native rewrite of ~/.config/i3blocks/scripts/powerprofile for waybar.
#
# Usage:
#   powerprofile.sh        print current profile as waybar JSON (default)
#   powerprofile.sh cycle  cycle power-saver -> balanced -> performance

get_profile() {
    tlp-stat -s | awk -F'= ' '/TLP profile/ {print $2}' | cut -d/ -f1
}

if [ "$1" = "cycle" ]; then
    current=$(get_profile)
    case "$current" in
        power-saver) sudo tlp balanced >/dev/null ;;
        balanced)    sudo tlp performance >/dev/null ;;
        performance) sudo tlp power-saver >/dev/null ;;
        *)           sudo tlp balanced >/dev/null ;;
    esac
    pkill -RTMIN+11 waybar
    exit 0
fi

profile=$(get_profile)

case "$profile" in
    power-saver) class="eco";     label="eco"     ;;
    balanced)    class="bal";     label="bal"     ;;
    performance) class="perf";    label="perf"    ;;
    *)           class="unknown"; label="$profile" ;;
esac

printf '{"text":"%s","class":"%s"}\n' "$label" "$class"
