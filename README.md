# **Install SmartTube to Multiple Devices**

## **Overview**
This script automates the process of installing the SmartTube Beta APK on multiple devices over the network using Android Debug Bridge (ADB). It:
- Downloads the latest SmartTube Beta APK.
- Downloads and sets up ADB tools if they are not already available.
- Installs the APK on multiple devices specified by their IP addresses.
- Disconnects from each device after installation.

---

## **Features**
- **Automated Downloads:** 
  - Fetches the latest SmartTube Beta APK from GitHub.
  - Downloads ADB tools automatically if they are missing.
- **Multi-Device Support:** 
  - Supports installation on multiple devices in a single run.
- **Error Handling:** 
  - Skips devices where a connection or installation fails and provides clear error messages.
- **Secure Temporary Files:** 
  - Uses a dedicated temporary directory for file operations, ensuring a clean environment.

---

## **Usage**

### **Prerequisites**
- Ensure your devices support **ADB over Wi-Fi** and have it enabled.
- Install the required dependencies:
  - `curl`: For downloading files.
  - `unzip`: For extracting ADB tools.

On most Linux systems, you can install these with:
```bash
sudo apt install curl unzip  # For Debian/Ubuntu
sudo yum install curl unzip  # For Red Hat/CentOS
brew install curl unzip      # For macOS (Homebrew)
```

### **Steps to Run the Script**
1. Clone this repository:
   ```bash
   git clone https://github.com/burglarbenson/SmartTubeInstaller.git
   cd SmartTubeInstaller
   ```

2. Make the script executable:
   ```bash
   chmod +x install_smart_tube.sh
   ```

3. Run the script with the IP addresses of your devices:
   ```bash
   ./install_smart_tube.sh <device_ip_1> [device_ip_2] ...
   ```
   Replace `<device_ip_1>` and `[device_ip_2]` with the actual IPs of your devices.

4. Example:
   ```bash
   ./install_smart_tube.sh 192.168.0.101 192.168.0.102
   ```

---

## **How It Works**
1. **ADB Tools Setup:**
   - If ADB tools are not found, the script downloads and extracts them to a local directory.
2. **APK Download:**
   - Fetches the latest SmartTube Beta APK from GitHub.
3. **Installation:**
   - For each IP provided, the script:
     - Connects to the device using ADB over Wi-Fi.
     - Installs the APK using ADB.
     - Disconnects after installation.

---

## **Customizing the Script**
- **Change the APK URL:**
  - To use a different APK, update the `APK_URL` variable in the script with your desired APK download link.
  
- **Change the ADB Tools URL:**
  - If you need a different version of ADB tools, update the `ADB_TOOLS_URL` variable in the script.

---

## **Troubleshooting**
- **Connection Issues:**
  - Ensure your devices are on the same network and have ADB over Wi-Fi enabled.
  - Use `adb connect <device_ip>:5555` manually to verify connectivity.

- **Missing Dependencies:**
  - Ensure `curl` and `unzip` are installed.

- **Script Errors:**
  - If the script exits unexpectedly, check for error messages and verify that the URLs for APK and ADB tools are accessible.

---

## **Contributing**
I welcome contributions! Feel free to open an issue or submit a pull request if you:
- Encounter bugs.
- Have ideas for improvements.
- Want to add support for additional features.

---

## **Disclaimer**
- This script downloads files from external sources (GitHub and Google's official servers). Verify the authenticity of URLs and files before use.
- Use at your own risk. Ensure the APK is safe and compatible with your devices.

---

## **License**
This project is licensed under the GNU General Public License. See the [LICENSE](LICENSE) file for details.

---

### **Author**
Developed by [burglarbenson](https://github.com/burglarbenson/). 

---