#!/bin/bash

# Build script for iOSMB-Server .deb package using Docker
# This script builds the Docker image and runs it to create the .deb file

set -e

echo "=========================================="
echo "iOSMB-Server Docker Build Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="iosmb-builder"
CONTAINER_NAME="iosmb-build-container"
OUTPUT_DIR="./output"

# Clean up old container if it exists
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    echo -e "${BLUE}Removing old container...${NC}"
    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
fi

# Clean output directory
echo -e "${BLUE}Cleaning output directory...${NC}"
rm -rf ${OUTPUT_DIR}/*

# Prune Docker build cache to ensure fresh build
echo -e "${BLUE}Pruning Docker build cache...${NC}"
docker system prune -f

# Check if Swift binary exists
if [ ! -f "iOSMB-Server/Package/usr/bin/iOSMB-Server" ]; then
    echo -e "${RED}ERROR: Swift binary not found!${NC}"
    echo ""
    echo "The Swift binary must be built on macOS first."
    echo "Please run: ./build-swift-macos.sh on a Mac"
    echo ""
    echo "Or push a tag to GitHub to use the automated build with macOS runner."
    exit 1
fi

echo -e "${GREEN}Swift binary found - proceeding with build${NC}"

# Build the Docker image with --no-cache to force fresh build
# Use --platform linux/amd64 to ensure x86_64 image on Apple Silicon Macs
echo -e "${BLUE}Building Docker image (no cache)...${NC}"
docker build --platform linux/amd64 --no-cache -t ${IMAGE_NAME}:latest -f Dockerfile.theos .

# Create output directory
mkdir -p ${OUTPUT_DIR}

# Run the container and copy the .deb file
echo ""
echo -e "${BLUE}Running build container...${NC}"
docker run --platform linux/amd64 --name ${CONTAINER_NAME} ${IMAGE_NAME}:latest

# Copy the .deb file from the container
echo ""
echo -e "${BLUE}Copying .deb file from container...${NC}"
docker cp ${CONTAINER_NAME}:/build/iOSMB-Server.deb ${OUTPUT_DIR}/

# Clean up container
docker rm ${CONTAINER_NAME}

# Show the result
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Package location: ${GREEN}${OUTPUT_DIR}/iOSMB-Server.deb${NC}"
echo ""
ls -lh ${OUTPUT_DIR}/iOSMB-Server.deb
echo ""
echo -e "${BLUE}Package info:${NC}"
dpkg-deb --info ${OUTPUT_DIR}/iOSMB-Server.deb 2>/dev/null || echo "Install dpkg to view package info"
echo ""
echo -e "${GREEN}You can now install this .deb file on your jailbroken iOS device!${NC}"
