#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <dir>"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "$1 must be a directory"
    exit 2
fi

dir=$(realpath "$1")

while IFS= read -r link; do

    linkdir=$(dirname "$link")
    target=$(readlink "$link")

    if [[ "$target" = /* ]]; then
        abstarget=$(realpath -m "$target")
    else
        abstarget=$(realpath -m "$linkdir/$target")
    fi

    if [[ "$abstarget" == "$dir"/* ]]; then
        newtarget=$(realpath --relative-to="$linkdir" "$abstarget")
    else
        newtarget="$abstarget"
    fi

    ln -sf "$newtarget" "$link"

done < <(find "$dir" -type l)
