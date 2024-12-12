#!/bin/bash

# ============================================
# Script Name: Install APK to Multiple Devices with Summary Notification
# Description:
#   Installs an APK on multiple devices and sends a summary notification to Discord.
# ============================================

# Discord webhook URL (set your webhook URL here)
WEBHOOK_URL="https://discord.com/api/webhooks/1311476511911444560/Yy3qKKnj0CvQ21qaD34K0s1YfL7fKCjKjTBEb8I2k3p6S06V3BAEHkwAv4m4Fx6INGps"

# Set default URLs
APK_URL="${APK_URL:-https://github.com/yuliskov/SmartTube/releases/download/latest/smarttube_beta.apk}"
ADB_TOOLS_URL="${ADB_TOOLS_URL:-https://dl.google.com/android/repository/platform-tools-latest-linux.zip}"

# Temporary directory for downloads
TMP_DIR=$(mktemp -d)
APK_PATH="$TMP_DIR/smarttube_beta.apk"
ADB_ZIP="$TMP_DIR/platform-tools-latest-linux.zip"
ADB_FOLDER="$TMP_DIR/platform-tools"
ADB_PATH="$ADB_FOLDER/adb"

# Cleanup function
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Summary results
RESULTS=()

# Append results to the summary
append_result() {
    local device="$1"
    local status="$2"
    RESULTS+=("- $device: $status")
}

# Send a single Discord notification
send_discord_summary() {
    local summary=$(printf "%s\n" "${RESULTS[@]}")

    # JSON payload for the webhook
    local payload=$(cat <<EOF
{
  "embeds": [
    {
      "title": "APK Installation Summary",
      "description": "$(echo "$summary" | sed ':a;N;$!ba;s/\n/\\n/g')",
      "color": 3447003
    }
  ]
}
EOF
)

    # Send the message using curl
    curl -H "Content-Type: application/json" -X POST -d "$payload" "$WEBHOOK_URL"
}

# Check for device IP arguments
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <device_ip_1> [device_ip_2] ..."
    exit 1
fi

DEVICE_IPS=("$@")

# Ensure required tools are installed
if ! command -v curl >/dev/null || ! command -v unzip >/dev/null; then
    append_result "Script" "Missing required tools (curl or unzip)."
    send_discord_summary
    exit 1
fi

# Download ADB tools if not already downloaded
if [[ ! -f "$ADB_PATH" ]]; then
    curl -L -o "$ADB_ZIP" "$ADB_TOOLS_URL"
    if [[ $? -ne 0 ]]; then
        append_result "Script" "Failed to download ADB tools."
        send_discord_summary
        exit 1
    fi
    unzip -q "$ADB_ZIP" -d "$TMP_DIR" || { append_result "Script" "Failed to extract ADB tools."; send_discord_summary; exit 1; }
fi

# Download the APK
curl -L -o "$APK_PATH" "$APK_URL"
if [[ $? -ne 0 ]]; then
    append_result "Script" "Failed to download APK."
    send_discord_summary
    exit 1
fi
append_result "Script" "APK downloaded successfully."

# Iterate through each device IP
for DEVICE_IP in "${DEVICE_IPS[@]}"; do
    echo "Processing device at $DEVICE_IP..."

    # Connect to the device
    "$ADB_PATH" connect "$DEVICE_IP:5555"
    if [[ $? -ne 0 ]]; then
        append_result "$DEVICE_IP" "Failed to connect."
        continue
    fi

    # Install the APK
    "$ADB_PATH" install -t "$APK_PATH"
    if [[ $? -ne 0 ]]; then
        append_result "$DEVICE_IP" "Failed to install APK."
    else
        append_result "$DEVICE_IP" "APK installed successfully."
    fi

    # Disconnect from the device
    "$ADB_PATH" disconnect
    if [[ $? -ne 0 ]]; then
        append_result "$DEVICE_IP" "Installed, but failed to disconnect."
    fi
done

# Send the summary notification
send_discord_summary
echo "All done!"
