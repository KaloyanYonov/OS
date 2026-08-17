#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: $0 dir"
	exit 1
fi

if [ ! -d "$1" ]; then
	echo "$1 must be a directory"
	exit 2
fi

fuga="$1"
pwdfile="$fuga/foo.pwd"
conf="$fuga/foo.conf"
cfg="$fuga/cfg"
validate="$fuga/validate.sh"

> "$conf"

while IFS= read -r file; do

	output=$("$validate" "$file")
	retVal=$?

	if [ "$retVal" -eq 1 ]; then
		while IFS= read -r line; do
			echo "$file:$line" >&2
		done < <(echo "$output")
		continue
	elif [ "$retVal" -eq 2 ]; then
		echo "$file: error while running validate.sh" >&2
		continue
	fi

	cat "$file" >> "$conf"

	base=$(basename "$file")
	name="${base%.cfg}"

	if ! grep -q "^$name:" "$pwdfile"; then
		pass=$(pwgen 16 1)
		hashed=$(mkpasswd "$pass")
		echo "$name:$hashed" >> "$pwdfile"
		echo "$name:$pass"
	fi

done < <(find "$cfg" -type f -name "*.cfg")
