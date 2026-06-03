#!/bin/bash

if [ $# -ne 2 ];then
	echo "Usage $0 <number> <number>"
	exit 1
fi

if ! echo "$1" | grep -E '^[0-9]+$'; then
	echo "$1 Must be a positive integer"
	exit 2
fi

if ! echo "$2" | grep -qE '^[0-9]+$'; then
	echo "$2 Must be a positive integer"
	exit 3
fi

mkdir -p a b c

while IFS= read -r file; do
		
	fileLines=$(wc -l < "$file")

	if [ $fileLines -lt $1 ];then
		mv "$file" a
	elif [ $fileLines -ge $1 ] && [ $fileLines -le $2 ];then
		mv "$file" b
	else
		mv "$file" c
	fi

done < <(find . -type f)


