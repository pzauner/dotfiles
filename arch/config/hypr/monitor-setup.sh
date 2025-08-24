#!/usr/bin/env bash

# Intelligent Monitor Setup Script
# Automatically detects if eDP-3 is available and configures monitors accordingly

# Function to check if monitor is connected
check_monitor() {
    local monitor=$1
    hyprctl monitors | grep -q "$monitor"
    return $?
}

# Function to configure monitors
setup_monitors() {
    if check_monitor "DP-3"; then
        echo "eDP-3 detected - setting up extended desktop with mirroring"
        # eDP-3 is available - set up extended desktop with mirroring
        hyprctl keyword monitor "DP-3,3440x1440@174.96,0x0,1.0,bitdepth,10,cm,hdr,sdrbrightness,1.4,vrr,1"
        
        if check_monitor "HDMI-A-1"; then
            # Disable HDMI-A-1 when eDP-3 is available (Dummy Plug)
            hyprctl keyword monitor "HDMI-A-1,disable"
            echo "Dummy Plug disabled - only main monitor active"
        fi
        
    else
        echo "eDP-3 not detected - setting HDMI-A-1 as primary monitor"
        # eDP-3 is not available - set HDMI-A-1 as primary
        if check_monitor "HDMI-A-1"; then
            hyprctl keyword monitor "HDMI-A-1,1920x1080@60.0,0x0,1.0"
            # Remove any mirroring
            hyprctl keyword monitor "HDMI-A-1,addreserved,0,0,0,0"
        fi
    fi
}

# Main execution
echo "Running intelligent monitor setup..."
setup_monitors
echo "Monitor setup complete!"
