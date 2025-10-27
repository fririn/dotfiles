#!/bin/bash

output_file=/home/paul/.config/rofi/all.txt

ssh_address=$1
ssh_port=${2:-22}
ssh_user=${3:-root}

insert_entry() {	
	echo adding entry for $ssh_hostname with user $ssh_user
	echo -e "$ssh_address\t:$ssh_hostname:ssh $ssh_user@$ssh_address -p$ssh_port" | tee -a $output_file
	sort -Vu -k 1 -o $output_file{,}

	#read -p "Add your key to this server? y/n" -n 1 -r 		
	#if [[ $REPLY =~ ^[Yy]$ ]]
	#then
	#fi
}

ssh_copy_id() {
    ssh-copy-id -i ~/.ssh/id_rsa $ssh_user@$ssh_address -p$ssh_port
#   ssh-copy-id -i /home/paul/.ssh/id_rsa 22@10.6.1.89 -pws3-mail.atlas.hyperoffice.com
}

existing_entry=$(grep "$ssh_address" $output_file)
if [[ -z $existing_entry ]]
then
	read -p 'Type hostname to add this host to rofi script or nothing to skip: ' ssh_hostname
	if [[ -n $ssh_hostname ]]
	then
		insert_entry
	fi
else
	echo -e "Line(s) for this IP address already exist:\n$existing_entry\nAdd another one? insert hostname or blank to skip"
        read ssh_hostname
	#if [[ $REPLY =~ ^[Yy]$ ]]
	if [[ -n $ssh_hostname ]]
	then
		insert_entry
	fi
fi

