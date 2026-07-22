#!/bin/bash

if [ $# -ne 1 ];then
	echo "Usage $0 <dir>"
	exit 1
fi
if [ ! -d "$1" ];then
	echo "$1 must be a directory"
	exit 2
fi
dir="$1"

allFile=$(mktemp)
groupFile=$(mktemp)

while IFS= read -r file; do

	sum=$(sha1sum "$file" | cut -d' ' -f1)
	inode=$(stat -c %i "$file")
	echo "$sum $inode $file"

done < <(find "$dir" \( -type f -o -type l \)) > "$allFile"

while IFS= read -r sum; do

	grep "^$sum " "$allFile" > "$groupFile"

	hasHardlinkGroup=0
	while IFS= read -r inode; do
		count=$(grep -c "^$sum $inode " "$groupFile")
		if [ "$count" -ge 2 ]; then
			hasHardlinkGroup=1
		fi
	done < <(cut -d' ' -f2 "$groupFile" | sort -u)

	first=1

	while IFS= read -r inode; do

		count=$(grep -c "^$sum $inode " "$groupFile")
		if [ "$count" -ge 2 ]; then
			grep "^$sum $inode " "$groupFile" | cut -d' ' -f3- | tail -n +2
		else
			fname=$(grep "^$sum $inode " "$groupFile" | cut -d' ' -f3-)
			if [ "$hasHardlinkGroup" -eq 1 ]; then
				echo "$fname"
			else
				if [ "$first" -eq 1 ]; then
					first=0
				else
					echo "$fname"
				fi
			fi
		fi
	done < <(cut -d' ' -f2 "$groupFile" | sort -u)

done < <(cut -d' ' -f1 "$allFile" | sort -u)

rm -f "$allFile" "$groupFile"
