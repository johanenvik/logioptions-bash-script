#!/bin/bash

# Script to fix Logi Options+ certificate issues on macOS Tahoe
# This script manipulates system time to work around certificate validation problems

set -e

echo "Starting Logi Options+ fix for macOS Tahoe..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Error: This script is designed for macOS only."
    exit 1
fi

# Check if running with sudo privileges (required for systemsetup and date commands)
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run with sudo privileges."
    echo "Usage: sudo $0"
    exit 1
fi

echo "Step 1: Disabling automatic time..."
systemsetup -setusingnetworktime off

echo "Step 2: Setting date back by one year..."
# Get current date and calculate one year ago
CURRENT_DATE=$(date +"%m/%d/%Y")
CURRENT_YEAR=$(date +"%Y")
ONE_YEAR_AGO=$((CURRENT_YEAR - 1))
NEW_DATE=$(date +"%m/%d")/$ONE_YEAR_AGO
NEW_TIME=$(date +"%H:%M:%S")

# Set the system date
date "$ONE_YEAR_AGO$(date +%m%d%H%M.%S)"
echo "Date set to: $(date)"

echo "Step 3: Force quitting Logi Options+..."
# Try to kill the process if it's running
LOGI_PID=$(pgrep -x "Logi Options+" 2>/dev/null || echo "")
if [ -n "$LOGI_PID" ]; then
    kill "$LOGI_PID" 2>/dev/null || true
    sleep 2
    echo "Logi Options+ has been force quit."
else
    echo "Logi Options+ was not running."
fi

echo "Step 4: Starting Logi Options+..."
# Open Logi Options+ application
open -a "Logi Options+" || echo "Warning: Could not start Logi Options+. Please start it manually."
sleep 3

echo "Step 5: Re-enabling automatic time..."
systemsetup -setusingnetworktime on
echo "Automatic time has been re-enabled."

echo ""
echo "Done! Logi Options+ should now be working correctly."
echo "The system time will automatically synchronize with network time."
