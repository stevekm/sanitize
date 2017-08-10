#!/bin/bash

# make tiny sample copies of fastq.gz files
# NOTE: input files must be in a different directory than pwd

input_files="${@:1}" # accept a space separated list of files

for item in $input_files; do
    (
    item_basename="$(basename "$item")"
    zcat "$item" | head -12000 | gzip > "$item_basename"
    )
done

