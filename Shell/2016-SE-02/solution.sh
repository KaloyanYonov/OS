#!/bin/bash

if [ $# -ne 1 ];then
	echo "Usage $0 <number>"
	exit 1
fi

if ! echo "1" | grep -E '^[0-9]+$';then
	echo "Must enter a valid number"
	exit 2
fi

if [ $(whoami) != "root" ]; then
	echo "Must be ran as root"
	exit 3
fi

while IFS= read -r uid; do

    total=0
    while IFS= read -r line; do
        rss=$(echo "$line" | tr -s ' ' | cut -d' ' -f3)
        total=$((total + rss))
    done < <(ps -e -o uid,pid,rss | tail -n +2 | tr -s ' ' | grep "^ *$uid ")

    echo "UID $uid: общо RSS = $total"

    if [ "$total" -gt "$1" ]; then
        max_pid=$(ps -e -o uid,pid,rss | tail -n +2 | tr -s ' ' \
                 | grep "^ *$uid " | sort -k3 -rn | head -n 1 | cut -d' ' -f2)

        echo "Прекратявам PID $max_pid за UID $uid"
        kill -15 "$max_pid"        
        sleep 2
        kill -9 "$max_pid" 2>/dev/null 
    fi
done < <(ps -e -o uid | tail -n +2 | tr -s ' ' | sort -u)



