#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <oldDir> <newDir>"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "$1 must be a directory"
    exit 2
fi

if [ ! -d "$2" ]; then
    echo "$2 must be a directory"
    exit 3
fi

while IFS= read -r file; do

    relpath="${file#$1/}"
    newfile="$2/${relpath%.bcf}.bcf2"
    mkdir -p "$(dirname "$newfile")"

    while IFS= read -r key; do
        count=$(grep -c "^$key=" "$file")
        if [ "$count" -eq 1 ]; then
            value=$(grep "^$key=" "$file" | cut -d'=' -f2-)
            echo "$key: $value"
        else
            echo "$key:"
            while IFS= read -r val; do
    		echo "- $val"
	    done < <(grep "^$key=" "$file" | cut -d'=' -f2-)
        fi
    done < <(cut -d'=' -f1 "$file" | sort -u) > "$newfile"

done < <(find "$1" -type f -name "*.bcf")



