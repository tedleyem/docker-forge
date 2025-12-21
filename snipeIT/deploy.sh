#!/bin/bash
# -----------------------------------------------------
# Docker Deployment Script for Build and Sync Operations
# Usage: ./docker-deploy.sh [build | sync | <none>]
# -----------------------------------------------------

# --- Configuration Variables ---
DOCKERHUB_USERNAME="tedleyem"
# Use the Snipe-IT configuration as the primary target
LOCAL_IMAGE_NAME="snipe-it"
LOCAL_TAG="v8.3.6"
DOCKERFILE_PATH="Dockerfile"
BUILD_CONTEXT="."

# --- Derived Variables ---
DOCKERHUB_REPO="${DOCKERHUB_USERNAME}/${LOCAL_IMAGE_NAME}"
FULL_LOCAL_IMAGE="${DOCKERHUB_REPO}:${LOCAL_TAG}"
FULL_REMOTE_IMAGE_TAG="${DOCKERHUB_REPO}:${LOCAL_TAG}"
FULL_REMOTE_IMAGE_LATEST="${DOCKERHUB_REPO}:latest"

# -----------------------------------------------------

## BUILD FUNCTION
build_image() {
    echo "--- Starting Docker Image Build ---"
    
    echo "Building image ${FULL_LOCAL_IMAGE} using ${DOCKERFILE_PATH}..."
    if ! docker build \
        -t "${FULL_LOCAL_IMAGE}" \
        -f "${DOCKERFILE_PATH}" \
        "${BUILD_CONTEXT}"; then
        
        echo "Error: Failed to build image. Exiting."
        return 1
    fi
    echo "---"
    echo "Docker image build complete for ${FULL_LOCAL_IMAGE}!"
    return 0
}

## SYNC FUNCTION
sync_image() {
    echo "--- Starting Docker Image Sync ---"
    echo "Local Image: ${FULL_LOCAL_IMAGE}"
    echo "Remote Repo: ${DOCKERHUB_REPO}"

    # 1. Check if the local image exists
    echo "Checking for local image: ${FULL_LOCAL_IMAGE}..."
    if ! docker image inspect "${FULL_LOCAL_IMAGE}" > /dev/null 2>&1; then
        echo "Error: Local image ${FULL_LOCAL_IMAGE} not found."
        echo "Skipping sync."
        return 1
    fi
    echo "Local image found."

    # 2. Authenticate to Docker Hub
    echo "Authenticating to Docker Hub..."
    if ! docker login; then
        echo "Error: Docker login failed. Skipping sync."
        return 1
    fi

    # 3. Tag the images
    echo "Tagging image as ${FULL_REMOTE_IMAGE_TAG}..."
    if ! docker tag "${FULL_LOCAL_IMAGE}" "${FULL_REMOTE_IMAGE_TAG}"; then
        echo "Error: Failed to tag image with version tag. Exiting."
        return 1
    fi
    echo "Tagging image as ${FULL_REMOTE_IMAGE_LATEST}..."
    if ! docker tag "${FULL_LOCAL_IMAGE}" "${FULL_REMOTE_IMAGE_LATEST}"; then
        echo "Error: Failed to tag image with latest tag. Exiting."
        return 1
    fi

    # 4. Push both tags
    echo "Pushing image tags to Docker Hub..."
    # Pushing both tags separately to ensure clean error messages per tag
    if ! docker push "${FULL_REMOTE_IMAGE_TAG}"; then
        echo "Error: Failed to push version tag ${FULL_REMOTE_IMAGE_TAG}. Continuing with latest..."
    else
        echo "Successfully pushed ${FULL_REMOTE_IMAGE_TAG}"
    fi
    
    if ! docker push "${FULL_REMOTE_IMAGE_LATEST}"; then
        echo "Error: Failed to push latest tag ${FULL_REMOTE_IMAGE_LATEST}. Exiting sync."
        return 1
    else
        echo "Successfully pushed ${FULL_REMOTE_IMAGE_LATEST}"
    fi

    echo "---"
    echo "Sync Complete!"
    echo "The local image has been synced and pushed to:"
    echo "  - ${FULL_REMOTE_IMAGE_TAG}"
    echo "  - ${FULL_REMOTE_IMAGE_LATEST}"
    return 0
}

# -----------------------------------------------------

## MAIN SCRIPT LOGIC
ACTION=${1:-both} # Default action is 'both' if no argument is provided.

case "$ACTION" in
    build)
        build_image
        ;;
    sync)
        sync_image
        ;;
    both)
        # Execute build first, and only proceed to sync if build was successful
        if build_image; then
            echo "--- Proceeding to sync... ---"
            sync_image
        else
            echo "Build failed, skipping sync."
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 [build | sync | both]"
        echo "  - build: Only runs the build step."
        echo "  - sync: Only runs the tag/push step."
        echo "  - both: Runs build, then runs sync (default)."
        exit 1
        ;;
esac