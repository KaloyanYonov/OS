#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    echo "Must be run as root"
    exit 1
fi

newest_time=0
newest_file=""
newest_user=""

while IFS=':' read -r username _ _ _ _ homedir _; do

    if [ ! -d "$homedir" ]; then
        continue
    fi

    result=$(find "$homedir" -type f -printf "%Ts %p\n" 2>/dev/null | sort -rn | head -n 1)

    if [ -z "$result" ]; then
        continue
    fi

    ftime=$(echo "$result" | cut -d' ' -f1)
    fpath=$(echo "$result" | cut -d' ' -f2-)

    if [ "$ftime" -gt "$newest_time" ]; then
        newest_time="$ftime"
        newest_file="$fpath"
        newest_user="$username"
    fi
done < /etc/passwd

if [ -z "$newest_file" ]; then
    echo "Files not found"
    exit 2
fi

echo "User: $newest_user"
echo "FIle: $newest_file"
