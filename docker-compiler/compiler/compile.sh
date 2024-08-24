#!/bin/sh


# Constants
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
SCRIPT_DIR=$(dirname "$(realpath "$0")")
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
