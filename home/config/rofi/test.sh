#!/bin/bash

DIR="$HOME/.config/rofi"
rofi_command="rofi -theme $DIR/themes/launcher.rasi -scroll-method 1 -no-lazy-grab -p ssh"

mapfile -t hosts < <(awk -F ':' '{print $1}' $DIR/hosts.txt)
mapfile -t commands < <(awk -F ':' '{print $2}' $DIR/hosts.txt)

#for i in "${!hosts[@]}"; do
#	hosts[$i]=$(echo -e "$(printf "%s" "${commands[$i]}" | cut -d'@' -f2 | cut -d' ' -f1)	\t${hosts[$i]}")
#	echo "${hosts[$i]} ${commands[$i]}"
#done

#chosen=$(printf "%s\n" "${hosts[@]}" | $rofi_command -dmenu )
#if [[ $chosen == "" ]]; then exit; fi
#
#chosen_command_index=1
#for i in "${!hosts[@]}"; do
#    if [[ "${hosts[$i]}" == "$chosen" ]]; then
#        chosen_command_index=$i
#        break
#    fi
#done


# gnome-terminal in new window
#gnome-terminal --tab -e "${commands[$chosen_command_index]}"

# gnome-terminal in current window as new tab, needs xdotools
#WID=$(xprop -root | grep "_NET_ACTIVE_WINDOW(WINDOW)"| awk '{print $5}')
#xdotool windowfocus $WID
#xdotool key ctrl+shift+t
#wmctrl -i -a $WID
#sleep 1; xdotool type --delay 1 --clearmodifiers "${commands[$chosen_command_index]}"; xdotool key Return;

# guake
#guake --show -n ${hosts[$chosen_command_index]} -e "${commands[$chosen_command_index]}"
