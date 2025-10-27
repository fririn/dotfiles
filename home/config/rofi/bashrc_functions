#!/bin/bash

ins() {
	local ssh_address=$1
	local ssh_port=${2:-22}
	local ssh_user=${3:-root}

	~/.config/rofi/add_host.sh $ssh_address $ssh_port $ssh_user
}

s() {
	local ssh_address=$1
	local ssh_port=${2:-22}
	local ssh_user=${3:-root}

	if [[ $# -eq 0 ]]
	then 
                echo 'usage(port and user are optional): s *ip* *port* *user*'
                echo 'Example: s 192.168.0.15 1234 testuser'
		return 0
	fi
	~/.config/rofi/add_host.sh $ssh_address $ssh_port $ssh_user


	ssh $ssh_user@$ssh_address -p$ssh_port
	return 0
}



sid() {
	local ssh_address=$1
	local ssh_port=${2:-22}
	local ssh_user=${3:-root}
	
	if [[ $# -eq 0 ]]
        then 
                echo 'usage(port is optional): sid *ip* *port* *user*'
                echo 'Example: sid 192.168.0.15 1234 testuser'
                return 0
        fi

	if [[ -z $(grep $ssh_address ~/.config/rofi/all.txt) ]]
	then
		read -p 'This IP is not present in hosts.txt file for rofi ssh script. Type hostname to add this host or nothing to skip: ' user_input
		if [[ $user_input ]]
		then
			~/.config/rofi/add_host.sh $ssh_address $user_input $ssh_port $ssh_user
		fi
	fi	
        ssh-copy-id -i ~/.ssh/id_rsa -p$ssh_port $ssh_user@$ssh_address 
        return 0
}

