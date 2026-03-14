#!/usr/bin/env bash
# SketchyBar workspace item — 3-state colouring matching Hyprland waybar style:
#   focused   → bright digit + rounded filled background + border
#   occupied  → bright digit, no background
#   empty     → dim digit, no background

WORKSPACE_ID="$1"

# ── Catppuccin Mocha ──────────────────────────────────────────────────────────
FOCUSED_BG=0x55313244      # surface0, semi-transparent fill
FOCUSED_BORDER=0xff89b4fa  # blue
FOCUSED_FG=0xff89b4fa      # blue

OCCUPIED_FG=0xffcdd6f4     # text (full bright)

EMPTY_FG=0xff45475a        # surface1 (dim/muted)

# ── Check if workspace has any windows ───────────────────────────────────────
# aerospace list-windows exits 0 even on empty workspace, so count lines
WINDOW_COUNT=$(aerospace list-windows --workspace "$WORKSPACE_ID" 2>/dev/null | wc -l | tr -d ' ')

# ── Apply state ───────────────────────────────────────────────────────────────
if [ "$AEROSPACE_FOCUSED_WORKSPACE" = "$WORKSPACE_ID" ]; then
  # ── FOCUSED: bright + filled rounded pill + blue border ───────────────────
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=$FOCUSED_BG \
    background.border_color=$FOCUSED_BORDER \
    background.border_width=1.5 \
    background.corner_radius=5 \
    label.color=$FOCUSED_FG

elif [ "$WINDOW_COUNT" -gt 0 ]; then
  # ── OCCUPIED: bright, no background ───────────────────────────────────────
  sketchybar --set "$NAME" \
    background.drawing=off \
    background.border_width=0 \
    label.color=$OCCUPIED_FG

else
  # ── EMPTY: muted/dim, no background ──────────────────────────────────────
  sketchybar --set "$NAME" \
    background.drawing=off \
    background.border_width=0 \
    label.color=$EMPTY_FG
fi
