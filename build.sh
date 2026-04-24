#!/bin/bash

# Build script for rpicam-apps inside a Docker container

set -e

echo "🚀 Starting rpicam-apps build in Docker..."

# Check that source/ directory exists and is not empty
if [ ! -d "source" ] || [ -z "$(ls -A source 2>/dev/null)" ]; then
    echo "Error: source/ directory is missing or empty."
    echo "Run ./init.sh or manually: git clone <repo> source"
    exit 1
fi

# Create the apps directory if it does not exist
mkdir -p apps

# Check whether the base image exists
if ! docker image inspect rpicam-apps-base:latest >/dev/null 2>&1; then
    echo "📦 Base image not found. Building base image with dependencies..."
    echo "⚠️  This will take a while, but only happens once!"
    docker build -f Dockerfile.base -t rpicam-apps-base:latest .
    echo "✅ Base image created!"
else
    echo "✓ Base image already exists. Using cached version."
fi

# Read version from VERSION file
PKGVERSION=$(cat VERSION)
echo "📋 Package version: ${PKGVERSION}"

# Build the Docker image
echo "📦 Building rpicam-apps Docker image..."
docker build --build-arg PKGVERSION="${PKGVERSION}" -t rpicam-apps-builder .

# Run the container and extract the built package
echo "🔨 Compiling and extracting the built package..."
docker run --rm -v "$(pwd)/apps:/apps" rpicam-apps-builder

echo "✅ Build complete! The package is located in the apps/ directory."
ls -lh apps/
