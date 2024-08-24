#!/bin/sh

# Loop through all files to properly rename them
for file in "$(pwd)/contracts/output"/*; do

  base_name=$(basename "$file")
  extension="${base_name##*.}"

  new_name=""

  # Handle JSON files specifically
  if [[ "$extension" == "json" ]]; then
    contract_name=$(echo "$base_name" | sed 's/sources_\([^_]*\)_sol_.*\.json/\1/')

    # Check if contract_name already ends with '_meta'
    if [[ ! "$contract_name" == *_meta.json ]]; then
      new_name="${contract_name}_meta.json"
    else
      new_name="$base_name"
    fi

    # If the name already matches the expected, skip the file
    if [[ "$base_name" == "$new_name" ]]; then
      continue
    fi
  # Handle the rest of files
  else
    new_name=$(echo "$base_name" | sed 's/sources_\(.*\)_sol_\(.*\)\.\(.*\)/\1.\3/')

    # If the name already matches the expected, skip the file
    if [[ "$base_name" == "$new_name" ]]; then
      continue
    fi
  fi

  # Rename the file if the names do not match
  mv "$file" "$(pwd)/contracts/output/$new_name"
done
