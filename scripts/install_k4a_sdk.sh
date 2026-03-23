#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

echo "-------------------------------------------------------"
echo "Installing Azure Kinect SDK 1.4.2 for Ubuntu 22.04"
echo "-------------------------------------------------------"

# 1. Update and install base dependencies
sudo apt-get update
sudo apt-get install -y curl libusb-1.0-0 libgl1 libsoundio-dev libglfw3-dev libx11-dev

# 2. Fix OpenSSL 1.1 Compatibility
# Required by the proprietary Depth Engine binary
echo "Installing OpenSSL 1.1 legacy support..."
curl -sSL http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb -o /tmp/libssl1.1.deb
sudo dpkg -i /tmp/libssl1.1.deb && rm /tmp/libssl1.1.deb

# 3. Fix libsoundio 1.1.0 Compatibility
# Ubuntu 22.04 has version 2.0+, but the SDK expects 1.1.0
echo "Installing libsoundio1 (v1.1.0) legacy support..."
curl -sSL http://archive.ubuntu.com/ubuntu/pool/universe/libs/libsoundio/libsoundio1_1.1.0-1_amd64.deb -o /tmp/libsoundio1.deb
sudo dpkg -i /tmp/libsoundio1.deb && rm /tmp/libsoundio1.deb

# 4. Extract Azure Kinect SDK 1.4.2 Binaries
echo "Downloading and extracting SDK 1.4.2 packages..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

BASE_URL="https://packages.microsoft.com/ubuntu/18.04/prod/pool/main"

curl -sSLO "${BASE_URL}/libk/libk4a1.4/libk4a1.4_1.4.2_amd64.deb"
curl -sSLO "${BASE_URL}/libk/libk4a1.4-dev/libk4a1.4-dev_1.4.2_amd64.deb"
curl -sSLO "${BASE_URL}/k/k4a-tools/k4a-tools_1.4.2_amd64.deb"

for f in *.deb; do dpkg-deb -x "$f" .; done

# 5. Deploy to system paths (/usr)
echo "Deploying files to /usr/..."
sudo cp -r usr/* /usr/

# 6. Setup Depth Engine and Shared Libraries
# This creates the symlink so the linker finds libdepthengine.so
sudo ln -sf /usr/lib/x86_64-linux-gnu/libdepthengine.so.2.0 /usr/lib/x86_64-linux-gnu/libdepthengine.so
sudo ldconfig

# 7. Setup UDEV Rules (Access for non-root users)
echo "Setting up UDEV rules..."
sudo cp /usr/lib/x86_64-linux-gnu/libk4a1.4/99-k4a.rules /etc/udev/rules.d/

cd - && rm -rf "$TEMP_DIR"

echo "-------------------------------------------------------"
echo "Installation Successful!"
echo "You can now use: k4aviewer, k4arecorder"
echo "-------------------------------------------------------"