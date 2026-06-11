#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 [-R<word1>=<word2>] ... <file> ..."
    exit 1
fi

for arg in "$@"; do
    if [[ "$arg" == -* ]] && [[ "$arg" != -R* ]]; then
        echo "Invalid argument: $arg"
        exit 2
    fi
done

for arg in "$@"; do
    if [[ "$arg" == -R* ]]; then
        inner="${arg#-R}"
        if ! echo "$inner" | grep -qE '^[a-zA-Z0-9]+=[a-zA-Z0-9]+$'; then
            echo "$arg must be -R<word1>=<word2>"
            exit 3
        fi
    else
        if [ ! -f "$arg" ]; then
            echo "File not found: $arg"
            exit 4
        fi
    fi
done

temp=$(mktemp)

for arg in "$@"; do
    if [[ "$arg" == -R* ]]; then
        echo "${arg#-R}" >> "$temp"
    fi
done

for arg in "$@"; do
    if [[ "$arg" != -R* ]]; then
        file="$arg"
        tmp_file=$(mktemp)
        mapping_file=$(mktemp)
        current="$file"
        cp "$file" "$tmp_file"

        while IFS='=' read -r word1 word2; do
            placeholder=$(pwgen 30 1)
            echo "$placeholder=$word2" >> "$mapping_file"
            sed -i "/^#/! s/\b$word1\b/$placeholder/g" "$tmp_file"
        done < "$temp"

        while IFS='=' read -r placeholder word2; do
            sed -i "s/$placeholder/$word2/g" "$tmp_file"
        done < "$mapping_file"

        mv "$tmp_file" "$file"
        rm -f "$mapping_file"
    fi
done

rm -f "$temp"
