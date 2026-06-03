#!/bin/bash


if [ $# -lt 1 ]; then
    echo "Usage: $0 <directory> [file]"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "$1 must be a directory"
    exit 2
fi

if [ -n "$2" ]; then
    exec >> "$2"
fi

broken=0

while IFS= read -r symlink; do
    if [ -e "$symlink" ]; then
        name=$(basename "$symlink")
        dest=$(readlink "$symlink")
        echo "$name -> $dest"
    else
        broken=$((broken + 1))
    fi
done < <(find "$1" -type l)

echo "Broken symlinks: $broken"

