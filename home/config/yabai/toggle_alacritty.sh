#!/bin/bash

# 1. Find the window ID for "quickterm"
QT_ID=$(yabai -m query --windows | jq -r '.[] | select(.title == "quickterm") | .id')

# 2. If it doesn't exist, launch it and exit
if [ -z "$QT_ID" ]; then
    # We use your specific launch command
     yabai -m rule --add --one-shot app="^Alacritty$" manage=off grid=1:1:0:0:1:1; /Applications/Alacritty.app/Contents/MacOS/alacritty --title "quickterm" --config-file ~/.config/alacritty/alacritty_quickterminal.toml &

    exit 0
fi

# 3. Get current state info
FOCUSED_ID=$(yabai -m query --windows --window | jq -r '.id')
CURRENT_SPACE=$(yabai -m query --spaces --space | jq -r '.index')

# 4. Logic: Toggle Visibility
if [ "$QT_ID" = "$FOCUSED_ID" ]; then
    # It's focused, so "Hide" it by moving it to Space 10 (our junk space)
    yabai -m window "$QT_ID" --space 9
else
    # It's hidden, so bring it to the current space and focus
    yabai -m window "$QT_ID" --space "$CURRENT_SPACE"
    yabai -m window "$QT_ID" --grid 1:1:0:0:1:1
    yabai -m window "$QT_ID" --focus
fi
