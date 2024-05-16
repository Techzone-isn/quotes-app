#!/bin/bash

# Set variables
IMAGE_NAME="quote"
TAG="latest"

# Prompt for Docker Hub credentials
read -p "Enter your Docker Hub username: " DOCKER_USERNAME
read -s -p "Enter your Docker Hub password: " DOCKER_PASSWORD
echo

DOCKER_REPO="$DOCKER_USERNAME/$IMAGE_NAME"

# Login to Docker Hub
echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

# Build the Docker image
docker build -t $DOCKER_REPO:$TAG .

# Push the image to Docker Hub
docker push $DOCKER_REPO:$TAG

# Logout from Docker Hub
docker logout

echo "Build and push completed."