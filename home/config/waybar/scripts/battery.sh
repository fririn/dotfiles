#!/bin/sh
# waybar custom/battery
# Native rewrite of /usr/libexec/i3blocks/battery (acpi-based) for waybar.
# Icon-only text (charge-level or charging glyph, no "DIS"/"CHR" wording);
# the time-remaining/time-to-full estimate lives in the tooltip instead.

bat_number="${BAT_NUMBER:-0}"

# fa-bolt (Nerd Font, Font Awesome 4 PUA range — confirmed present in the
# installed JetBrainsMono Nerd Font; the mdi range used previously was not)
charging_icon=$(printf '\357\203\247')
# fa-battery-empty .. fa-battery-full, lowest to highest charge
icons=$(printf '\357\211\204 \357\211\203 \357\211\202 \357\211\201 \357\211\200')

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
    if   [ "$percent" -lt 20 ]; then idx=1
    elif [ "$percent" -lt 40 ]; then idx=2
    elif [ "$percent" -lt 60 ]; then idx=3
    elif [ "$percent" -lt 85 ]; then idx=4
    else idx=5
    fi
    icon=$(printf '%s' "$icons" | tr ' ' '\n' | sed -n "${idx}p")
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
