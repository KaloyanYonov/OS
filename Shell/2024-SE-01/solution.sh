#!/bin/bash
# Not finished 

if [ $# -lt 2 ];then
	echo "Usage {0} <file> <replacement1> ....[replacementN]"
	exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ];then
	echo "Must be a readable file"
	exit 2
fi

if ! echo "$1" | grep -qE '^-';then
	echo "FIle name cannot start with -"
	exit 3
fi



