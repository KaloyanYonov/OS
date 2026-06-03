#!/bin/bash


if [ $# -ne 3 ]; then
    echo "Usage: $0 <file> <option> <option>"
    exit 1
fi
if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    echo "$1 must be a readable file"
    exit 2
fi
if ! grep -q "^$2=" "$1"; then
    echo "$2 not found in $1"
    exit 3
fi

value1=$(grep "^$2=" "$1" | cut -d'=' -f2)
value2=$(grep "^$3=" "$1" | cut -d'=' -f2)

new_value2="$value2"
for term in $value1; do
    new_value2=$(echo "$new_value2" | sed "s/\b$term\b//g" | tr -s ' ' | sed 's/^ //;s/ $//')
done

sed -i "s/^$3=.*/$3=$new_value2/" "$1"
