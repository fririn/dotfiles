#!/bin/bash

# 1. Grant permission (safe to run repeatedly)
xhost +si:localuser:root >/dev/null 2>&1

# 2. Define the command wrapper to run nvidia-settings as root
NVS="sudo -E bash -c 'export DISPLAY=:0; nvidia-settings'"

# 3. Enable Fan Control
eval "sudo -E bash -c 'export DISPLAY=:0; nvidia-settings [gpu:0]/GPUFanControlState=1'"

while true; do
  # Get GPU Temp
  TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)

  # Basic Logic
  if [ "$TEMP" -ge 85 ]; then
    SPEED=100
  elif [ "$TEMP" -ge 80 ]; then
    SPEED=80
  elif [ "$TEMP" -ge 70 ]; then
    SPEED=60
  else
    SPEED=40
  fi

  # Apply Speed
  eval "sudo -E bash -c 'export DISPLAY=:0; nvidia-settings [fan:0]/GPUTargetFanSpeed=$SPEED'"

  sleep 5
done
