#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Usage $0 <csv file> <csv file>"
	exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ]; then
	echo "$1 must be a readable file"
	exit 2
fi

createdFile="$2"
touch "$createdFile"

while IFS= read -r line; do

	id=$(echo "$line" | cut -d',' -f1)
	rest=$(echo "$line" | cut -d',' -f2-)

	match=""
	while IFS= read -r existingLine; do

		exRest=$(echo "$existingLine" | cut -d',' -f2-)
		if [ "$rest" = "$exRest" ]; then
			match="$existingLine"
			break
		fi

	done < "$createdFile"

	if [ -z "$match" ]; then
		echo "$line" >> "$createdFile"
	else
		matchId=$(echo "$match" | cut -d',' -f1)
		if [ "$id" -lt "$matchId" ]; then
			sed -i "/^$match$/d" "$createdFile"
			echo "$line" >> "$createdFile"
		fi
	fi

done < "$1"
