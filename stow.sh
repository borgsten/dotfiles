#!/usr/bin/env bash

configs=(
    "zsh"
    "tmux"
    "nvim"
    "scripts"
    "alacritty"
    "i3"
    "polybar"
    "rofi"
    "theming"
    "hypr"
    "ghostty"
)

for config in "${configs[@]}"; do
	echo "Stowing $config"
	stow -R --target="${HOME}" "$config"
done

# Ignore the current theme symlink
echo "Make git ignore current theme symlink"
git update-index --assume-unchanged theming/.config/theming/current
