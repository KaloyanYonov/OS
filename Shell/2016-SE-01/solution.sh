#/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage $0 <dir>"
	exit 1
fi

if [ ! -d "$1" ];then
	echo "$1 must be a directory"
	exit 2
fi

find "$1" -xtype l 


