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
    "btop"
)

# Make sure files are symlinced
mkdir -p ~/.local/share/icons/Adwaita-Symbolic
mkdir -p ~/.config/btop/themes
ln -sf ../../../.cache/theming/btop.theme ~/.config/btop/themes/matugen.theme

for config in "${configs[@]}"; do
	echo "Stowing $config"
	stow -R --target="${HOME}" "$config"
done

# Ignore the current theme symlink
if git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Make git ignore current theme symlink"
    git update-index --assume-unchanged theming/.config/theming/current
fi
