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
)

for config in "${configs[@]}"; do
	echo "Stowing $config"
	stow -R --target="${HOME}" "$config"
done
