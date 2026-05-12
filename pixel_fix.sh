#!/bin/bash

# Pixel 8 Pro "Deep Sleep" & Battery Optimization Script
# This script uses ADB to apply optimizations and force aggressive Doze mode.

# Check for ADB connection
if ! adb get-state 1>/dev/null 2>&1; then
    echo "Error: No device connected via ADB. Please connect your Pixel 8 Pro and enable USB Debugging."
    exit 1
fi

echo "--- Pixel 8 Pro Battery Optimization Tool ---"

optimize_system() {
    echo "Step 1: Running ART (Android Runtime) Optimization..."
    echo "This may take several minutes. It pre-compiles apps to reduce CPU usage."
    adb shell cmd package compile -m speed-profile -a
    adb shell cmd package bg-dexopt-job
    echo "Optimization complete."
}

enable_deep_sleep_profile() {
    echo "Step 2: Applying Deep Sleep & Power Savings Settings..."
    
    # Disable Mobile Data Always Active (Huge modem drain)
    adb shell settings put global mobile_data_always_on 0
    
    # Disable Adaptive Connectivity (Modem hunting)
    adb shell settings put global adaptive_connectivity_enabled 0
    
    # Set Aggressive Doze Constants
    # This forces the phone to enter 'Deep Sleep' much faster when the screen is off.
    # Light doze after 30s, Deep doze after 60s.
    DOZE_CONSTANTS="light_after_inactive_to=30000,light_pre_idle_to=30000,light_idle_to=30000,light_max_idle_to=60000,deep_inactive_to=60000,deep_idle_to=60000"
    adb shell settings put global device_idle_constants "$DOZE_CONSTANTS"
    
    echo "Deep Sleep profile applied."
}

force_immediate_doze() {
    echo "Step 3: Forcing immediate Deep Doze..."
    # To force Doze while charging, we must simulate being unplugged.
    adb shell dumpsys battery unplug
    adb shell dumpsys deviceidle force-idle deep
    echo "Device forced into Deep Doze. Note: Interaction with the screen may exit this state."
}

restore_defaults() {
    echo "Restoring system defaults..."
    adb shell settings put global mobile_data_always_on 1
    adb shell settings put global adaptive_connectivity_enabled 1
    adb shell settings delete global device_idle_constants
    adb shell dumpsys battery reset
    adb shell dumpsys deviceidle unforce
    echo "Defaults restored."
}

show_status() {
    echo "--- Current Status ---"
    echo -n "Doze State: "
    adb shell dumpsys deviceidle get deep
    echo -n "Mobile Data Always On: "
    adb shell settings get global mobile_data_always_on
    echo -n "Adaptive Connectivity: "
    adb shell settings get global adaptive_connectivity_enabled
}

# Menu
echo "1) Full Optimization (Run this after updates)"
echo "2) Apply Deep Sleep Profile (Aggressive Doze + Modem fixes)"
echo "3) Force Immediate Deep Sleep (Use before sleep/charging)"
echo "4) Restore System Defaults"
echo "5) Check Status"
echo "6) Exit"
read -p "Select an option: " choice

case $choice in
    1) optimize_system ;;
    2) enable_deep_sleep_profile ;;
    3) force_immediate_doze ;;
    4) restore_defaults ;;
    5) show_status ;;
    6) exit 0 ;;
    *) echo "Invalid option." ;;
esac

echo "Done."
