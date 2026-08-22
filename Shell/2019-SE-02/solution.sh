#!/bin/bash

if [ "$1" == "-n" ]; then
	if ! echo "$2" | grep -qE '^[0-9]+$'; then
		echo "$2 after -n must be a number"
		exit 1
	fi
	N="$2"
	shift 2
else
	N=10
fi

tmp=$(mktemp)

for arg in "$@"; do

	fileName=${arg%.log}

	while IFS= read -r line; do
		timestamp="${line:0:19}"
		data="${line:20}"
		echo "$timestamp $fileName $data" >> "$tmp"
	done < <(tail -n "$N" "$arg")

done

sort "$tmp"
rm -f "$tmp"
