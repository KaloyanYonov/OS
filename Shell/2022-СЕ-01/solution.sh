#!/bin/bash
if [ $# -ne 3 ]; then
    echo "Usage $0 <number> <prefix> <unit>"
    exit 1
fi

number="$1"
prefixInput="$2"
unitInput="$3"

if ! echo "$number" | grep -qE '^[0-9]+(\.[0-9]+)?$'; then
    echo "Must be a positive number"
    exit 2
fi

if ! grep -q "$prefixInput" "prefix.csv"; then
    echo "Prefix doesn't exist"
    exit 3
fi

if ! grep -q "$unitInput" "base.csv"; then
    echo "Unit doesn't exist"
    exit 4
fi

while IFS=',' read -r unit symbol measure; do
    if [ "$symbol" == "$unitInput" ]; then
        while IFS=',' read -r pref symb decimal; do
            if [ "$symb" == "$prefixInput" ]; then
                result=$(echo "$decimal * $number" | bc)
                echo "$result $symbol ($measure, $unit)"
            fi
        done < <(tail -n +2 "prefix.csv")
    fi
done < <(tail -n +2 "base.csv")
