#!/bin/bash

if [ $# -ne 1 ];then
	echo "Usage $0 <device>"
	exit 1
fi

wakeUp="/proc/apci/wakeup"
device="$1"

if ! grep -q "$device" "$wakeUp"; then
	echo "Device not found"
	exit 2
fi



while IFS= read -r line;do
	
	dev=$(echo "$line" | cut -d' ' -f1)
	status=$(echo "$line" | cut -d ' ' -f3 | sed 's/\*//')

	if [ "$dev" != "$device" ];then
		continue
	fi

	# if the task only wants to change status to disabled ?
	if [ "$status" == "disabled" ];then
		echo "Device status is already disabled"
	elif [ "$status" == "enabled" ];then
		echo "Disabling $dev"
		echo "$dev" > "$wakeup"
	fi
	break


done < <(tail -n +2 "$wakeUp" | tr -s ' ')



