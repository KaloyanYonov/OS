#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Usage: $0 <file> <file>"
    exit 1
fi
if [ ! -r "$1" ]; then
    echo "Must be a readable file"
    exit 2
fi
if [ ! -r "$2" ]; then
    echo "Must be a readable file"
    exit 3
fi

file1="$1"
file2="$2"
file1Lines=$(grep -c "$(basename "$file1")" "$file1")
file2Lines=$(grep -c "$(basename "$file2")" "$file2")

if [ "$file1Lines" -ge "$file2Lines" ]; then
    winner="$file1"
else
    winner="$file2"
fi

cut -d' ' -f4- < "$winner" | sort > "$(basename "$winner").songs"
