#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <options_file>"
    exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    echo "$1 must be a readable file"
    exit 2
fi

file="$1"
cmd=""
args=""
envvars=""
workdir=""

while IFS= read -r line; do

    line=$(echo "$line" | sed 's/#.*//' | sed 's/[[:space:]]*$//')

    if [ -z "$line" ];then
	    continue
    fi

    key=$(echo "$line" | cut -d' ' -f1)
    value=$(echo "$line" | cut -d' ' -f2-)

    if [ "$key" = "CMD" ]; then
        cmd="$value"
    elif [ "$key" = "ARGS" ]; then
        args="$value"
    elif [ "$key" = "ENV" ]; then
        envvars="$value"
    elif [ "$key" = "WORKDIR" ]; then
        workdir="$value"
    fi

done < "$file"

if [ -z "$cmd" ]; then
    echo "Error: no CMD specified"
    exit 3
fi

parsed_args=""
if [ -n "$args" ]; then
    parsed_args=$(echo "$args" | sed 's/^\[//' | sed 's/\]$//' | sed 's/, / /g')
fi

parsed_env=""
if [ -n "$envvars" ]; then
    parsed_env=$(echo "$envvars" | sed 's/^{//' | sed 's/}$//' \
        | sed 's/": "/=/g' | sed 's/", "/\n/g' | sed 's/"//g' \
        | while IFS= read -r pair; do
            printf '%s ' "$pair"
          done)
fi

if [ -n "$workdir" ]; then
    cd "$workdir"
fi

eval "env $parsed_env $cmd $parsed_args"
