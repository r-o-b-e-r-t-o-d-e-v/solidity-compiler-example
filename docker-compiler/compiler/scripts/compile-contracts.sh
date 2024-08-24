#!/bin/sh


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
for file in $(pwd)/contracts/*.sol; do
  metadata_args+=" /sources/$(basename "$file")"
done
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---


# Run the Docker container, compile the contracts and remove the container
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
docker run --rm \
-v $(pwd)/contracts:/sources \
ethereum/solc:0.8.26-alpine \
--optimize \
--bin \
--abi \
--metadata \
$metadata_args \
-o /sources/output/ \
--overwrite
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
