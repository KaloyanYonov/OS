#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    echo "Must be run as root"
    exit 1
fi

while IFS= read -r user; do
    count=0
    total=0
    max_rss=0
    max_pid=0

    while IFS= read -r line; do
        pid=$(echo "$line" | tr -s ' ' | cut -d' ' -f2)
        rss=$(echo "$line" | tr -s ' ' | cut -d' ' -f3)

        count=$((count + 1))
        total=$((total + rss))
	
	if [ "$rss" -gt "$max_rss" ]; then
            max_rss="$rss"
            max_pid="$pid"
        fi
    done < <(ps -e -o user,pid,rss | tail -n +2 | tr -s ' ' | grep "^$user ")

    [ "$count" -eq 0 ] && continue

    avg=$((total / count))

    echo "User: $user | Proccesses: $count | Total RSS: $total KB | Average RSS: $avg KB"


    if [ "$max_rss" -gt $((avg * 2)) ]; then
        echo " Stopping PID $max_pid on $user (RSS: $max_rss KB, average: $avg KB)"
        kill -15 "$max_pid"
        sleep 2
        kill -9 "$max_pid" 2>/dev/null
    fi

