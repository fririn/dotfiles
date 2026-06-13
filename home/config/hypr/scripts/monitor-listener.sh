#!/bin/bash
handle() {
    case $1 in
        monitoradded*|monitorremoved*)
            ~/.config/hypr/scripts/monitor-setup.sh
            ;;
    esac
}

socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" \
    | while read -r line; do handle "$line"; done
