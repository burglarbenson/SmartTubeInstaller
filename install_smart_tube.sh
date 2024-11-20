#!/bin/bash

# ============================================
# Script Name: Install APK to Multiple Devices
# Description:
#   This script automates the process of downloading the SmartTube APK,
#   downloading ADB tools if not already available, and installing the APK
#   on one or more devices specified by their IP addresses.
# 
# Features:
#   - Downloads the latest SmartTube APK from GitHub.
#   - Automatically downloads ADB tools if not already present.
#   - Installs the APK on multiple devices by connecting via their IPs.
#   - Handles errors gracefully, skipping devices where a step fails.
# 
# Prerequisites:
#   - Ensure `curl` and `unzip` are installed on the system.
#   - Ensure the target devices are accessible via ADB over network.
# 
# Usage:
#   1. Update the DEVICE_IPS variable with the IP addresses of your devices.
#   2. Make the script executable: chmod +x install_apk.sh
#   3. Run the script: ./install_smart_tube.sh
# 
# ============================================


# Define device IPs or hostnames
DEVICE_IPS=("shield" "192.168.1.25") # Replace with actual IPs

# Set variables
FOLDER="$(dirname "$0")"
APK_PATH="$FOLDER/stnbeta.apk"
ADB_FOLDER="$FOLDER/platform-tools"
ADB_PATH="$ADB_FOLDER/adb"
APK_URL="https://github.com/yuliskov/SmartTube/releases/download/latest/smarttube_beta.apk"
ADB_TOOLS_URL="https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
ADB_ZIP="$FOLDER/platform-tools-latest-linux.zip"

# Download ADB tools if not present
if [[ ! -f "$ADB_PATH" ]]; then
    echo "ADB tools not found. Downloading..."
    curl -L -o "$ADB_ZIP" "$ADB_TOOLS_URL"
    if [[ $? -ne 0 ]]; then
        echo "Failed to download ADB tools."
        exit 1
    fi
    echo "Extracting ADB tools..."
    unzip -q "$ADB_ZIP" -d "$FOLDER"
    if [[ $? -ne 0 ]]; then
        echo "Failed to extract ADB tools."
        exit 1
    fi
    rm "$ADB_ZIP"
    echo "ADB tools downloaded and extracted."
fi

# Download the APK
echo "Downloading APK..."
curl -L -o "$APK_PATH" "$APK_URL"
if [[ $? -ne 0 ]]; then
    echo "Failed to download APK."
    exit 1
fi
echo "Download complete."

# Iterate through each device IP
for DEVICE_IP in "${DEVICE_IPS[@]}"; do
    echo "Processing device at $DEVICE_IP..."

    # Connect to the device
    echo "Connecting to $DEVICE_IP..."
    "$ADB_PATH" connect "$DEVICE_IP:5555"
    if [[ $? -ne 0 ]]; then
        echo "Failed to connect to $DEVICE_IP."
        continue
    fi

    # Install the APK
    echo "Installing APK on $DEVICE_IP..."
    "$ADB_PATH" install -t "$APK_PATH"
    if [[ $? -ne 0 ]]; then
        echo "Failed to install APK on $DEVICE_IP."
    else
        echo "Successfully installed APK on $DEVICE_IP."
    fi

    # Disconnect from the device
    echo "Disconnecting from $DEVICE_IP..."
    "$ADB_PATH" disconnect
    if [[ $? -ne 0 ]]; then
        echo "Failed to disconnect from $DEVICE_IP."
    else
        echo "Disconnected from $DEVICE_IP."
    fi

done

echo "All done!"
