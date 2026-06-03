#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi
if [ ! -f "$1" ]; then
    echo "Must be a file"
    exit 2
fi
if [ ! -r "$1" ]; then
    echo "$1 must be readable"
    exit 3
fi

count=1
while IFS= read -r line; do
    cleaned=$(echo "$line" | sed 's/^[0-9]* г\. - //')
    echo "$count. $cleaned"
    count=$((count + 1))
done < "$1" | sort -k2
