#!/usr/bin/env bash

configs=(
    "zsh"
    "tmux"
    "nvim"
    "scripts"
    "alacritty"
    "i3"
    "sway"
    "walker"
    "waybar"
    "polybar"
    "rofi"
    "theming"
    "hypr"
    "ghostty"
    "services"
    "applications"
)

mkdir -p ~/.local/share/icons/Adwaita-Symbolic

for config in "${configs[@]}"; do
	echo "Stowing $config"
	stow -R --target="${HOME}" "$config"
done

# Ignore the current theme symlink
if git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Make git ignore current theme symlink"
    git update-index --assume-unchanged theming/.config/theming/current
fi
