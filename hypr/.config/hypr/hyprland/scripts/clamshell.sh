#!/usr/bin/env bash

# Based on https://github.com/Kore29/hyprland-clamshell

# Change this to your internal monitor name (use 'hyprctl monitors' to find it)
INTERNAL_DISPLAY="${HYPR_INTERNAL_DISPLAY:-"eDP-1"}"
INTERNAL_DISPLAY_CONFIG="${HYPR_INTERNAL_DISPLAY_CONFIG:-"preferred, auto, 1"}"

if ! hyprctl -j monitors all | jq -e ".[] | select(.name==\"$INTERNAL_DISPLAY\")" > /dev/null; then
    echo "Internal display '$INTERNAL_DISPLAY' not found. Please set INTERNAL_DISPLAY variable correctly." >&2
    exit 1
fi

mode_close() {
    # Only disable internal screen if an external monitor is connected
    MONITORS_COUNT=$(hyprctl monitors all | grep -c "Monitor")
    if [[ $MONITORS_COUNT -gt 1 ]]; then

        MONITOR_DISABLED="$(hyprctl -j monitors all | jq -e ".[] | select(.name==\"eDP-1\") | .disabled")"
        if [[ "$MONITOR_DISABLED" == "false" ]]; then
            hyprctl keyword monitor "$INTERNAL_DISPLAY, disable"
        fi
    fi
}

mode_open() {
    # Force enable internal screen
    hyprctl keyword monitor "$INTERNAL_DISPLAY, $INTERNAL_DISPLAY_CONFIG"
}

if [[ "$1" == "close" ]]; then
    mode_close
elif [[ "$1" == "open" ]]; then
    mode_open
elif [[ "$1" == "check" ]]; then
    # Silent check for startup/reload to sync state
    if grep -q "open" /proc/acpi/button/lid/*/state; then
        mode_open
    else
        mode_close
    fi
else
    echo "Usage: $0 [open|close|check]"
    exit 1
fi
