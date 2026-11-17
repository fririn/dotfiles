#!/usr/bin/env bash
# Area screenshot with the screen frozen the moment the key is pressed, then
# edited in swappy. Same mechanism as `grimblast --freeze` (which needs hyprctl):
# hyprpicker -r draws a still frame of every output on an overlay layer, slurp
# selects on top of it, grim captures the (frozen) region.

dir="$HOME/Pictures/Screenshots/Clipboard"
mkdir -p "$dir"

hyprpicker -r -z &
freeze=$!
tmp=$(mktemp --suffix=.png)
trap 'kill "$freeze" 2>/dev/null; rm -f "$tmp"' EXIT
sleep 0.2 # let the freeze overlay map before slurp draws over it (grimblast does the same)

geom=$(slurp) || exit 0 # Escape cancels
grim -g "$geom" "$tmp" || exit 1

# Unfreeze before swappy opens, or its window would sit under the overlay.
kill "$freeze" 2>/dev/null

out="$dir/$(date +%Y%m%d-%H:%M:%S).png"
cp "$tmp" "$out"
swappy -f "$out"
