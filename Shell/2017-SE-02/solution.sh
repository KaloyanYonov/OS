#/bin/bash


if [ $# -ne 3 ];then
	echo "Usage $0 <SRC> <DST> <ABC>"
	exit 1
fi

if [ "$(whoami)" != "root" ];then
	echo "Must be ran as root"
	exit 2
fi

SRC="$1"
DST="$2"
ABC="$3"

if [ ! -d "$SRC" ];then
	echo "$SRC must be a directory"
	exit 3
fi

if [ ! -d "$DST" ];then
	echo "$DST must be a directory"
	exit 4
fi

if [ -n "$(find "$DST" -mindepth 1 -maxdepth 1)" ];then
	echo "$DST must be empty"
	exit 5
fi

while IFS= read -r file;do

	relpath=$(echo "$file" | sed "s|^$SRC/||")
	reldir=$(dirname "$relpath")

	mkdir -p "$DST/$reldir"

	mv "$file" "$DST/$relpath"

done < <(find "$SRC" -type f -name "*$ABC*")



