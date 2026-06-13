#!/usr/bin/env bash
# Must be sourced to update HYPRLAND_INSTANCE_SIGNATURE in the current shell:
#   source ~/.config/hypr/scripts/fix-hypr-sig.sh
# Or run directly to execute a hyprctl command with the correct instance:
#   ~/.config/hypr/scripts/fix-hypr-sig.sh hyprctl devices

_sig=$(ls -t /run/user/${UID}/hypr/ 2>/dev/null | head -1)

if [[ -z "$_sig" ]]; then
    echo "fix-hypr-sig: no Hyprland instances found in /run/user/${UID}/hypr/" >&2
    return 1 2>/dev/null || exit 1
fi

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced — update the caller's env
    export HYPRLAND_INSTANCE_SIGNATURE="$_sig"
    echo "HYPRLAND_INSTANCE_SIGNATURE set to: $_sig"
else
    # Running directly — exec the given command with the correct env, or just print
    if [[ $# -gt 0 ]]; then
        HYPRLAND_INSTANCE_SIGNATURE="$_sig" "$@"
    else
        echo "$_sig"
    fi
fi
