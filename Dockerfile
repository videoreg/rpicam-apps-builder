# Use the pre-built base image with dependencies
FROM rpicam-apps-base:latest

ARG PKGVERSION=1.0

# Copy sources into the container (keeps local files unmodified)
COPY source/ /build/

# Configure and build with the specified flags
RUN meson setup --wipe build \
    -Denable_libav=enabled \
    -Denable_drm=disabled \
    -Denable_egl=disabled \
    -Denable_qt=disabled \
    -Denable_opencv=enabled \
    -Denable_tflite=disabled \
    -Denable_hailo=disabled && \
    ninja -C build

# Create the output directory
RUN mkdir -p /output

# Package the build as a .deb using checkinstall
RUN checkinstall --pkgname=rpicam-apps \
    --pkgversion="${PKGVERSION}" \
    --backup=no \
    --deldoc=yes \
    --fstrans=no \
    --default \
    ninja -C build install

# Move the resulting .deb to the output directory
RUN mv *.deb /output/

# On container start, copy the .deb to the mounted /apps volume
CMD ["sh", "-c", "cp /output/*.deb /apps/"]
