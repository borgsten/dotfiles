#!/usr/bin/env bash

xdg-open "$1"
hyprctl eval 'hl.dispatch(hl.dsp.focus({ window = hl.get_urgent_window() }))'
