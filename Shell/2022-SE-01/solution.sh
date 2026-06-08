#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <config_file>"
    exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    echo "Must enter a readable file"
    exit 2
fi

wakeup="/proc/acpi/wakeup"
configFile="$1"

while IFS= read -r line; do

    line=$(echo "$line" | sed 's/#.*//')
    line=$(echo "$line" | tr -s ' ' | sed 's/^ //;s/ $//')

    if [ -z "$line" ]; then
        continue
    fi

    configDevice=$(echo "$line" | cut -d' ' -f1)
    preferredStatus=$(echo "$line" | cut -d' ' -f2)

    deviceLine=$(grep "^$configDevice " "$wakeup")
    if [ -z "$deviceLine" ]; then
        echo "Warning: device '$configDevice' not found in $wakeup"
        continue
    fi

    currentStatus=$(echo "$deviceLine" | tr -s ' ' | cut -d' ' -f3 | sed 's/^\*//')


    if [ "$currentStatus" != "$preferredStatus" ]; then
        echo "Setting $configDevice to $preferredStatus"
        echo "$configDevice" > "$wakeup"
    else
        echo "$configDevice is already $preferredStatus"
    fi

done < "$configFile"
