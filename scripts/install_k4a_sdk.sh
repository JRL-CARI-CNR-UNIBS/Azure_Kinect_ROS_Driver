#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting Azure Kinect SDK installation for Ubuntu 22.04..."

# 1. Install system dependencies
sudo apt-get update
sudo apt-get install -y curl libusb-1.0-0 libgl1 libsoundio-dev

# 2. Fix OpenSSL 1.1 compatibility
# The 18.04 Depth Engine requires libssl1.1, which is missing in 22.04
echo "Installing OpenSSL 1.1 compatibility package..."
curl -sSL http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb -o /tmp/libssl1.1.deb
sudo dpkg -i /tmp/libssl1.1.deb && rm /tmp/libssl1.1.deb

# 3. Extract Azure Kinect SDK 1.4.1 binaries (Ubuntu 18.04 version)
echo "Extracting SDK binaries..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

curl -sSLO https://packages.microsoft.com/ubuntu/18.04/prod/pool/main/libk/libk4a1.4/libk4a1.4_1.4.1_amd64.deb
curl -sSLO https://packages.microsoft.com/ubuntu/18.04/prod/pool/main/libk/libk4a1.4-dev/libk4a1.4-dev_1.4.1_amd64.deb

for f in *.deb; do dpkg-deb -x "$f" .; done

# 4. Deploy to system paths
echo "Deploying files to /usr/..."
sudo cp -r usr/* /usr/

# 5. Fix Depth Engine symbolic link
# This is crucial for the SDK to find the proprietary depth engine binary
sudo ln -sf /usr/lib/x86_64-linux-gnu/libdepthengine.so.2.0 /usr/lib/x86_64-linux-gnu/libdepthengine.so
sudo ldconfig

echo "Azure Kinect SDK installed successfully!"
