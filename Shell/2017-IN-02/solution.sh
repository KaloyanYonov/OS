#!/bin/bash


if [ $# -ne 1 ]; then
	echo "Usage $0 <user>"
	exit 1
fi

if [ $(whoami) != "root" ];then
	echo "Must be ran as root"
	exit 2
fi

FOO="$1"
fooCount=$(ps -e -o user | grep -c "$FOO" )
while IFS= read -r user; do
    count=$(ps -e -o user | grep -c "^$user$")
    if [ "$count" -gt "$fooCount" ]; then
        echo "$user"
    fi
done < <(ps -e -o user | tail -n +2 | grep -v "^$FOO$" | sort -u)

total=0
count=0

while IFS= read -r time; do
    IFS=':' read -r h m s <<< "$time"
    seconds=$((10#$h * 3600 + 10#$m * 60 + 10#$s))
    total=$((total + seconds))
    count=$((count + 1))
done < <(ps -e -o time | tail -n +2)

avg=$((total / count))
echo "Средно време: $avg секунди"

while IFS= read -r line; do
    pid=$(echo "$line"   | tr -s ' ' | cut -d' ' -f2)
    time=$(echo "$line"  | tr -s ' ' | cut -d' ' -f3)

    IFS=':' read -r h m s <<< "$time"
    seconds=$((10#$h * 3600 + 10#$m * 60 + 10#$s))

    if [ "$seconds" -gt $((avg * 2)) ]; then
        kill -15 "$pid"
        sleep 2
        kill -9 "$pid" 2>/dev/null
    fi
done < <(ps -e -o user,pid,time | tail -n +2 | tr -s ' ' | grep "^$FOO ")



