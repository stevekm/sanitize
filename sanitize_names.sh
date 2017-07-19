#!/bin/bash

## USAGE: sanitize.sh /path/to/dir
## DESCRIPTION: This script will replace all occurences of items in column 1 with item in column 2 in names of files, dirs, or symlinks in the specified directory

dir_to_clean="$1"
replace_file="replace.tsv"

change_name () {
    local item="$1"
    local old_pattern="$2"
    local new_pattern="$3"
    new_basename="$(echo "$(basename "$item")" | sed -e "s|${old_pattern}|${new_pattern}|g")"
    new_name="$(dirname "$item")/${new_basename}"

    printf "%s  :  %s\n" "$item" "$new_name"
    mv "$item" "$new_name"
}

cat "$replace_file" | while read line; do
    if [ ! -z "$line" ]; then
        find_pattern="$(echo "$line" | cut -f1)"
        replace_pattern="$(echo "$line" | cut -f2)"
        printf "%s, %s\n" "$find_pattern" "$replace_pattern"
        find "$dir_to_clean" -name "*$find_pattern*" -print0 | while read -d $'\0' item; do
            change_name "$item" "$find_pattern" "$replace_pattern"
        done
    fi
done
