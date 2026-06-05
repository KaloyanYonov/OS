#!/bin/bash

# not finished

if [ $# -ne 1 ];then
	echo "Usage $0 <number>"
	exit 1
fi

if ! echo "$1" | grep -qE '^[0-9]+$'; then
	echo "Must enter a positive number"
	exit 2
fi

accords="A.Bb.B.C.Db.D.Eb.E.F.Gb.G.Ab"
n=$(( "$1" % 12 ))
shifted="${accords:$n}${accords:0:$n}"

while IFS= read -r line; do
	
	acc=$(echo "$line" | grep -oE '[\[*\]]')
	decoded=$(echo "$line" | tr "$acc" "$shifted")
done


