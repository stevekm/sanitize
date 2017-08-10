#!/bin/bash

## USAGE: sanitize.sh /path/to/dir
## DESCRIPTION: This script will replace all occurences of items in column 1 with item in column 2

dir_to_clean="$1"
replace_file="replace.tsv"


cat "$replace_file" | while read line; do
    if [ ! -z "$line" ]; then
        find_pattern="$(echo "$line" | cut -f1)"
        replace_pattern="$(echo "$line" | cut -f2)"
        printf "%s, %s\n" "$find_pattern" "$replace_pattern"
        find "$dir_to_clean" -type f -exec sed -i "s/$find_pattern/$replace_pattern/g" {} \;
        find "$dir_to_clean" -type f -exec grep -l "$find_pattern" {} \;
    fi
done
