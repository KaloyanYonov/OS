#!/bin/bash


if [ $# -ne 3 ]; then
	echo "Usage: $0 <config_file> <key> <value>"
	exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ]; then
	echo "$1 must be a readable file"
	exit 2
fi

file=$1
key=$2
value=$3

if ! echo "$key" | grep -qE '^[a-zA-Z0-9_]+$'; then
	echo "Key must only contain letters, digits and underscore"
	exit 3
fi

if ! echo "$value" | grep -qE '^[a-zA-Z0-9_]+$'; then
	echo "Value must only contain letters, digits and underscore"
	exit 4
fi

user=$(whoami)
currDate=$(date)

tmpfile=$(mktemp)
found=0

while IFS= read -r line; do

	trimmed=$(echo "$line" | sed 's/^[ \t]*//; s/[ \t]*$//')

	if [ -z "$trimmed" ]; then
		echo "$line" >> "$tmpfile"
		continue
	fi

	if echo "$trimmed" | grep -q '^#'; then
		echo "$line" >> "$tmpfile"
		continue
	fi

	noComment=$(echo "$line" | cut -d'#' -f1)
	fileKey=$(echo "$noComment" | cut -d'=' -f1 | tr -s ' \t' ' ' | sed 's/^ //; s/ $//')
	fileValue=$(echo "$noComment" | cut -d'=' -f2- | tr -s ' \t' ' ' | sed 's/^ //; s/ $//')

	if [ "$fileKey" != "$key" ]; then
		echo "$line" >> "$tmpfile"
		continue
	fi

	found=1

	if [ "$fileValue" == "$value" ]; then
		echo "$line" >> "$tmpfile"
	else
		echo "# $line # edited at $currDate by $user" >> "$tmpfile"
		echo "$key = $value # added at $currDate by $user" >> "$tmpfile"
	fi
done < "$file"

if [ "$found" -eq 0 ]; then
	echo "$key = $value # added at $currDate by $user" >> "$tmpfile"
fi

mv "$tmpfile" "$file"
