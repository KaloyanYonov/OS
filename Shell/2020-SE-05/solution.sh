#!/bin/bash

if [ $# -ne 3 ]; then
	echo "Usage: $0 password_file config_file cfg_directory"
	exit 1
fi

pwd_file="$1"
config_file="$2"
cfg_dir="$3"

if [ ! -f "$pwd_file" ] || [ ! -r "$pwd_file" ] || [ ! -w "$pwd_file" ]; then
	echo "$pwd_file must be a readable and writable file"
	exit 2
fi

if [ ! -d "$cfg_dir" ]; then
	echo "$cfg_dir must be a directory"
	exit 3
fi

if [ -f "$config_file" ] && [ ! -w "$config_file" ]; then
	echo "$config_file must be writable"
	exit 4
fi

echo -n "" > "$config_file"

while IFS= read -r file; do

	errors=""
	lineCount=0

	while IFS= read -r line; do

		lineCount=$(( lineCount + 1 ))

		if echo "$line" | grep -qE '^#'; then
			continue
		fi

		if ! echo "$line" | grep -qE '^\{ [A-Za-z0-9_-]+ \};$'; then
			errors="${errors}Line $lineCount:$line"
		fi

	done < "$file"

	if [ -n "$errors" ]; then
		echo "Error in $file:"
		echo -n "$errors"
		continue
	fi

	cat "$file" >> "$config_file"

	username=$(basename "$file" .cfg)

	if ! grep -q "^$username:" "$pwd_file"; then
		password=$(pwgen 16 1)
		hash=$(echo "$password" | md5sum | cut -d' ' -f1)
		echo "$username:$hash" >> "$pwd_file"
		echo "$username $password"
	fi

done < <(find "$cfg_dir" -name "*.cfg")
