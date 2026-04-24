#!/bin/bash

# Initialize the source/ directory by cloning rpicam-apps from GitHub

set -e

# Check if source is already populated
if [ -d "source" ] && [ -n "$(ls -A source 2>/dev/null)" ]; then
    echo "Warning: source/ directory already exists and is not empty."
    read -p "Delete it and re-clone? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    rm -rf source
fi

echo ""
echo "Choose the source repository:"
echo "  1) videoreg/rpicam-apps  — fork with videoreg-specific patches"
echo "  2) raspberrypi/rpicam-apps  — official upstream"
echo ""
read -p "Enter choice [1/2]: " choice

case "$choice" in
    1) REPO="https://github.com/videoreg/rpicam-apps.git" ;;
    2) REPO="https://github.com/raspberrypi/rpicam-apps.git" ;;
    *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

echo ""
echo "Cloning $REPO into source/ ..."
git clone --depth=1 "$REPO" source

echo ""
echo "Done! You can now run ./build.sh"
