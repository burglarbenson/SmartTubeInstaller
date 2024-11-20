#!/bin/bash

# ============================================
# Script Name: Install APK to Multiple Devices
# Description:
#   This script downloads the SmartTube APK and ADB tools (if missing),
#   then installs the APK on devices specified by their IP addresses.
# 
# Features:
#   - Supports multiple devices via command-line arguments.
#   - Downloads necessary files from trusted URLs.
#   - Installs APK and disconnects from devices after completion.
# 
# Usage:
#   ./install_apk.sh <device_ip_1> [device_ip_2] ...
# 
# DISCLAIMER:
#   - Verify the authenticity of URLs and downloaded files before use.
#   - Ensure devices are accessible via ADB over the network.
# ============================================

# Set default URLs (can be overridden via environment variables)
APK_URL="${APK_URL:-https://github.com/yuliskov/SmartTube/releases/download/latest/smarttube_beta.apk}"
ADB_TOOLS_URL="${ADB_TOOLS_URL:-https://dl.google.com/android/repository/platform-tools-latest-linux.zip}"

# Temporary directory for downloads
TMP_DIR=$(mktemp -d)
APK_PATH="$TMP_DIR/smarttube_beta.apk"
ADB_ZIP="$TMP_DIR/platform-tools-latest-linux.zip"
ADB_FOLDER="$TMP_DIR/platform-tools"
ADB_PATH="$ADB_FOLDER/adb"

# Cleanup function to remove temporary files
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Check for device IP arguments
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <device_ip_1> [device_ip_2] ..."
    exit 1
fi

DEVICE_IPS=("$@") # Capture device IPs from arguments

# Ensure required tools are installed
if ! command -v curl >/dev/null; then
    echo "Error: 'curl' is not installed. Please install it and try again."
    exit 1
fi

if ! command -v unzip >/dev/null; then
    echo "Error: 'unzip' is not installed. Please install it and try again."
    exit 1
fi

# Download ADB tools if not already downloaded
if [[ ! -f "$ADB_PATH" ]]; then
    echo "Downloading ADB tools..."
    curl -L -o "$ADB_ZIP" "$ADB_TOOLS_URL"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download ADB tools."
        exit 1
    fi
    echo "Extracting ADB tools..."
    unzip -q "$ADB_ZIP" -d "$TMP_DIR"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to extract ADB tools."
        exit 1
    fi
    echo "ADB tools downloaded and extracted."
fi

# Download the APK
echo "Downloading APK..."
curl -L -o "$APK_PATH" "$APK_URL"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to download APK."
    exit 1
fi
echo "APK downloaded to $APK_PATH."

# Iterate through each device IP
for DEVICE_IP in "${DEVICE_IPS[@]}"; do
    echo "Processing device at $DEVICE_IP..."

    # Connect to the device
    echo "Connecting to $DEVICE_IP..."
    "$ADB_PATH" connect "$DEVICE_IP:5555"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to connect to $DEVICE_IP."
        continue
    fi

    # Install the APK
    echo "Installing APK on $DEVICE_IP..."
    "$ADB_PATH" install -t "$APK_PATH"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to install APK on $DEVICE_IP."
    else
        echo "APK successfully installed on $DEVICE_IP."
    fi

    # Disconnect from the device
    echo "Disconnecting from $DEVICE_IP..."
    "$ADB_PATH" disconnect
    if [[ $? -ne 0 ]]; then
        echo "Warning: Failed to disconnect from $DEVICE_IP."
    else
        echo "Disconnected from $DEVICE_IP."
    fi

done

echo "All done!"
