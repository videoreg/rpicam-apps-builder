#!/bin/bash

# Script for rebuilding the base image with dependencies

set -e

echo "🔄 Rebuilding rpicam-apps-base..."
echo "⚠️  This will take a while..."

# Remove the old base image if it exists
if docker image inspect rpicam-apps-base:latest >/dev/null 2>&1; then
    echo "🗑️  Removing old base image..."
    docker rmi rpicam-apps-base:latest
fi

# Build the new base image
echo "📦 Building new base image..."
docker build -f Dockerfile.base -t rpicam-apps-base:latest .

echo "✅ Base image rebuilt successfully!"
echo ""
echo "You can now run ./build.sh to build rpicam-apps"
