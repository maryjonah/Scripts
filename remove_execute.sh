#!/bin/bash
echo "Usage: $0 <path>"

default_path="." # current path script exists in
ignore_list="$0" # ignore current script

# Check user passed path if not use current path
if [ $# -eq 0 ]; then
  echo "No path defined, using current path '$PWD'"
  path=$default_path
else
  path="$1"
fi

# Modify and display files not in ignore list and have at least 1 execute bit
for item in $ignore_list; do
  find $path ! -path "*$item*" -type f -perm /+x -exec chmod -x {} \; -exec echo "Modified file:" {} \;
done
