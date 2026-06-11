#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

dir=$(dirname "$(realpath "$0")")
bakefile="$dir/bakefile"

if [ ! -f "$bakefile" ]; then
    echo "bakefile not found in $dir"
    exit 2
fi

build() {
    local file="$1"
    local rule=$(grep "^$file:" "$bakefile")

    if [ -z "$rule" ]; then
        
        if [ ! -f "$file" ]; then
            echo "Error: '$file' not found and has no rule in bakefile"
            exit 3
        fi

        return
    fi

    local deps=$(echo "$rule" | cut -d':' -f2)
    local cmd=$(echo "$rule"  | cut -d':' -f3-)

    for dep in $deps; do
        build "$dep"
    done

    local needs_build=false

    if [ ! -f "$file" ]; then
        needs_build=true
    else
        for dep in $deps; do
            if [ "$dep" -nt "$file" ]; then
                needs_build=true
                break
            fi
        done
    fi

    if [ "$needs_build" = true ]; then
        echo "Starting build on $file"
        eval "$cmd"
        if [ $? -ne 0 ]; then
            echo "Error: command failed for '$file'"
            exit 4
        fi
    else
        echo "$file is up to date"
    fi
}

build "$1"
