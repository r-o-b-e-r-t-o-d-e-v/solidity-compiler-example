#!/bin/sh

PACK_SH_VERSION="1.0.0"

FILES_DIR="$(pwd)/contracts/output"
TARGET_DIR="$FILES_DIR/packed"

# Default value for KEEP_UNPACKED_FILES
KEEP_UNPACKED_FILES="false"

# Parse command-line arguments
for arg in "$@"; do
  case $arg in --keep-unpacked)
      KEEP_UNPACKED_FILES="true"
      shift
      ;;
    *)
      echo "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

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

  echo "Generated $output_file"
done

if [ "$KEEP_UNPACKED_FILES" == "false" ]; then
  find "$FILES_DIR" -maxdepth 1 -type f -exec rm -f {} +
  mv "$TARGET_DIR"/* "$FILES_DIR"
  rm -rf "$TARGET_DIR"
fi
