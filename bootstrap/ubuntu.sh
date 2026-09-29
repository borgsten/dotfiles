#!/usr/bin/env bash
# Install the essentials the dotfiles rely on, on Ubuntu 24.04.
#
# Usage: bootstrap/ubuntu.sh
#
# Safe to re-run; it is also how things get updated:
#   apt, PPA, mise repo  apt upgrade (this script runs it)
#   neovim, noctalia     try with ubuntu/neovim.sh --tag, ubuntu/noctalia.sh --ref
#                        then bump the pin in ubuntu/pins.sh
#   wezterm              ubuntu/wezterm.sh --pin
#   mise tools           mise upgrade
#   go tools             re-run this script (installs @latest)
#   LSPs and formatters  :Mason in nvim

set -euo pipefail

here="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "$here/ubuntu/pins.sh"

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
    # WM Hyprland (ppa:cppiber/hyprland)
    uwsm
    hyprland
    hypridle
    hyprlock
    hyprpaper
    hyprsunset
    hyprpolkitagent
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
    gnome-keyring
    seahorse
    libsecret-tools
)

# Runtimes and tools too old or missing in noble
mise_tools=(
    node@lts
    tree-sitter@latest
    # go install ignores its go.mod replace directives and fails to build
    lazydocker@latest
)

go_tools=(
    github.com/jesseduffield/lazygit@latest
)

# Whether an apt source is already configured
has_source() {
    grep -rqs "$1" /etc/apt/sources.list /etc/apt/sources.list.d/
}

# Needed to add the sources below, not on a fresh desktop install
sudo apt-get update
sudo apt-get install -y ca-certificates curl software-properties-common

if ! has_source "cppiber/hyprland"; then
    sudo add-apt-repository -y --no-update ppa:cppiber/hyprland
fi

if ! has_source "mise.jdx.dev"; then
    sudo install -dm 755 /etc/apt/keyrings
    curl -fsSL https://mise.jdx.dev/gpg-key.pub |
        sudo tee /etc/apt/keyrings/mise-archive-keyring.asc >/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc arch=amd64] https://mise.jdx.dev/deb stable main" |
        sudo tee /etc/apt/sources.list.d/mise.list >/dev/null
fi

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y "${packages[@]}"

"$here/ubuntu/neovim.sh"
"$here/ubuntu/wezterm.sh"

"$here/ubuntu/noctalia.sh"

mise use --global --yes "${mise_tools[@]}"

# Match the GOPATH in zsh/.zshenv so the binaries land on PATH
export GOPATH="$HOME/.local/go"
for tool in "${go_tools[@]}"; do
    echo "go install $tool"
    go install "$tool"
done

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

services=(
    ssh-agent.service
)

for service in "${services[@]}"; do
    if [[ "$(systemctl --user is-enabled "${service}")" != "enabled" ]]; then
        systemctl --user enable --now "${service}"
    fi
done
