#!/bin/bash

# Script to fix Logi Options+ certificate issues on macOS Tahoe
# This script manipulates system time to work around certificate validation problems

set -e

echo "Starting Logi Options+ fix for macOS..."

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

echo ""
echo "Step 1: Disabling automatic time..."
systemsetup -setusingnetworktime off 2>/dev/null

echo ""
echo "Step 2: Setting date back by one year..."
# Calculate one year ago and format for BSD date command
# Format for setting date: mmddHHMMccyy.SS
ONE_YEAR_AGO=$(date -v-1y +"%m%d%H%M%Y.%S")

# Set the system date
date "$ONE_YEAR_AGO"
echo "Date set to: $(date)"

# Wait a moment to ensure the date change takes effect
sleep 5

echo ""
echo "Step 3: Force quitting Logi Options+..."
# Try to kill the process if it's running
LOGI_PID=$(pgrep -f "logioptionsplus_agent" 2>/dev/null | head -n 1 || echo "")
echo "Finding Logi Options+ process..."
sleep 3
if [ -n "$LOGI_PID" ]; then
    echo "Found Logi Options+ process (PID: $LOGI_PID), force killing..."
    kill -9 "$LOGI_PID" 2>/dev/null || true
    sleep 3
    # Verify it's killed
    if pgrep -f "logioptionsplus_agent" >/dev/null 2>&1; then
        echo "Warning: Process may still be running. Trying killall..."
        killall -9 "logioptionsplus_agent" 2>/dev/null || true
        sleep 2
    fi
    echo "Logi Options+ has been force quit."
else
    echo "Logi Options+ was not running."
fi

echo ""
echo "Step 4: Starting Logi Options+..."
# Try different possible application names
if open -a "logioptionsplus_agent" 2>/dev/null; then
    echo "Logi Options+ started successfully."
# if open -a "logioptionsplus" 2>/dev/null; then
#     echo "Logi Options+ started successfully. (1)"
else
    echo "Warning: Could not find Logi Options+. Please start it manually."
fi
sleep 5

echo ""
echo "Step 5: Re-enabling automatic time..."
systemsetup -setusingnetworktime on 2>/dev/null
echo "Automatic time has been re-enabled."

echo ""
echo "Done! Logi Options+ should now be working correctly."
echo "The system time will automatically synchronize with network time."
