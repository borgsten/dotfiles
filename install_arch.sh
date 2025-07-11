#!/usr/bin/env bash

packages=(
    # System
    ghostty
    ttf-jetbrains-mono-nerd
    udiskie
    brightnessctl
    # WM Hyprland
    deskflow
    hypridle
    hyprland
    hyprlock
    hyprpaper
    hyprsunset
    swaync
    waybar
    wl-clipboard
    # Dev
    cmake
    # Neovim
    nvim
    lua51
    luarocks
    # Util
    bat
    fd
    fzf
    less
    ripgrep
    tmux
    unzip
)

sudo pacman -S --needed ${packages[@]}
