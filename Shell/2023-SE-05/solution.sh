#!/bin/bash

magic=65536
commands=$(mktemp)
iter=0

while true; do

    iter=$((iter + 1))
    found=false

    while IFS= read -r comm; do
        totalRss=0

        while IFS= read -r rss; do
            totalRss=$((totalRss + rss))
        done < <(ps -eo rss,comm | tail -n +2 | grep " $comm$" | cut -d' ' -f1)

        if [ "$totalRss" -gt "$magic" ]; then
            found=true
            echo "$comm" >> "$commands"
        fi

    done < <(ps -eo comm | tail -n +2 | sort -u)

    if [ "$found" = false ]; then
        break
    fi

    sleep 1
done

half=$((iter / 2))

while IFS= read -r comm; do
    if [ -z "$comm" ]; then
        continue
    fi
    count=$(grep -cx "$comm" "$commands")
    if [ "$count" -gt "$half" ]; then
        echo "$comm"
    fi
done < <(sort -u "$commands")

rm -f "$commands"
