# VPN Monitoring Script

This repository contains a Bash script (`check_vpn.sh`) designed to monitor your VPN connection status. The script periodically checks if your VPN is active by verifying your external Internet Service Provider (ISP). If the VPN is disconnected, the script can execute a predefined action, such as restarting the service.

## Features

- **VPN Status Check**: Determines if the VPN is active by checking the external ISP.
- **Automatic Action on VPN Loss**: Executes a specified command when the VPN is disconnected, e.g., restart the VPN service, run a script or reboot.
- **Internet Connectivity Check**: Only checks VPN status if there is internet access.

## Installation

Ensure that the necessary packages are installed:

```sudo apt-get install curl iputils-ping bsdutils jq
Clone the repository with submodules:

```
git clone --recurse-submodules https://github.com/macg4dave/check_vpn
cd check_vpn
sudo cp -rv check_vpn /usr/local/share/bin
sudo chmod +x /usr/local/share/bin/check_vpn.sh
Configuration
Edit the check_vpn.sh script to adjust the variables as needed.

Find your ISP Name by visiting http://ip-api.com or running curl http://ip-api.com in the terminal.

## Configuration variables
CHECK_INTERVAL=60                       # Interval between checks in seconds
ISP_TO_CHECK="Your ISP Name"            # The ISP name when VPN is disconnected
VPN_LOST_ACTION="/path/to/your/action"  # Command to execute when VPN is lost
                                        # e.g., VPN_LOST_ACTION="/usr/bin/systemctl restart openvpn.service"

## Logging configuration
log_file="/var/log/check_vpn/check_vpn.log"  # Log file path
log_verbose=1  # Verbosity level: 1=ERROR, 2=WARN, 3=INFO, 4=DEBUG
Copy code
