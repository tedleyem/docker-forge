#!/bin/bash

# Array of Docker image names in repo/image format
docker_images=("manios/nagios" "snipe/snipe-it" "teampasswordmanager/teampasswordmanager")

# Docker Hub username (replace this with your actual username)
docker_username="tedleyem"

# Function to get the latest tag for a given Docker image
get_latest_tag() {
  local image=$1
  echo "Getting the latest tag for image: $image" && sleep 1
  
  # Using the Docker Hub API to fetch the latest tag (1 tag only)
  response=$(curl -s "https://hub.docker.com/v2/repositories/$image/tags?page_size=1")
  
  # Check if the 'results' field is null or empty
  if [[ $(echo "$response" | jq -r '.results | length') -eq 0 ]]; then
    echo "Error: No tags found for image: $image"
    return 1  # Return a non-zero status to indicate failure
  fi
  
  # Grab and return the latest tag (first one)
  latest_tag=$(echo "$response" | jq -r '.results[0].name')
  echo "$latest_tag"
}

# Function to pull, tag, and push the image
pull_tag_push_image() {
  local image=$1
  local latest_tag=$2

  echo "Pulling $image:$latest_tag..."
  # Pull the image with the latest tag
  docker pull "$image:$latest_tag"
  
  # Tag the image with the new name (tedleyem/image_name:latest_tag)
  local new_tag="$docker_username/$(echo "$image" | cut -d'/' -f2):$latest_tag"
  echo "Tagging $image:$latest_tag as $new_tag..."
  docker tag "$image:$latest_tag" "$new_tag"
  
  # Push the newly tagged image to Docker Hub
  echo "Pushing $new_tag to Docker Hub..."
  docker push "$new_tag"
}

# Function to validate Docker image reference format
is_valid_docker_image() {
  local image=$1
  # Regular expression for valid Docker image format (repo/image) that allows uppercase letters
  if [[ ! "$image" =~ ^[a-zA-Z0-9]+(?:[._-][a-zA-Z0-9]+)*\/[a-zA-Z0-9]+(?:[._-][a-zA-Z0-9]+)*$ ]]; then
    echo "Error: Invalid Docker image reference format: $image"
    return 1
  fi
  return 0
}

# Function to check if the user is logged in to Docker
docker_login_check() {
  if ! docker info > /dev/null 2>&1; then
    echo "You are not logged in to Docker. Please log in now."
    docker login
    if [ $? -ne 0 ]; then
      echo "Docker login failed. Exiting script."
      exit 1
    fi
  else
    echo "Docker is already logged in."
  fi
}

# Perform Docker login check before proceeding
docker_login_check

# Loop through the array of Docker images in repo/image format
for image in "${docker_images[@]}"; do
  echo "--------------------------------------------------"
  
  # Check if the image format is valid
  if ! is_valid_docker_image "$image"; then
    echo "Invalid reference format for image: $image. Exiting script."
    exit 1  # Exit the script if an invalid reference is found
  fi

  # Get the latest tag for the current image
  latest_tag=$(get_latest_tag "$image")
  
  if [ $? -ne 0 ]; then
    echo "Failed to get the latest tag for image: $image. Exiting script."
    exit 1  # Exit the script if an error occurs
  fi
  
  # Pull, tag, and push the image
  pull_tag_push_image "$image" "$latest_tag"
done

echo "Successfully pulled, tagged, and pushed all images."
