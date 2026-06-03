#!/bin/bash

if [ $(whoami) != "root" ];then
	echo "Must be ran as root"
	exit 1
fi


while IFS= read -r line;do
	user=$(echo "$line" | cut -d':' -f1)
	homedir=$(echo "$line" | cut -d':' -f6)

	if [ ! -d "$homedir" ];then
		echo "$user"
	elif [ ! -w "$homedir" ];then
		echo "$user"
	fi

done < /etc/passwd


