#!/bin/bash

# --- CONFIGURATION ---
ROFI_DIR="$HOME/.config/rofi"
INPUT_FILE="${1:-$ROFI_DIR/ssh/nomad_hosts.txt}"
THEME="$ROFI_DIR/themes/launcher.rasi"
# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    rofi -e "Error: Input file not found at $INPUT_FILE"
    exit 1
fi

# --- STEP 1: PREPARE DATA FOR ROFI ---
# 1. grep -v "^#": Ignore the comment lines from your Nomad script.
# 2. awk: Reformat the colon-separated values into a readable string.
#    Input:  cluster:eligibility:user:hostname:ip
#    Output: hostname | ip | cluster | user | eligibility
#    We use tab (\t) as a separator so `column` can align it perfectly.
# 3. column -t: Aligns the output into perfect columns.
ROFI_LIST=$(grep -v "^#" "$INPUT_FILE" | \
    awk -F':' '{printf "%s\t%s\t%s\t%s\t%s\n", $4, $5, $1, $3, $2}' | \
    column -t -s $'\t')

# --- STEP 2: SELECT VIA ROFI ---
# We define the Rofi command. -i makes it case insensitive.
CHOSEN_LINE=$(echo "$ROFI_LIST" | rofi -dmenu -i -p "SSH" -theme "$THEME" -no-lazy-grab)
# check if anything is chosen
if [[ -z "$CHOSEN_LINE" ]]; then exit 0; fi
# parse variables from chosen line
read -r HOST_NAME NODE_IP CLUSTER_NAME SSH_USER ELIGIBILITY <<< "$CHOSEN_LINE"

#rofi_command="rofi -G -theme $ROFI_DIR/themes/ssh_menu.rasi -scroll-method 1 -no-lazy-grab -p search: "
#rofi_command="wofi -scroll-method 1 -no-lazy-grab -p ssh"

# Construct the SSH command
SSH_CMD="ssh ${SSH_USER}@${NODE_IP}"

SESSION_NAME="ssh"
tmux new-window -a -n "$HOST_NAME" "echo 'Connecting to $HOST_NAME... $SSH_CMD'; $SSH_CMD"

#tilix --class tilix_main --name tilix_main -e bash -c "echo ${commands[$index]};${commands[$index]};sleep infinity"
