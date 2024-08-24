#!/bin/sh


# ARGS
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
PACK_OUTPUT="false"
KEEP_UNPACKED_FILES="false"

while [ $# -gt 0 ]; do
  case "$1" in
    --pack)
      PACK_OUTPUT="true"
      shift
      ;;
    --keep-unpacked)
      KEEP_UNPACKED_FILES="true"
      shift
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Args validation
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
if [ "$PACK_OUTPUT" == "false" ] && [ "$KEEP_UNPACKED_FILES" == "true" ]; then
  echo "Argument --keep-unpacked can only be using along with --pack."
  exit 1
fi
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Running the script to do the actual contracts compilation
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
$SCRIPT_DIR/scripts/compile-contracts.sh
if [ $? -ne 0 ]; then
  exit 1
fi
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Running the script to normalize the name of the compiled contracts
# The reason for this is because solc generates filenames differently
# depending on whether you compiled a single contract or multiple ones
# in the same compilation process.
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
$SCRIPT_DIR/scripts/rename-contracts.sh
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Running the script to pack the contracts compiled files
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
if [ "$PACK_OUTPUT" == "true" ]; then
  if [ "$KEEP_UNPACKED_FILES" == "true" ]; then
    $SCRIPT_DIR/scripts/pack-output.sh --keep-unpacked
  else
    $SCRIPT_DIR/scripts/pack-output.sh
  fi
fi
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
