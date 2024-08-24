#!/bin/sh


# Accepted args:
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
#
# -c <contracts_folder>   Param to set the location of the contracts.
#
#                         If not specified, the script will search for
#                         a so called 'contracts' folder in all the
#                         subdirectories from the execution context.
#
#                         This arg expects the path to be related to
#                         the execution context.
#
# -o <output_folder>      Param to set the location of the output
#                         folder the compile files will be generated at.
#
#                         If not specified, the script will search for
#                         a so called 'output' folder in all the
#                         subdirectories from the execution context.
#                         If none is found, it will use the 'contracts'
#                         folder to generate the output files there
#                         (.../contracts/output/*).
#
#                         This arg expects the path to be related to
#                         the execution context.
#
# --pack                  Flag to tell the script to pack the compiled
#                         files so every smart contract just have a
#                         single .json file containing both the abi
#                         and the bin. Otherwise each contract would
#                         have several files (.bin, .abi and _meta).
#
# --keep-unpacked         Flag to tell the script if when packing
#                         the compiled files should also keep the
#                         original ones.
#                         **Requires --pack flag to also be set.
#
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Constants
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Establish a default directory for contracts by finding any folder with that name in subdirectories
CONTRACTS_DIR_DEFAULT=$(find $(pwd) -type d -name 'contracts' -print)
CONTRACTS_DIR="$CONTRACTS_DIR_DEFAULT"

# ---  .  ---  .  ---  .  ---  .  ---  .  ---

# Establish a default directory for output by finding any folder with that name in subdirectories
OUTPUT_DIR_DEFAULT=$(find $(pwd) -type d -name 'output' -print)

# If no output folder exists, creates a default path based on the contracts folder location
if [ -z "$OUTPUT_DIR_DEFAULT" ]; then
    OUTPUT_DIR_DEFAULT="$CONTRACTS_DIR_DEFAULT/output"
fi

OUTPUT_DIR="$OUTPUT_DIR_DEFAULT"
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


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
    -c)
      if [ -n "$2" ]; then
        CONTRACTS_DIR_RELATIVE_PATH="$2"
        shift 2
      else
        echo " >> Error: -c requires a non-empty option argument."
        exit 1
      fi
      ;;
    -o)
      if [ -n "$2" ]; then
        OUTPUT_DIR_RELATIVE_PATH="$2"
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


# Solving contracts directory
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
if [ -z "$CONTRACTS_DIR_RELATIVE_PATH" ]; then
  echo " >> No contracts directory was set. Using default one: $CONTRACTS_DIR_DEFAULT"
else
  CONTRACTS_DIR="$(pwd)/${CONTRACTS_DIR_RELATIVE_PATH#./}"

  TEMP_CONTRACTS_DIR=$(cd $(pwd)/${CONTRACTS_DIR_RELATIVE_PATH#./} && pwd)
  if [ $? -ne 0 ]; then
    echo " >> Invalid contracts directory path"
    exit 1
  fi

  CONTRACTS_DIR="$(cd $TEMP_CONTRACTS_DIR; pwd )"

  if [ "$(basename $CONTRACTS_DIR)" != "contracts" ]; then
    CONTRACTS_DIR="$CONTRACTS_DIR/contracts"
  fi

  if [ ! -d "$CONTRACTS_DIR" ]; then
    echo " >> Invalid contracts directory path"
    exit 1
  fi

  echo " >> Set contracts directory to: $CONTRACTS_DIR"
fi
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Solving output directory
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
if [ -z "$OUTPUT_DIR_RELATIVE_PATH" ]; then
  echo " >> No output directory was set. Using default one: $OUTPUT_DIR_DEFAULT"
else

  TEMP_OUTPUT_DIR_ABSOLUTE="$(pwd | sed 's:/*$::')/${OUTPUT_DIR_RELATIVE_PATH#./}"
  TEMP_OUTPUT_DIR_ABSOLUTE="${TEMP_OUTPUT_DIR_ABSOLUTE%.}"
  TEMP_OUTPUT_DIR_NAME="$(basename $TEMP_OUTPUT_DIR_ABSOLUTE)"

  if [ "$TEMP_OUTPUT_DIR_NAME" != "output" ]; then
    OUTPUT_DIR="${TEMP_OUTPUT_DIR_ABSOLUTE%/}/output"
  else
    OUTPUT_DIR="$TEMP_OUTPUT_DIR_ABSOLUTE"
  fi

  echo " >> Set output directory to: $OUTPUT_DIR"
fi
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Args validation
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
if [ "$PACK_OUTPUT" == "false" ] && [ "$KEEP_UNPACKED_FILES" == "true" ]; then
  echo " >> Argument --keep-unpacked can only be using along with --pack."
  exit 1
fi
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Running the script to do the actual contracts compilation
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
$SCRIPT_DIR/scripts/compile-contracts.sh -c "$CONTRACTS_DIR" -o "$OUTPUT_DIR"
if [ $? -ne 0 ]; then
  echo " >> Compilation process went wrong."
  exit 1
fi
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Running the script to pack the contracts compiled files
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
if [ "$PACK_OUTPUT" == "true" ]; then
  if [ "$KEEP_UNPACKED_FILES" == "true" ]; then
    $SCRIPT_DIR/scripts/pack-output.sh --keep-unpacked -o "$OUTPUT_DIR"
  else
    $SCRIPT_DIR/scripts/pack-output.sh -o "$OUTPUT_DIR"
  fi
fi

if [ $? -ne 0 ]; then
  echo " >> Something went wrong when packing the compile generated files."
  exit 1
fi
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

exit 0
