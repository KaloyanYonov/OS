#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <dir> <output.svg>"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "$1 must be a directory"
    exit 2
fi

dir="$1"
output="$2"
graphFile=$(mktemp)

while IFS= read -r file; do

    while IFS= read -r line; do
        if [ -z "$line" ]; then
            continue
        fi

        if echo "$line" | grep -qE '^class [A-Za-z_]'; then
            className=$(echo "$line" | cut -d' ' -f2)

            echo "$className" >> "$graphFile"

            if echo "$line" | grep -q ':'; then
                parents=$(echo "$line" | cut -d':' -f2)

                while IFS= read -r parent; do
                    
                    parentName=$(echo "$parent" | grep -oE '[A-Za-z_][A-Za-z0-9_]*$')

                    if [ -n "$parentName" ]; then
                        echo "$parentName" >> "$graphFile"
                        echo "$parentName -> $className" >> "$graphFile"
                    fi
                done < <(echo "$parents" | tr ',' '\n')
            fi
        fi

    done < "$file"
done < <(find "$dir" -type f -name "*.h")

dag-ger "$graphFile" > "$output"
rm -f "$graphFile"
