#!/usr/bin/env bash

packages=(
    # System
    ghostty
    ttf-jetbrains-mono-nerd
    udiskie
    brightnessctl
    zsh
    # WM Hyprland
    deskflow
    hypridle
    hyprland
    hyprlock
    hyprpaper
    hyprpolkitagent
    hyprsunset
    swaync
    waybar
    wl-clipboard
    walker-bin
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
    firefox
    nodejs
    libqalculate
)

paru -S --needed ${packages[@]}
