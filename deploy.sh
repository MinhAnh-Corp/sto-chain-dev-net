#!/bin/bash

# Step 1: Pull latest code from GitHub
echo "Pulling latest code from GitHub..."
git pull origin main

# Step 2: Determine new version
VERSION=$(git rev-parse --short HEAD)  # Use commit hash as version
IMAGE_NAME="stochain-node:$VERSION"

# Step 3: Rebuild Docker image with new version
echo "Building Docker image with version $VERSION..."
docker build -t $IMAGE_NAME .

# Step 4: Stop and remove old containers
echo "Stopping and removing old containers..."
docker-compose down

# Step 5: Run new containers with updated image
echo "Starting new containers with image $IMAGE_NAME..."
IMAGE_NAME=$IMAGE_NAME docker-compose up -d

echo "Deployment completed successfully with version $VERSION!"