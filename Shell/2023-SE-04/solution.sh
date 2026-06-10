#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <dir>"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "$1 must be a directory"
    exit 2
fi

dir="$1"
groups=0
freed=0
hashFile=$(mktemp)

while IFS= read -r file; do
    hash=$(sha1sum "$file" | cut -d' ' -f1)
    echo "$hash $file" >> "$hashFile"
done < <(find "$dir" -mindepth 1 -type f)

while IFS= read -r hash; do

    count=$(grep -c "^$hash " "$hashFile")

    if [ "$count" -gt 1 ]; then

        groups=$((groups + 1))
        original=$(grep "^$hash " "$hashFile" | head -n 1 | cut -d' ' -f2-)
        fileSize=$(stat -c '%s' "$original")

        while IFS= read -r duplicate; do
            rm "$duplicate"
            ln "$original" "$duplicate"
            freed=$((freed + fileSize))
        done < <(grep "^$hash " "$hashFile" | tail -n +2 | cut -d' ' -f2-)
    fi

done < <(cut -d' ' -f1 "$hashFile" | sort -u)

echo "Deduplicated groups: $groups. Space freed: $freed bytes."

rm -f "$hashFile"
