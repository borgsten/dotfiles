#!/bin/env bash

capacity_file="/sys/class/power_supply/BAT0/capacity"
status_file="/sys/class/power_supply/BAT0/status"
if [[ -f ${capacity_file} ]]; then
    status=$(cat ${status_file})
    level=$(cat ${capacity_file})
    echo "${status}  - 󱊣 ${level}%"
fi
