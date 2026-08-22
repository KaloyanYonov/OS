#!/bin/bash

user=$(whoami)
if [ "$user" != "oracle" ] && [ "$user" != "grid" ]; then
	echo "Script can only be run by oracle and grid"
	exit 1
fi

if [ -z "$ORACLE_HOME" ]; then
	echo "ORACLE_HOME is not set"
	exit 2
fi

adrci="$ORACLE_HOME/bin/adrci"
if [ ! -x "$adrci" ]; then
	echo "adrci not found or not executable"
	exit 3
fi

diag_dest="/u01/app/$user"

output=$("$adrci" exec="show homes")

if [ "$output" == "No ADR homes are set" ]; then
	exit 0
fi

while IFS= read -r line; do

	trimmed=$(echo "$line" | sed 's/^[ \t]*//; s/[ \t]*$//')

	if [ -z "$trimmed" ]; then
		continue
	fi

	if [ "$trimmed" == "ADR Homes:" ]; then
		continue
	fi

	fullpath="$diag_dest/$trimmed"
	du -sm "$fullpath"

done < <(echo "$output")
