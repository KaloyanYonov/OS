#!/bin/bash

if [ $# -ne 3 ];then
	echo "Usage $0 <file> <file> <blackHole>"
	exit 1
fi


if [ ! -f "$1" ] || [ ! -r "$1" ];then
	echo "$1 must be a readable file"
	exit 2
fi

if [ ! -f "$2" ] || [ ! -r "$2" ];then
	echo "$2 must be a readable file"
	exit 3
fi

point1="$1"
point2="$2"
blackHole="$3"


if ! grep -q "$blackHole" "$point1" && ! grep -q "$blackHole" "$point2"; then
	echo "Black hole doesn't exist in both files"
	exit 4
fi

distance1=$(grep "$blackHole" "$point1" | cut -d':' -f2 | grep -oE '[0-9]+' )
distance2=$(grep "$blackHole" "$point2" | cut -d':' -f2 | grep -oE '[0-9]+' )

if [ "$distance1" -ge "$distance2" ];then
	echo "$point1"
else
	echo "$point2"
fi








