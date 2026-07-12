#!/bin/sh
# waybar custom/battery
# Native rewrite of /usr/libexec/i3blocks/battery (acpi-based) for waybar.
# Icon-only text (charge-level or charging glyph, no "DIS"/"CHR" wording);
# the time-remaining/time-to-full estimate lives in the tooltip instead.

bat_number="${BAT_NUMBER:-0}"

# mdi-battery-charging (Nerd Font)
charging_icon=$(printf '\357\226\203')
# mdi-battery-10 .. mdi-battery-100 (Nerd Font), lowest to highest charge
icons=$(printf '\357\225\270 \357\225\271 \357\225\272 \357\225\273 \357\225\274 \357\225\275 \357\225\276 \357\225\277 \357\226\200 \357\226\201')

line=$(acpi -b 2>/dev/null | grep "Battery $bat_number")
[ -z "$line" ] && exit 0

status=$(printf '%s' "$line" | sed -n 's/.*: \([A-Za-z ]*\), \([0-9]*\)%.*/\1/p')
percent=$(printf '%s' "$line" | sed -n 's/.*: \([A-Za-z ]*\), \([0-9]*\)%.*/\2/p')
[ -z "$percent" ] && exit 0

charging=false
case "$status" in
    Charging) charging=true ;;
    Unknown)
        ac=$(acpi -a 2>/dev/null | sed -n 's/.*: \([a-z-]*\)/\1/p')
        [ "$ac" = "on-line" ] && charging=true
        ;;
esac

if [ "$charging" = true ]; then
    icon="$charging_icon"
else
    idx=$((percent / 10))
    [ "$idx" -gt 9 ] && idx=9
    icon=$(printf '%s' "$icons" | tr ' ' '\n' | sed -n "$((idx + 1))p")
fi

text="$icon $percent%"

time=$(printf '%s' "$line" | sed -n 's/.*, \([0-9][0-9]:[0-9][0-9]\):.*/\1/p')
if [ -n "$time" ]; then
    if [ "$charging" = true ]; then
        tooltip="Time to full: $time"
    else
        tooltip="Time remaining: $time"
    fi
else
    tooltip="$status"
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
