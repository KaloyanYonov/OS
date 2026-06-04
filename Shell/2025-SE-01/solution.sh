#!/bin/bash

if [ $# -ne 2 ];then
	echo "Usage $0 <file> <file>"
	exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ];then
	echo "$1 must be a readable file"
	exit 2
fi

file="$1"
dirFile="$2"
name=$(basename "$dirFile")
name="${name%.*}"


while IFS= read -r line; do
	language=$(echo "$line" | cut -d' ' -f1)
	basedir=$(echo "$line" | grep -oE "'[^']+'" | tr -d "'")
	

	opts=""
    	if ! echo "$line" | grep -qw "listener"; then
        	opts="$opts -no-listener"
    	fi
    	if echo "$line" | grep -qw "visitor"; then
       		opts="$opts -visitor"
    	fi

    	outdir="$basedir/$name"
    	antlr4 -Dlanguage="$language" $opts -o "$outdir" "$dirFile"


	
done < "$file"


