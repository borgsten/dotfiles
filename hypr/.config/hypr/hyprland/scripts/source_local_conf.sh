#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
CONF_DIR="$(realpath "$SCRIPT_DIR/../local")"

RUNNING_NVIDIA=$(lsmod | grep -q nvidia && echo true || echo false)

for config in "$CONF_DIR"/*.conf; do
    # Skip NVIDIA-specific configs if NVIDIA is not running
    if [[ "$config" == *nvidia.conf && "$RUNNING_NVIDIA" == false ]]; then
        continue
    fi

    echo sourcing $config
    hyprctl keyword source $config
done
