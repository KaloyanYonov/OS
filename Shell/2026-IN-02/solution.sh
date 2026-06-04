#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <file> <k>"
    exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    echo "$1 must be a readable file"
    exit 2
fi

if ! echo "$2" | grep -qE '^[0-9]+$'; then
    echo "$2 must be a non-negative integer"
    exit 3
fi

k=$(( $2 % 26 ))
alpha="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
shifted="${alpha:$k}${alpha:0:$k}"
count=0

while IFS= read -r word; do
    decoded=$(echo "$word" | tr 'A-Z' "$shifted")
    if grep -qi "^$decoded$" /usr/share/dict/words; then
        count=$((count + 1))
    fi
done < <(grep -oE '[A-Z]+' "$1" | sort -u)

echo "$count"
