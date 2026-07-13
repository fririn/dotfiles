#!/bin/sh
# waybar custom/volume
# Native rewrite of ~/.config/i3blocks/scripts/volume for waybar.
#
# Usage:
#   volume.sh             print current status as waybar JSON (default)
#   volume.sh mute         toggle mute
#   volume.sh up|down      step volume +/-5%
#   volume.sh cycle-sink   move audio to the next available sink

refresh() { pkill -RTMIN+10 waybar; }

case "$1" in
    mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        refresh
        exit 0
        ;;
    up)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        refresh
        exit 0
        ;;
    down)
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        refresh
        exit 0
        ;;
    cycle-sink)
        current=$(pactl get-default-sink)
        next=$(pactl -f json list sinks \
            | jq -r '.[] | select(.ports[0].availability != "not available") | .name' \
            | awk -v cur="$current" '
                { names[NR] = $0; if ($0 == cur) idx = NR }
                END { n = NR; if (idx == "") idx = 0; print names[(idx % n) + 1] }
            ')
        [ -n "$next" ] && pactl set-default-sink "$next"
        pactl list short sink-inputs | cut -f1 | while read -r id; do
            pactl move-sink-input "$id" "$next" 2>/dev/null
        done
        refresh
        exit 0
        ;;
esac

set -- $(wpctl get-volume @DEFAULT_AUDIO_SINK@)
vol=$2
mute=$3
sink=$(pactl get-default-sink)

label=$(printf '%s' "$sink" | sed -n 's/.*__\(.*\)__sink$/\1/p')
if [ -z "$label" ]; then
    desc=$(pactl -f json list sinks | jq -r --arg n "$sink" '.[] | select(.name==$n) | .description')
    max=16
    if [ "${#desc}" -gt "$max" ]; then
        label=$(printf '%s' "$desc" | cut -c1-$((max - 1)))…
    else
        label=$desc
    fi
fi

# fa-headphones / fa-volume-up (Nerd Font, Font Awesome 4 PUA range)
headphones_icon=$(printf '\357\200\245')
speaker_icon=$(printf '\357\200\250')

case "$label" in
    *[Hh]eadphone*|*[Hh]eadset*) label="$headphones_icon" ;;
    *[Ss]peaker*)                label="$speaker_icon" ;;
esac

pct=$(echo "$vol * 100" | bc | cut -d. -f1)

if echo "$mute" | grep -q MUTED; then
    printf '{"text":"muted %s ","class":"muted"}\n' "$label"
else
    printf '{"text":"%s%% %s ","class":"unmuted"}\n' "$pct" "$label"
fi
