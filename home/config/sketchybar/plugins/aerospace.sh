#!/usr/bin/env bash
# Highlight active AeroSpace workspace in SketchyBar

WORKSPACE_ID="$1"
BLUE=0xff89b4fa
SURFACE0=0xff313244
TEXT=0xffcdd6f4
SUBTEXT=0xffa6adc8

if [ "$AEROSPACE_FOCUSED_WORKSPACE" = "$WORKSPACE_ID" ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=$SURFACE0 \
    label.color=$BLUE
else
  sketchybar --set "$NAME" \
    background.drawing=off \
    label.color=$SUBTEXT
fi
