#!/bin/bash


if [ $# -ne 2 ]; then
    echo "Usage: $0 <dir> <string>"
    exit 1
fi
if [ ! -d "$1" ]; then
    echo "Must be a directory"
    exit 2
fi

max_x=0
max_y=0
max_z=0

while IFS= read -r line; do
    if ! echo "$line" | grep -qE "^vmlinuz-[0-9]+\.[0-9]+\.[0-9]+-${2}$"; then
        continue
    fi

    x=$(echo "$line" | cut -d'-' -f2 | cut -d'.' -f1)
    y=$(echo "$line" | cut -d'-' -f2 | cut -d'.' -f2)
    z=$(echo "$line" | cut -d'-' -f2 | cut -d'.' -f3)

    if [ "$x" -gt "$max_x" ]; then
        max_x="$x"
        max_y="$y"
        max_z="$z"
    elif [ "$x" -eq "$max_x" ]; then
        if [ "$y" -gt "$max_y" ]; then
            max_y="$y"
            max_z="$z"
        elif [ "$y" -eq "$max_y" ]; then
            if [ "$z" -ge "$max_z" ]; then
                max_z="$z"
            fi
        fi
    fi
done < <(find "$1" -mindepth 1 -maxdepth 1 -type f -printf '%f\n')

echo "vmlinuz-${max_x}.${max_y}.${max_z}-${2}"

