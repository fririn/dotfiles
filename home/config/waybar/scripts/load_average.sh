#!/bin/sh
# waybar custom/load_average
# Native rewrite of ~/.config/i3blocks/scripts/la for waybar.

load="$(cut -d ' ' -f1 /proc/loadavg)"
cpus="$(nproc)"

load_i=$(printf '%s' "$load" | tr -d '.')
half=$((cpus * 100 / 2))
full=$((cpus * 100))

class="normal"
if [ "$load_i" -ge "$full" ]; then
    class="critical"
elif [ "$load_i" -ge "$half" ]; then
    class="warning"
fi

printf '{"text":"%s","tooltip":"%s cores","class":"%s"}\n' "$load" "$cpus" "$class"
