#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <config_file>"
    exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    echo "$1 must be a readable file"
    exit 2
fi

if [ "$(whoami)" != "root" ]; then
    echo "Must be run as root"
    exit 3
fi

configFile="$1"

while IFS= read -r line; do
    if [ -z "$line" ]; then
        continue
    fi

    directory=$(echo "$line" | tr -s ' ' | cut -d' ' -f1)
    bitType=$(echo "$line"   | tr -s ' ' | cut -d' ' -f2)
    perms=$(echo "$line"     | tr -s ' ' | cut -d' ' -f3)

    while IFS= read -r item; do
        filePerms=$(stat -c '%a' "$item")

        if [ "$bitType" == "R" ]; then
            if [ "$filePerms" == "$perms" ]; then
                if [ -d "$item" ]; then
                    chmod 755 "$item"
                elif [ -f "$item" ]; then
                    chmod 664 "$item"
                fi
            fi

        elif [ "$bitType" == "A" ]; then
            result=$(( 8#$filePerms & 8#$perms ))
            if [ "$result" -ne 0 ]; then
                if [ -d "$item" ]; then
                    chmod 755 "$item"
                elif [ -f "$item" ]; then
                    chmod 664 "$item"
                fi
            fi

        elif [ "$bitType" == "T" ]; then
            result=$(( 8#$filePerms & 8#$perms ))
            if [ "$result" -eq $(( 8#$perms )) ]; then
                if [ -d "$item" ]; then
                    chmod 755 "$item"
                elif [ -f "$item" ]; then
                    chmod 664 "$item"
                fi
            fi
        fi

    done < <(find "$directory" -mindepth 1 \( -type f -o -type d \))

done < "$configFile"
