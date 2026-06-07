#!/bin/bash

# Fetch DockerHub credentials from environment variables (GitHub Secrets)
DOCKER_USERNAME=$DOCKER_USERNAME
DOCKER_PASSWORD=$DOCKER_PASSWORD

# Loop through all subdirectories
for dir in */; do
  # Check if the directory contains a Dockerfile
  if [ -f "$dir/Dockerfile" ]; then
    # Get the name of the directory (remove trailing slash)
    dir_name=$(basename "$dir")
    
    # Full image name with DockerHub username and repository name
    image_name="$DOCKER_USERNAME/$dir_name"
    
    # Log in to DockerHub using the provided credentials
    echo "Logging in to Docker Hub..."
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    
    # Build the Docker image and tag it with the directory name
    echo "Building Docker image for $dir_name..."
    docker build -t "$image_name" "$dir"
    
    # Push the image to DockerHub
    echo "Pushing Docker image to DockerHub: $image_name"
    docker push "$image_name"
  else
    echo "No Dockerfile found in $dir"
  fi
done
