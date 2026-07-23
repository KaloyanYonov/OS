#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <file> <directory>" >&2
    exit 1
fi

if [ ! -d "$2" ]; then
    echo "$2 must be a directory" >&2
    exit 2
fi

csvFile="$1"
dir="$2"

trim() {
    echo "$1" | sed 's/^ *//;s/ *$//'
}

echo "hostname,phy,vlans,hosts,failover,VPN-3DES-AES,peers,VLAN Trunk Ports,license,SN,key" > "$csvFile"

while IFS= read -r file; do
    hostname=$(basename "$file" .log)
    counter=0

    while IFS= read -r line; do
        counter=$((counter + 1))

	#this solution works but only if the order is the same everytime otherwise it breaks, another solution would be to just grep the text for each field and cut
	
        case $counter in
            2) phy=$(trim "$(echo "$line" | cut -d':' -f2)") ;;
            3) vlans=$(trim "$(echo "$line" | cut -d':' -f2)") ;;
            4) hosts=$(trim "$(echo "$line" | cut -d':' -f2)") ;;
            5) failover=$(trim "$(echo "$line" | cut -d':' -f2)") ;;
            6) vpnaes=$(trim "$(echo "$line" | cut -d':' -f2)") ;;
            7) peers=$(trim "$(echo "$line" | cut -d':' -f2)") ;;
            8) trunk=$(trim "$(echo "$line" | cut -d':' -f2)") ;;
            9) license=$(trim "$(echo "$line" | sed -E 's/This platform has an? (.*) license\./\1/')") ;;
            10) sn=$(trim "$(echo "$line" | cut -d':' -f2)") ;;
            11) key=$(trim "$(echo "$line" | cut -d':' -f2)") ;;
        esac

    done < "$file"

    echo "$hostname,$phy,$vlans,$hosts,$failover,$vpnaes,$peers,$trunk,$license,$sn,$key" >> "$csvFile"

done < <(find "$dir" -maxdepth 1 -type f -name "*.log")
