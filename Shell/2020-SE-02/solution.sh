#!/bin/bash


if [ $# -ne 1 ]; then
	echo "Usage $0: file"
	exit 1
fi

if [ ! -f "$1" ] || [ ! -r "$1" ]; then
	echo "$1 must be a readable file"
	exit 2
fi

file="$1"

firstCount=0
secondCount=0
thirdCount=0
first=""
second=""
third=""

while IFS= read -r site; do

	siteEsc=$(echo "$site" | sed 's/\./\\./g')
	siteCount=$(grep -cE "^[^ ]+ ${siteEsc} " "$file")

	if [ "$siteCount" -gt "$firstCount" ]; then
		thirdCount=$secondCount
		third=$second
		secondCount=$firstCount
		second=$first
		firstCount=$siteCount
		first=$site
	elif [ "$siteCount" -gt "$secondCount" ]; then
		thirdCount=$secondCount
		third=$second
		secondCount=$siteCount
		second=$site
	elif [ "$siteCount" -gt "$thirdCount" ]; then
		thirdCount=$siteCount
		third=$site
	fi

done < <(cut -d' ' -f2 "$file" | sort -u)

while IFS= read -r site; do

	if [ -z "$site" ];then
		continue
	fi

	siteEsc=$(echo "$site" | sed 's/\./\\./g')
	siteLines=$(grep -E "^[^ ]+ ${siteEsc} " "$file")

	http2Count=0
	otherCount=0
	statusTemp=$(mktemp)

	while IFS= read -r ln; do
		protocol=$(echo "$ln" | cut -d' ' -f8)
		status=$(echo "$ln" | cut -d' ' -f9)
		client=$(echo "$ln" | cut -d' ' -f1)

		if [ "$protocol" = "HTTP/2.0" ]; then
			http2Count=$((http2Count + 1))
		else
			otherCount=$((otherCount + 1))
		fi

		if [ "$status" -gt 302 ]; then
			echo "$client" >> "$statusTemp"
		fi
	done < <(echo "$siteLines")

	echo "$site HTTP/2.0: $http2Count non-HTTP/2.0: $otherCount"

	while read -r cnt client; do
		echo "$cnt $client"
	done < <(sort "$statusTemp" | uniq -c | sort -rn | head -5)

	rm -f "$statusTemp"
done < <(printf '%s\n%s\n%s\n' "$first" "$second" "$third")
