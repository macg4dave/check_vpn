#!/bin/bash

# Error logging functions
log_file="/var/log/vpn_check.log"

function log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" | tee -a "$log_file"
}

function log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" | tee -a "$log_file"
}

function log_warn() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] $1" | tee -a "$log_file"
}

# Configuration variables
CHECK_INTERVAL=60
ISP_TO_CHECK="Hutchison 3G UK Ltd"
VPN_LOST_ACTION="/usr/sbin/shutdown -r now"

# Function to check internet connectivity
function check_vpn() {
    if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
        get_loc
    else
        log_error "Internet Down"
    fi
}

# Function to determine current ISP and take action if VPN is lost
function get_loc() {
    response=$(curl -s http://ip-api.com/json)
    if [ $? -ne 0 ] || [ -z "$response" ]; then
        log_error "Failed to retrieve location data"
        return 1
    fi

    # Check if jq is installed
    if command -v jq >/dev/null 2>&1; then
        isp=$(echo "$response" | jq -r '.isp')
    else
        log_warn "jq not found, falling back to sed for JSON parsing"
        isp=$(echo "$response" | sed -n 's/.*"isp":"\([^"]*\)".*/\1/p')
    fi

    if [ -z "$isp" ]; then
        log_error "Failed to parse ISP from response"
        return 1
    fi

    if [ "$isp" == "$ISP_TO_CHECK" ]; then
        log_error "VPN Lost (ISP: $isp)"
        logger "VPN lost, taking action"
        $VPN_LOST_ACTION
    else
        log_info "VPN active (ISP: $isp)"
    fi
}

# Main loop to continuously check VPN status
while true; do
    check_vpn
    sleep $CHECK_INTERVAL
done
