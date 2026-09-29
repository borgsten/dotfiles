#!/usr/bin/env bash
# Install the essentials the dotfiles rely on, on Ubuntu 26.04.
#
# Usage: bootstrap/ubuntu.sh
#
# Safe to re-run; it is also how things get updated:
#   apt, PPAs, noctalia  apt upgrade (this script runs it)
#   neovim               re-run this script (builds stable if the tag moved),
#                        or ubuntu/neovim.sh REF for another version
#   wezterm              manually, only installed when missing (nightly .deb
#                        from github.com/wezterm/wezterm/releases/tag/nightly)
#   mise tools           mise upgrade
#   LSPs and formatters  :Mason in nvim

set -euo pipefail

here="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

if [[ $EUID -eq 0 ]]; then
    echo "Run as your user, sudo is used where needed" >&2
    exit 1
fi

packages=(
    # System
    build-essential
    git
    curl
    stow
    zsh
    xdg-terminal-exec
    xdg-utils
    udiskie
    brightnessctl
    playerctl
    libnotify-bin
    # WM Hyprland (ppa:cppiber/hyprland, resolute's is too old)
    uwsm
    hyprland
    noctalia
    # hyprland recommends one of these, noctalia is the notification daemon
    sway-notification-center-
    dunst-
    wl-clipboard
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    flameshot
    grim
    qt5-style-kvantum
    # Theming
    vivid
    btop
    # Dev
    cmake
    golang-go
    mise
    # Neovim (built by ubuntu/neovim.sh), deps for plugins and mason
    lua5.1
    luarocks
    unzip
    python3-venv
    # Util
    bat
    fd-find
    eza
    fzf
    less
    ripgrep
    tmux
    jq
    zoxide
    lazygit
    gnome-keyring
    seahorse
    libsecret-tools
)

# Too old or missing in resolute
mise_tools=(
    node@lts
    tree-sitter@latest
    lazydocker@latest
)

NERD_FONTS_VERSION=v3.5.1

# Needed to add the sources below
sudo apt-get update
sudo apt-get install -y ca-certificates curl software-properties-common

if ! grep -rqs "cppiber/hyprland" /etc/apt/sources.list.d/; then
    sudo add-apt-repository -y --no-update ppa:cppiber/hyprland
fi

if ! grep -rqs "jdxcode/mise" /etc/apt/sources.list.d/; then
    sudo add-apt-repository -y --no-update ppa:jdxcode/mise
fi

if [[ ! -f /etc/apt/sources.list.d/noctalia-resolute.sources ]]; then
    curl -fsSL -o /tmp/nickh-archive-keyring.deb https://pkg.noctalia.dev/deb/nickh-archive-keyring.deb
    sudo apt-get install -y /tmp/nickh-archive-keyring.deb
    rm /tmp/nickh-archive-keyring.deb
    sudo curl -fsSL -o /etc/apt/sources.list.d/noctalia-resolute.sources \
        https://pkg.noctalia.dev/deb/noctalia-resolute.sources
fi

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y "${packages[@]}"

"$here/ubuntu/neovim.sh"

# Nightly, the last stable release has no 26.04 build
if ! command -v wezterm >/dev/null; then
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    chmod 755 "$tmp"
    wezterm_url=https://github.com/wezterm/wezterm/releases/download/nightly/wezterm-nightly.Ubuntu26.04.deb
    curl -fL --progress-bar -o "$tmp/wezterm-nightly.deb" "$wezterm_url"
    curl -fsSL "$wezterm_url.sha256" | awk -v f="$tmp/wezterm-nightly.deb" '{print $1 "  " f}' | sha256sum --check --quiet
    sudo apt-get install -y "$tmp/wezterm-nightly.deb"
fi

mise use --global --yes "${mise_tools[@]}"

# Debian renames these to avoid clashes, the dotfiles use the upstream names
mkdir -p ~/.local/bin
ln -sf /usr/bin/batcat ~/.local/bin/bat
ln -sf /usr/bin/fdfind ~/.local/bin/fd

font_dir=~/.local/share/fonts/JetBrainsMonoNerd
if [[ "$(cat "$font_dir/.version" 2>/dev/null)" != "$NERD_FONTS_VERSION" ]]; then
    rm -rf "$font_dir"
    mkdir -p "$font_dir"
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION/JetBrainsMono.tar.xz" |
        tar -xJ -C "$font_dir" --wildcards '*.ttf'
    echo "$NERD_FONTS_VERSION" >"$font_dir/.version"
    fc-cache -f "$font_dir"
fi

if [[ ! -d ~/.cache/tmux/plugins/tpm ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.cache/tmux/plugins/tpm
fi
