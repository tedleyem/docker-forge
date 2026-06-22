#!/bin/bash

# Loop through all subdirectories
for dir in */; do
  # Check if the directory contains a docker-compose.yml file
  if [ -f "$dir/docker-compose.yml" ]; then
    echo "Found docker-compose.yml in $dir"

    # Create a kompose directory if it doesn't exist
    kompose_dir="$dir/kompose"
    mkdir -p "$kompose_dir"

    # Run kompose to generate Kubernetes manifest files in the kompose directory
    echo "Generating Kubernetes manifests for $dir using kompose..."
    kompose -f "$dir/docker-compose.yml" convert -o "$kompose_dir/"

    echo "Kubernetes manifests created in $kompose_dir"
  else
    echo "No docker-compose.yml found in $dir"
  fi
done
