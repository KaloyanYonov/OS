#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <path/to/file>"
    exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    echo "Must be a readable file"
    exit 2
fi

visited=$(mktemp)

process_file() {
    local file="$1"
    local absfile=$(realpath "$file")

    if grep -qx "$absfile" "$visited"; then
        echo "Error: circular include detected: $absfile" >&2
        rm -f "$visited"
        exit 3
    fi

    if [ ! -f "$absfile" ] || [ ! -r "$absfile" ]; then
        echo "Error: cannot read file: $absfile" >&2
        rm -f "$visited"
        exit 4
    fi

    echo "$absfile" >> "$visited"
    local dir=$(dirname "$absfile")

    while IFS= read -r line; do
        if echo "$line" | grep -qE '^!include:'; then
            included=$(echo "$line" | cut -d' ' -f2-)
            included_path="$dir/$included"
            process_file "$included_path"
        else
            echo "$line"
        fi
    done < "$absfile"

    tmp=$(mktemp)
    grep -vx "$absfile" "$visited" > "$tmp"
    mv "$tmp" "$visited"
}

process_file "$1"
rm -f "$visited"
