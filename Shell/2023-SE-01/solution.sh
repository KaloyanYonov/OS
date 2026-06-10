#!/bin/bash

# NO BONUS POINTS :(

if [ $# -ne 2 ];then
	echo "Usage $0 <file> <dir>"
	exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ];then
	echo "$1 must be a readable file"
	exit 2
fi

if [ ! -d "$2" ];then
	echo "$2 must be a directory"
	exit 3
fi

badWords="$1"
dir="$2"

while IFS= read -r file; do
	
	while IFS= read -r word; do
		if grep -qx "$word" "$file"; then
			replacement=""
			for char in $(echo "$word" | grep -o '.'); do
				replacement="$replacement*"	
			done
			sed -i "s/\b$word\b/$replacement/g" "$file"
		fi
	done < "$badWords"



done < <(find "$2" -name "*.txt")



