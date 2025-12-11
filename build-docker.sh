#!/bin/bash

# Build script for WebMessage .deb package using Docker
# This script builds the Docker image and runs it to create the .deb file

set -e

echo "=========================================="
echo "WebMessage Docker Build Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="webmessage-builder"
CONTAINER_NAME="webmessage-build-container"
OUTPUT_DIR="./output"

# Clean up old container if it exists
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    echo -e "${BLUE}Removing old container...${NC}"
    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
fi

# Build the Docker image
echo -e "${BLUE}Building Docker image...${NC}"
docker build -t ${IMAGE_NAME}:latest .

# Create output directory
mkdir -p ${OUTPUT_DIR}

# Run the container and copy the .deb file
echo ""
echo -e "${BLUE}Running build container...${NC}"
docker run --name ${CONTAINER_NAME} ${IMAGE_NAME}:latest

# Copy the .deb file from the container
echo ""
echo -e "${BLUE}Copying .deb file from container...${NC}"
docker cp ${CONTAINER_NAME}:/build/WebMessage.deb ${OUTPUT_DIR}/

# Clean up container
docker rm ${CONTAINER_NAME}

# Show the result
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Package location: ${GREEN}${OUTPUT_DIR}/WebMessage.deb${NC}"
echo ""
ls -lh ${OUTPUT_DIR}/WebMessage.deb
echo ""
echo -e "${BLUE}Package info:${NC}"
dpkg-deb --info ${OUTPUT_DIR}/WebMessage.deb 2>/dev/null || echo "Install dpkg to view package info"
echo ""
echo -e "${GREEN}You can now install this .deb file on your jailbroken iOS device!${NC}"
