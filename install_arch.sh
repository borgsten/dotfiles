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
    swayosd
    # Dev
    cmake
    # Neovim
    nvim
    lua51
    luarocks
    # Util
    bat
    fd
    eza
    fzf
    less
    ripgrep
    tmux
    unzip
    firefox
    nodejs
    libqalculate
    gnome-keyring
    seahorse
    libsecret
    jq
    lazydocker
    lazygit
    zoxide
)

paru -S --needed ${packages[@]}

if [[ ! -d ~/.cache/tmux/plugins/tpm ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.cache/tmux/plugins/tpm
fi

if [[ "$(systemctl --user is-enabled ssh-agent.service)" != "enabled" ]]; then
    systemctl --user enable --now ssh-agent.service
fi
