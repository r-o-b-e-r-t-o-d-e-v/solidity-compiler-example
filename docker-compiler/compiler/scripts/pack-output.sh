#!/bin/sh

PACK_SH_VERSION="1.0.0"


# Accepted args:
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
#
# -o <output_folder>      Param to set the location of the output
#                         folder the compile files will be generated at.
#
#                         If not specified, the script will exit.
#                         This arg expects the path to be absolute,
#                         no matter the execution context.
#
# --keep-unpacked         Flag to tell the script if when packing
#                         the compiled files should also keep the
#                         original ones.
#
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Constants
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Default value for KEEP_UNPACKED_FILES
KEEP_UNPACKED_FILES="false"
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# ARGS
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
while [ $# -gt 0 ]; do
  case "$1" in
    --keep-unpacked)
      KEEP_UNPACKED_FILES="true"
      shift
      ;;
    -o)
      if [ -n "$2" ]; then
        OUTPUT_DIR="$2"
        shift 2
      else
        echo " >> Error: -o requires a non-empty option argument."
        exit 1
      fi
      ;;
    *)
      echo " >> Unknown argument: $1"
      exit 1
      ;;
  esac
done
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Args validation
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
if [ -z "$OUTPUT_DIR" ]; then
  echo " >> No output directory was specified ($0)"
  exit 1
fi
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
FILES_DIR="$OUTPUT_DIR"
TARGET_DIR="$FILES_DIR/packed"
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Generate packed files
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# Creates the directory for packed files
mkdir -p "$TARGET_DIR"

# Iterate over each .abi file in the directory
for abi_file in "$FILES_DIR"/*.abi; do

  # Get the base name of the file (e.g., "DummyContract" or "SimpleToken")
  base_name=$(basename "$abi_file" .abi)

  # Define the corresponding .bin file
  bin_file="$FILES_DIR/$base_name.bin"

  # Define the output JSON file
  output_file="$TARGET_DIR/$base_name.json"

  # Read the content of the .abi and .bin files
  abi_content=$(cat "$abi_file")
  bin_content=$(cat "$bin_file")

  # Create the JSON structure and write to the output file
  echo "{" > "$output_file"
  echo "  \"packingVersion\": \"$PACK_SH_VERSION\"," >> "$output_file"
  echo "  \"abi\": $abi_content," >> "$output_file"
  echo "  \"bin\": \"$bin_content\"" >> "$output_file"
  echo "}" >> "$output_file"

  echo " >> Generated $output_file"
done
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Removing originals based on argument
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# If there is no flag to keep the original files, it removes them
if [ "$KEEP_UNPACKED_FILES" == "false" ]; then

  # Delete the original files
  find "$FILES_DIR" -maxdepth 1 -type f -exec rm -f {} +

  # Moves the packed ones to the output directory
  mv "$TARGET_DIR"/* "$FILES_DIR"

  # Removes the packed directory
  rm -rf "$TARGET_DIR"
fi
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
