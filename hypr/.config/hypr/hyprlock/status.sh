#!/bin/env bash

MAIN_KB_CAPS=$(hyprctl devices | grep -B 6 "main: yes" | grep "capsLock" | head -1 | awk '{print $2}')

capacity_file="/sys/class/power_supply/BAT0/capacity"
if [[ -f ${capacity_file} ]]; then
    level=$(cat ${capacity_file})
    echo "󱊣 ${level}%"
fi

if [ "$MAIN_KB_CAPS" = "yes" ]; then
    echo "⚠ Caps Lock active"
else
    echo ""
fi

