#!/usr/bin/env sh
echo killing polybar
# Terminate already running bar instances
killall -q polybar

echo waiting 
# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

echo launching  
# Launch fullbar
polybar main &
echo launched
