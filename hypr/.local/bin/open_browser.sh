#!/usr/bin/env bash

xdg-open "$1"
hyprctl eval 'UTIL.helpers.focusUrgentWindow()'
