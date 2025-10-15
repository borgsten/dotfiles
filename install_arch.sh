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
    walker
    elephant

    elephant-calc
    elephant-desktopapplications
    elephant-files
    elephant-menus
    elephant-providerlist
    elephant-runner
    elephant-symbols
    elephant-websearch

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

paru -S --needed "${packages[@]}"

if [[ ! -d ~/.cache/tmux/plugins/tpm ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.cache/tmux/plugins/tpm
fi

scriptpath="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
if [[ ! -f ~/.config/systemd/user/elephant.service ]]; then
    install -D -m 644 "${scriptpath}/services/elephant.service ~/.config/systemd/user/elephant.service"
fi

services=(
    app-com.mitchellh.ghostty.service
    ssh-agent.service
    elephant.service
)

for service in "${services[@]}"; do
    if [[ "$(systemctl --user is-enabled "${service}")" != "enabled" ]]; then
        systemctl --user enable --now "${service}"
    fi
done
