#!/bin/bash
#check_vpn.sh
# Source error logging script
#source /usr/local/share/bin/check_vpn/error-logging/error-logging.sh
source /Users/dave/github/check_vpn/error-logging/error-logging.sh
# Configuration variables
CHECK_INTERVAL=60
ISP_TO_CHECK="Hutchison 3G UK Ltd"
VPN_LOST_ACTION="/sbin/shutdown -r now"

# Set log file and log level for the script
log_file="/var/log/check_vpn"
log_verbose=1  # ERROR level logging

# Function to check internet connectivity
function check_vpn() {
    if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
        get_isp
    else
        log_write 2 "Internet Down"
    fi
}

# Function to determine current ISP and take action if VPN is lost
function get_isp() {
    response=$(curl -s http://ip-api.com/json)
    if [ $? -ne 0 ] || [ -z "$response" ]; then
        log_write 1 "Failed to retrieve location data"
        return 1
    fi

    # Check if jq is installed
    if command -v jq >/dev/null 2>&1; then
        isp=$(echo "$response" | jq -r '.isp')
    else
        log_write 2 "jq not found, falling back to sed for JSON parsing"
        isp=$(echo "$response" | sed -n 's/.*"isp":"\([^"]*\)".*/\1/p')
    fi

    if [ -z "$isp" ]; then
        log_write 1 "Failed to parse ISP from response"
        return 1
    fi

    if [ "$isp" == "$ISP_TO_CHECK" ]; then
        log_write 1 "VPN Lost (ISP: $isp)"
        logger "VPN lost, taking action"
        $VPN_LOST_ACTION
    else
        log_write 3 "VPN active (ISP: $isp)"
    fi
}

# Main loop to continuously check VPN status
while true; do
    check_vpn
    sleep $CHECK_INTERVAL
done
