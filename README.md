# Building rpicam-apps in Docker on Raspberry Pi

This project contains the configuration for cross-compiling rpicam-apps in a Docker container on a Raspberry Pi 4/5, targeting Raspberry Pi Zero.

Building directly on a Raspberry Pi Zero (even 2W) is impractical due to its limited resources, so the intended workflow is to build on a more powerful Pi and deploy the resulting `.deb` package to the Zero.

> **Environment note:** The Docker base image is based on **Raspberry Pi OS (Debian Trixie)** — the same OS as the target Raspberry Pi Zero — to ensure binary compatibility.

> **Note on libcamera:** Since libcamera is not available in the standard Debian repositories, the base image adds the Raspberry Pi apt repository (`archive.raspberrypi.com`) and installs libcamera from there as a pre-built package.

## Requirements

- Raspberry Pi OS (Debian Trixie)
- Docker

## Build Architecture

The project uses a two-stage Docker build for efficiency:

1. **Base image** (`rpicam-apps-base`) — contains all system dependencies and libraries
2. **Builder image** (`rpicam-apps-builder`) — uses the base image to compile the source code

## Initialization

Before building, the `source/` directory must contain the rpicam-apps source code.

**Option A — using the init script (recommended):**

```bash
./init.sh
```

The script will prompt you to choose between:
- `videoreg/rpicam-apps` — fork with videoreg-specific patches
- `raspberrypi/rpicam-apps` — official upstream

**Option B — manual clone:**

```bash
# videoreg fork
git clone --depth=1 https://github.com/videoreg/rpicam-apps.git source

# or official upstream
git clone --depth=1 https://github.com/raspberrypi/rpicam-apps.git source
```

## Usage

### Versioning

The package version is stored in the [`VERSION`](VERSION) file. To change it, edit that file before building:

```bash
echo "1.1" > VERSION
./build.sh
```

The build script reads `VERSION` automatically and passes it to Docker via `--build-arg`. For a manual build, pass it explicitly:

```bash
docker build --build-arg PKGVERSION="$(cat VERSION)" -t rpicam-apps-builder .
```

If you build without specifying `PKGVERSION`, Docker will use the default value defined in `ARG` inside the Dockerfile.

### Quick build

Just run the build script:

```bash
./build.sh
```

This script will:
1. Check whether the base image exists (creates it automatically on first run)
2. Read the version from the `VERSION` file
3. Compile rpicam-apps inside the container
4. Copy the resulting `.deb` package into the `apps/` directory

**Note:** The first build will take longer (creating the base image), but subsequent builds will be much faster!

### Manual build

If you want to build manually:

```bash
# Create the output directory
mkdir -p apps

# Build the Docker image
docker build --build-arg PKGVERSION="$(cat VERSION)" -t rpicam-apps-builder .

# Run the container and retrieve the built package
docker run --rm -v "$(pwd)/apps:/apps" rpicam-apps-builder
```

## Output

After a successful build, the `apps/` directory will contain the Debian package:

- `rpicam-apps_<version>-1_arm64.deb`

Install it on the Raspberry Pi to get the following binaries:

- rpicam-hello
- rpicam-jpeg
- rpicam-raw
- rpicam-still
- rpicam-vid
- rpicam-detect

## Build Flags

Meson is configured with the following flags:

- `-Denable_libav=enabled` — libav (FFmpeg) support
- `-Denable_opencv=enabled` — OpenCV support
- `-Denable_drm=disabled` — no DRM
- `-Denable_egl=disabled` — no EGL
- `-Denable_qt=disabled` — no Qt GUI
- `-Denable_tflite=disabled` — no TensorFlow Lite
- `-Denable_hailo=disabled` — no Hailo AI

## Image Management

### Listing images

```bash
# List Docker images
docker images | grep rpicam

# Image sizes
docker images rpicam-apps-base
docker images rpicam-apps-builder
```

### Cleanup

```bash
# Remove the builder image
docker rmi rpicam-apps-builder

# Remove the base image (will be recreated on next build)
docker rmi rpicam-apps-base

# Remove both images
docker rmi rpicam-apps-builder rpicam-apps-base
```

## Troubleshooting

### Build failures

If the build fails, try:

```bash
# Rebuild without cache
docker build --no-cache -t rpicam-apps-builder .

# Or fully rebuild both images
docker rmi rpicam-apps-builder rpicam-apps-base
./build.sh
```

### Updating dependencies

If you need to update packages in the base image:

```bash
./rebuild-base.sh
```

### Viewing build logs

```bash
# Verbose build output
docker build --progress=plain -t rpicam-apps-builder .
```

### Installing on the Raspberry Pi

```bash
scp ./apps/rpicam-apps_$(cat VERSION)-1_arm64.deb pi@<HOST>:/home/pi

sudo apt remove rpicam-apps-core rpicam-apps

sudo dpkg --force-overwrite -i rpicam-apps_$(cat VERSION)-1_arm64.deb
```
