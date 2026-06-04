#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <DIR>"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "$1 must be a directory"
    exit 2
fi

DIR="$1"
DATA="$DIR/.data"

mkdir -p "$DATA"

while IFS= read -r file; do


    hash=$(sha256sum "$file" | cut -d' ' -f1)
    dest="$DATA/$hash"

    if [ ! -f "$dest" ]; then
        mv "$file" "$dest"
    else
        rm "$file"
    fi

    rellink=$(realpath --relative-to="$(dirname "$file")" "$dest")

    ln -s "$rellink" "$file"

done < <(find "$DIR" -type f -not -path "$DATA/*")
