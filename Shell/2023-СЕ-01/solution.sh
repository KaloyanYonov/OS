#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage $0 <csvFile> <starType>"
    exit 1
fi
if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    echo "Must be a readable file"
    exit 2
fi

file="$1"
userType="$2"

TMPFILE=$(mktemp)
winnerConst=""
maxCount=0

grep "$userType" "$file" > "$TMPFILE"

while IFS=',' read -r _ _ _ constellation _ _ _; do
    curr=$(grep -c "$constellation" "$TMPFILE")
    if [ "$curr" -gt "$maxCount" ]; then
        maxCount="$curr"
        winnerConst="$constellation"
    fi
done < "$TMPFILE"

#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage $0 <csvFile> <starType>"
    exit 1
fi
if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    echo "Must be a readable file"
    exit 2
fi

file="$1"
userType="$2"

TMPFILE=$(mktemp)
winnerConst=""
maxCount=0

grep "$userType" "$file" > "$TMPFILE"

while IFS=',' read -r _ _ _ constellation _ _ _; do
    curr=$(grep -c "$constellation" "$TMPFILE")
    if [ "$curr" -gt "$maxCount" ]; then
        maxCount="$curr"
        winnerConst="$constellation"
    fi
done < "$TMPFILE"

#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage $0 <csvFile> <starType>"
    exit 1
fi
if [ ! -f "$1" ] || [ ! -r "$1" ]; then
    echo "Must be a readable file"
    exit 2
fi

file="$1"
userType="$2"

TMPFILE=$(mktemp)
winnerConst=""
maxCount=0

grep "$userType" "$file" > "$TMPFILE"

while IFS=',' read -r _ _ _ constellation _ _ _; do
    curr=$(grep -c "$constellation" "$TMPFILE")
    if [ "$curr" -gt "$maxCount" ]; then
        maxCount="$curr"
        winnerConst="$constellation"
    fi
done < "$TMPFILE"

grep "$winnerConst" "$file" | grep -v ',--$' | sort -t',' -k7,7n | head -n 1 | cut -d',' -f1

