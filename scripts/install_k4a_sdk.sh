#!/bin/bash
set -e

echo "Starting Azure Kinect SDK 1.4.2 installation for Ubuntu 22.04..."

# 1. System Dependencies
sudo apt-get update
sudo apt-get install -y curl libusb-1.0-0 libgl1 libsoundio-dev libglfw3-dev

# 2. Fix OpenSSL 1.1 (Still required for the 1.4.2 binary)
echo "Installing OpenSSL 1.1 compatibility package..."
curl -sSL http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb -o /tmp/libssl1.1.deb
sudo dpkg -i /tmp/libssl1.1.deb && rm /tmp/libssl1.1.deb

# 3. Extract Azure Kinect SDK 1.4.2 binaries
echo "Extracting SDK 1.4.2 binaries..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

BASE_URL="https://packages.microsoft.com/ubuntu/18.04/prod/pool/main"

# Download 1.4.2 version
curl -sSLO "${BASE_URL}/libk/libk4a1.4/libk4a1.4_1.4.2_amd64.deb"
curl -sSLO "${BASE_URL}/libk/libk4a1.4-dev/libk4a1.4-dev_1.4.2_amd64.deb"
curl -sSLO "${BASE_URL}/k/k4a-tools/k4a-tools_1.4.2_amd64.deb"

for f in *.deb; do dpkg-deb -x "$f" .; done

# 4. Deploy to system paths
echo "Deploying files to /usr/..."
sudo cp -r usr/* /usr/

# 5. Symbolic link for Depth Engine
# The depth engine inside 1.4.2 still needs to be found by the linker
sudo ln -sf /usr/lib/x86_64-linux-gnu/libdepthengine.so.2.0 /usr/lib/x86_64-linux-gnu/libdepthengine.so
sudo ldconfig

echo "Azure Kinect SDK 1.4.2 installed successfully!"