#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Usage: $0 <file> <directory>"
	exit 1
fi

if [ ! -d "$2" ]; then
	echo "$2 must be a directory"
	exit 2
fi

# easier  than find + mindepth imo. 
if [ -n "$(ls -A "$2")" ]; then
	echo "$2 must be empty"
	exit 3
fi

if [ ! -f "$1" ]; then
	echo "$1 must be a file"
	exit 4
fi

if [ ! -r "$1" ]; then
	echo "$1 must be readable"
	exit 5
fi

pathToDir=$(realpath "$2")
dict="$pathToDir/dict.txt"
touch "$dict"

count=0

while IFS= read -r line; do

	prefix=$(echo "$line" | cut -d':' -f1)
	nameSurname=$(echo "$prefix" | grep -oE '^[A-Za-z-]+[[:space:]]+[A-Za-z-]+' | tr -s ' ')

	existing=$(grep "^$nameSurname;" "$dict")
	if [ -z "$existing" ]; then
		count=$((count + 1))
		echo "$nameSurname;$count" >> "$dict"
		echo "$line" >> "$pathToDir/$count.txt"
	else
		number=$(echo "$existing" | cut -d';' -f2)
		echo "$line" >> "$pathToDir/$number.txt"
	fi
done < "$1"
