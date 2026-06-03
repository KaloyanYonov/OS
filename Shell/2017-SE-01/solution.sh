#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: $0 <directory> [number]"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "$1 must be a directory"
    exit 2
fi

if [ $# -eq 2 ]; then
    find "$1" -type f -links +"$2"
else
    find "$1" -xtype l
fi
