#!/bin/bash

maxNumber=0
numbers=""

while IFS= read -r number; do
    if ! echo "$number" | grep -qE '^-?[0-9]+$'; then
        continue
    fi
    absoluteNumber=${number#-}
    numbers="$numbers $number" 
    if [ "$absoluteNumber" -gt "$maxNumber" ]; then
        maxNumber="$absoluteNumber"
    fi
done

for number in $numbers; do
    absoluteNumber=${number#-}
    if [ "$absoluteNumber" -eq "$maxNumber" ]; then
        echo "$number"
    fi
done | sort -u  

# б)

#!/bin/bash
maxSum=0
numbers=""

while IFS= read -r number; do
    if ! echo "$number" | grep -qE '^-?[0-9]+$'; then
        continue
    fi
    
    absoluteNumber=${number#-}
    # to keep numbers tracked for nex4t for loop
    numbers="$numbers $number"
    
    sum=0
    while IFS= read -r digit; do
        sum=$(( sum + digit ))
    done < <(echo "$absoluteNumber" | grep -o '.')
    
    if [ "$sum" -gt "$maxSum" ]; then
        maxSum="$sum"
    fi
    
done

minNumber=""
for number in $numbers; do
    absoluteNumber=${number#-}
    
    sum=0
    while IFS= read -r digit; do
        sum=$(( sum + digit ))
    done < <(echo "$absoluteNumber" | grep -o '.')
    
    if [ "$sum" -eq "$maxSum" ]; then
        if [ -z "$minNumber" ] || [ "$number" -lt "$minNumber" ]; then
            minNumber="$number"
        fi
    fi
done

echo "$minNumber" | sort -un

