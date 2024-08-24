#!/bin/sh


# Accepted args:
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
#
# -c <contracts_folder>   Param to set the location of the contracts.
#                         If not specified, the script will exit.
#
#                         This arg expects the path to be absolute,
#                         no matter the execution context.
#
# -o <output_folder>      Param to set the location of the output
#                         folder the compile files will be generated at.
#
#                         If not specified, the script will exit.
#                         This arg expects the path to be absolute,
#                         no matter the execution context.
#
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# ARGS
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
while [ $# -gt 0 ]; do
  case "$1" in
    -c)
      if [ -n "$2" ]; then
        SOURCES_DIR="$2"
        shift 2
      else
        echo "Error: -o requires a non-empty option argument."
        exit 1
      fi
      ;;
    -o)
      if [ -n "$2" ]; then
        OUTPUT_DIR="$2"
        shift 2
      else
        echo "Error: -o requires a non-empty option argument."
        exit 1
      fi
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
if [ -z "$SOURCES_DIR" ]; then
  echo "No sources directory was specified"
  exit 1
fi

if [ -z "$OUTPUT_DIR" ]; then
  echo "No output directory was specified ($0)"
  exit 1
fi
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Quick checking to make sure Docker is running
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
if ! docker info > /dev/null 2>&1; then
    echo "Docker daemon is not running. Please start Docker and try again."
    exit 1
fi
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Build the metadata param values with all the contracts to be compiled
# This is basically to add several contracts to be compiled at the same time
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
metadata_args=""
for file in "$SOURCES_DIR"/*.sol; do
  metadata_args+=" /sources/$(basename "$file")"
done
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Run the Docker container, compile the contracts and remove the container
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
docker run --rm \
-v "$SOURCES_DIR":/sources \
-v "$OUTPUT_DIR":/output \
ethereum/solc:0.8.26-alpine \
--optimize \
--bin \
--abi \
--metadata \
$metadata_args \
-o /output/ \
--overwrite
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
