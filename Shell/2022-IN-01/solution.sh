#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <dir1> <dir2>"
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

if [ -n "$(find "$2" -mindepth 1)" ]; then
    echo "$2 must be empty"
    exit 4
fi

dir1="$1"
dir2="$2"

while IFS= read -r item; do

    filename=$(basename "$item")

    if echo "$filename" | grep -qE '^\..+\.swp$'; then
        continue
    fi

    relpath="${item#$dir1/}"
    mkdir -p "$dir2/$(dirname "$relpath")"
    cp "$item" "$dir2/$relpath"

done < <(find "$dir1" -type f)
