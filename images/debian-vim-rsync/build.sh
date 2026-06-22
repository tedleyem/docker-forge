#!/usr/bin/env bash
set -e

IMAGE_NAME="tedleyem/debian-jumper"
TAG="latest"

echo "Building Docker image: ${IMAGE_NAME}:${TAG}..."
docker build -t "${IMAGE_NAME}:${TAG}" .

echo "Pushing Docker image to registry..."
docker push "${IMAGE_NAME}:${TAG}"

echo "Successfully built and pushed ${IMAGE_NAME}:${TAG}"
