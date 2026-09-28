#!/usr/bin/env bash
# Install the packages the dotfiles rely on.
#
# Usage: ./install_arch.sh [extra...]

usage() {
    sed -n '2,4s/^# \?//p' "${BASH_SOURCE[0]}"
    local extra_names
    extra_names=$(compgen -A variable extra_)
    echo "  Extras: $(echo ${extra_names//extra_/}) (default: none)"
}

packages=(
    # System
    base-devel
    git
    curl
    stow
    zsh
    wezterm
    ghostty
    ttf-jetbrains-mono-nerd
    xdg-terminal-exec
    xdg-utils
    udiskie
    brightnessctl
    playerctl
    libnotify
    # WM Hyprland
    uwsm
    deskflow
    hyprland
    hyprpolkitagent
    noctalia
    wl-clipboard
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    flameshot
    grim
    kvantum
    # Theming
    matugen
    vivid
    btop
    # Dev
    cmake
    mise
    npm
    ruby
    ipython
    libxml2
    # Neovim
    neovim
    tree-sitter-cli
    lua51
    luarocks
    # Formatters
    stylua
    python-black
    python-isort
    clang
    go
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

# Launcher replaced by noctalia, kept for the bespoke shell
extra_walker=(
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
)

extra_hyprland=(
    hypridle
    hyprlock
    hyprpaper
    hyprsunset
    nwg-displays
    swaync
    swayosd
    waybar
)

extras=()
for arg in "$@"; do
    case $arg in
        -h|--help) usage; exit 0 ;;
    esac
    if ! declare -p "extra_${arg}" &>/dev/null; then
        echo "Unknown extra: $arg" >&2
        usage >&2
        exit 2
    fi
    extras+=("$arg")
    declare -n extra="extra_${arg}"
    packages+=("${extra[@]}")
    unset -n extra
done

has_extra() {
    [[ " ${extras[*]} " == *" $1 "* ]]
}

paru -S --needed "${packages[@]}"

if [[ ! -d ~/.cache/tmux/plugins/tpm ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.cache/tmux/plugins/tpm
fi

scriptpath="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
if has_extra walker && [[ ! -f ~/.config/systemd/user/elephant.service ]]; then
    elephant service enable
fi

services=(
    ssh-agent.service
)

for service in "${services[@]}"; do
    if [[ "$(systemctl --user is-enabled "${service}")" != "enabled" ]]; then
        systemctl --user enable --now "${service}"
    fi
done
