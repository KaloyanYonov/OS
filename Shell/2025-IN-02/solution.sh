#!/bin/bash



if [ $# -ne 2 ];then
	echo "Usage $0 <domain> <file>"
	exit 1
fi


if [ ! -f "$2" ] || [ ! -r "$2" ];then
	echo "$2 must be a readable file"
	exit 2
fi

domain="$1"
file="$2"

while IFS= read -r team; do

	echo "; team $team"

	while IFS= read -r zone;do
		while IFS= read -r server;do
			echo "$zone IN NS $server.$domain"
		done < <(tr -s ' ' < "$file" | grep "$team" | cut -d' ' -f1) 
	

	done < <(tr -s ' ' < "$file" | grep "$team" | cut -d' ' -f2)

done < <(tr -s ' ' < "$file" | cut -d' ' -f3 | sort -u)



