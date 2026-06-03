#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    echo "Must be run as root"
    exit 1
fi

root_rss=0
while IFS= read -r line; do
    rss=$(echo "$line" | tr -s ' ' | cut -d' ' -f2)
    root_rss=$((root_rss + rss))
done < <(ps -e -o user,rss | tail -n +2 | tr -s ' ' | grep "^root ")

while IFS=':' read -r username _ uid _ _ homedir _; do
    [ "$username" = "root" ] && continue
    [ "$uid" -eq 0 ] && continue

    problem=0

    if [ ! -d "$homedir" ]; then
        problem=1
    else
        owner=$(stat -c '%U' "$homedir")
        if [ "$owner" != "$username" ]; then
		problem=1
        else
            perm=$(stat -c '%A' "$homedir")
            owner_write=${perm:2:1}
            if [ "$owner_write" != "w" ]; then
                problem=1
            fi
        fi
    fi

    [ "$problem" -eq 0 ] && continue

    user_rss=0
    while IFS= read -r line; do
        rss=$(echo "$line" | tr -s ' ' | cut -d' ' -f2)
        user_rss=$((user_rss + rss))
    done < <(ps -e -o user,rss | tail -n +2 | tr -s ' ' | grep "^$username ")

    if [ "$user_rss" -gt "$root_rss" ]; then
        while IFS= read -r pid; do
            kill -15 "$pid"
            sleep 2
            kill -9 "$pid" 2>/dev/null
        done < <(ps -e -o user,pid | tail -n +2 | tr -s ' ' | grep "^$username " | cut -d' ' -f2)
    fi

done < /etc/passwd
