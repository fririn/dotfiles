#!/bin/bash

# base rofi direcory
ROFI_DIR="$HOME/.config/rofi"
rofi_command="rofi -G -theme $ROFI_DIR/themes/ssh_menu.rasi -scroll-method 1 -no-lazy-grab -p search: "
#rofi_command="wofi -scroll-method 1 -no-lazy-grab -p ssh"

# parsing all.txt to three separate arrays.
# example of all.txt string:
# 'IP              :HOSTNAME :SSH COMMAND
# '212.98.160.50   :ns1.bn.by:ssh root@212.98.160.50'
mapfile -t addresses < <(cut -d':' -f1 $ROFI_DIR/all.txt)
mapfile -t hostnames < <(cut -d':' -f2 $ROFI_DIR/all.txt)
mapfile -t commands < <(cut -d':' -f3 $ROFI_DIR/all.txt)


# Passing strings in the form of 'IP\tHOSTNAME\n' to the $rofi_comand.
# It spawns a menu, than gets the second column from chosen string to the $chosen  
chosen=$(paste -d'\t' <(printf "   %s\n" "${addresses[@]}") <(printf "%s\n" "${hostnames[@]}") | $rofi_command -dmenu | awk '{print $2}')


# do nothing if nothing was chosen
if [[ $chosen == "" ]]; then exit; fi


# get index of the chosen address to use later with commands array. Workaround since i did not figure out multidimentional arrays in bash >_<
index=1
for i in "${!hostnames[@]}"; do
    if [[ "${hostnames[$i]}" == "$chosen" ]]; then
        index=$i
        break
    fi
done


# execute command in new tab of guake 
#guake --show -n ${hostnames[$index]} -e "${commands[$index]}"

#alacritty --class Floating -e zsh -c "echo ${commands[$index]};${commands[$index]}" &




SESSION_NAME="ssh"
# Check if the session exists
#if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    # Session does not exist, create it
    #tmux new-session -d -s "$SESSION_NAME" -n "${hostnames[$index]}" \; send-keys "clear;${commands[$index]}" C-m
    #tmux new-session -d -n "${hostnames[$index]}" \; send-keys "clear;${commands[$index]}" C-m
#else
    # create new window in $SESION_NAME session and run the command
    tmux new-window -a -n "${hostnames[$index]}" \; send-keys "clear;${commands[$index]}" C-m
    echo "Created new tmux session: $SESSION_NAME"
#fi


#tilix --class tilix_main --name tilix_main -e bash -c "echo ${commands[$index]};${commands[$index]};sleep infinity"





# gnome-terminal in new window
#gnome-terminal --tab -e "${commands[$chosen_command_index]}"

# gnome-terminal in current window as new tab, needs xdotools
#WID=$(xprop -root | grep "_NET_ACTIVE_WINDOW(WINDOW)"| awk '{print $5}')
#xdotool windowfocus $WID
#xdotool key ctrl+shift+t
#wmctrl -i -a $WID
#sleep 1; xdotool type --delay 1 --clearmodifiers "${commands[$chosen_command_index]}"; xdotool key Return;




