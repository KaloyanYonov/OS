#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 directory"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "$1 must be a directory"
    exit 2
fi

dir1="$1"
hashFile="$dir1/hashFile"
extracted_dir="/extracted"

mkdir -p "$extracted_dir"

if [ ! -f "$hashFile" ]; then
    > "$hashFile"
fi

while IFS= read -r file; do

    base=$(basename "$file")

    if ! echo "$base" | grep -qE '^[^_]+_report-[0-9]+\.tgz$'; then
        continue
    fi

    name=$(echo "$base" | cut -d'_' -f1)
    timestamp=$(echo "$base" | sed -E 's/^[^_]+_report-([0-9]+)\.tgz$/\1/')

    line=$(sha256sum "$file")

    if grep -qxF "$line" "$hashFile"; then
        continue
    fi

    echo "$line" >> "$hashFile"

    member=$(tar -tzf "$file" | grep -E 'meow.txt')

    if [ -n "$member" ]; then
        tmp_dir=$(mktemp -d)
        tar -xzf "$file" -C "$tmp_dir" "$member"
        mv "$tmp_dir/$member" "$extracted_dir/${name}_${timestamp}.txt"
        rm -rf "$tmp_dir"
    fi

done < <(find "$dir1" -name "*.tgz")
