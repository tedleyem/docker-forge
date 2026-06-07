#!/bin/bash 
# build all docker images in subdir's and tag 
# image with name of parent dir. 

DOCKER_USERNAME="tedleyem"

# Loop through all subdirectories
for dir in */; do
  # Check if the directory contains a Dockerfile
  if [ -f "$dir/Dockerfile" ]; then
    # Get the name of the directory (remove trailing slash)
    dir_name=$(basename "$dir")
    
    # Build the Docker image and tag it with the directory name
    echo "Building Docker image for $dir_name..."
    docker build -t "$dir_name" "$dir"
    
    # Optional: Push the image to a repository (if you need to)
    # docker push "$dir_name"
  else
    echo "No Dockerfile found in $dir"
  fi
done


# Loop through all subdirectories
for dir in */; do
  # Check if the directory contains a Dockerfile
  if [ -f "$dir/Dockerfile" ]; then
    # Get the name of the directory (remove trailing slash)
    dir_name=$(basename "$dir")
    
    # Full image name with DockerHub username and repository name
    image_name="$DOCKER_USERNAME/$dir_name"
    
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
