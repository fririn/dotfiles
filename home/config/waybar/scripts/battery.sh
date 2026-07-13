#!/bin/sh
# waybar custom/battery
# Native rewrite of /usr/libexec/i3blocks/battery for waybar.
# Reads /sys/class/power_supply directly (the previous acpi-based version
# silently printed nothing when the acpi tool wasn't installed).
# Icon-only text (charge-level or charging glyph, no "DIS"/"CHR" wording);
# the time-remaining/time-to-full estimate lives in the tooltip instead.

bat_number="${BAT_NUMBER:-0}"
bat="/sys/class/power_supply/BAT$bat_number"

[ -d "$bat" ] || exit 0

# fa-bolt (Nerd Font, Font Awesome 4 PUA range — confirmed present in the
# installed JetBrainsMono Nerd Font; the mdi range used previously was not)
charging_icon=$(printf '\357\203\247')
# fa-battery-empty .. fa-battery-full, lowest to highest charge
icons=$(printf '\357\211\204 \357\211\203 \357\211\202 \357\211\201 \357\211\200')

status=$(cat "$bat/status" 2>/dev/null)
percent=$(cat "$bat/capacity" 2>/dev/null)
[ -z "$percent" ] && exit 0

charging=false
case "$status" in
    Charging) charging=true ;;
    Unknown)
        # AC adapter name varies by machine (AC, ACAD, ADP1, ...), so find it
        # by type instead of by name.
        for psu in /sys/class/power_supply/*/; do
            [ "$(cat "$psu/type" 2>/dev/null)" = "Mains" ] || continue
            [ "$(cat "$psu/online" 2>/dev/null)" = "1" ] && charging=true && break
        done
        ;;
esac

if [ "$charging" = true ]; then
    icon="$charging_icon"
else
    if   [ "$percent" -lt 20 ]; then idx=1
    elif [ "$percent" -lt 40 ]; then idx=2
    elif [ "$percent" -lt 60 ]; then idx=3
    elif [ "$percent" -lt 85 ]; then idx=4
    else idx=5
    fi
    icon=$(printf '%s' "$icons" | tr ' ' '\n' | sed -n "${idx}p")
fi

text="$icon $percent%"

# Time estimate from energy/power counters (µWh / µW). Batteries that expose
# charge_now/current_now instead work the same way since the units cancel.
now=$(cat "$bat/energy_now" 2>/dev/null || cat "$bat/charge_now" 2>/dev/null)
full=$(cat "$bat/energy_full" 2>/dev/null || cat "$bat/charge_full" 2>/dev/null)
rate=$(cat "$bat/power_now" 2>/dev/null || cat "$bat/current_now" 2>/dev/null)

tooltip="$status"
if [ -n "$now" ] && [ -n "$rate" ] && [ "$rate" -gt 0 ] 2>/dev/null; then
    mins=""
    if [ "$charging" = true ] && [ -n "$full" ]; then
        mins=$(( (full - now) * 60 / rate ))
        label="Time to full"
    elif [ "$status" = "Discharging" ]; then
        mins=$(( now * 60 / rate ))
        label="Time remaining"
    fi
    if [ -n "$mins" ] && [ "$mins" -ge 0 ]; then
        tooltip=$(printf '%s: %02d:%02d' "$label" $((mins / 60)) $((mins % 60)))
    fi
fi

if [ "$charging" = true ]; then
    class="charging"
else
    class="normal"
    if [ "$status" = "Discharging" ]; then
        if   [ "$percent" -lt 5 ];  then class="critical"
        elif [ "$percent" -lt 20 ]; then class="urgent"
        elif [ "$percent" -lt 40 ]; then class="low"
        elif [ "$percent" -lt 60 ]; then class="medium"
        elif [ "$percent" -lt 85 ]; then class="good"
        fi
    fi
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class"
