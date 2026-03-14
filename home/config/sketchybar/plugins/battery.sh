#!/usr/bin/env bash
PERCENTAGE="$(pmset -g batt | grep -Eo '\d+%' | head -1 | tr -d '%')"
CHARGING="$(pmset -g batt | grep 'AC Power')"

GREEN=0xffa6e3a1
YELLOW=0xfff9e2af
RED=0xfff38ba8
BLUE=0xff89b4fa

if [ "$PERCENTAGE" = "" ]; then
  sketchybar --set "$NAME" label="?" icon="󰂑"
  exit 0
fi

if [ -n "$CHARGING" ]; then
  ICON="󰂄"
  COLOR=$BLUE
elif [ "$PERCENTAGE" -ge 70 ]; then
  ICON="󰁹"
  COLOR=$GREEN
elif [ "$PERCENTAGE" -ge 40 ]; then
  ICON="󰁾"
  COLOR=$YELLOW
elif [ "$PERCENTAGE" -ge 20 ]; then
  ICON="󰁼"
  COLOR=$YELLOW
else
  ICON="󰁺"
  COLOR=$RED
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
