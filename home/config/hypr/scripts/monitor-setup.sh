#!/bin/bash

for i in $(seq 1 20); do
    hyprctl monitors | grep -q "^Monitor DP-1" && break
    sleep 0.5
done

if hyprctl monitors | grep -q "^Monitor DP-1"; then
    for i in $(seq 1 10); do
        hyprctl keyword workspace "$i, monitor:DP-1, persistent:true"
    done
    hyprctl keyword workspace "11, monitor:eDP-1, persistent:true"
    hyprctl keyword workspace "12, monitor:eDP-1, persistent:true"
    hyprctl dispatch focusmonitor DP-1
else
    for i in $(seq 1 12); do
        hyprctl keyword workspace "$i, monitor:eDP-1, persistent:true"
    done
fi
