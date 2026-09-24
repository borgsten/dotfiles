#!/usr/bin/env bash
# Check that the tools the dotfiles rely on are installed.
#
# Usage: ./healthcheck.sh [section...]
#   Sections: shell neovim terminal desktop setup (default: all)
#
# Exits non-zero if anything marked required is missing; optional misses only
# warn, since they depend on which machine/session you are on.

if [[ -t 1 ]]; then
    red=$'\e[31m' green=$'\e[32m' yellow=$'\e[33m' bold=$'\e[1m' dim=$'\e[2m' reset=$'\e[0m'
else
    red='' green='' yellow='' bold='' dim='' reset=''
fi

missing_required=()
missing_optional=()

section() {
    printf '\n%s%s%s\n' "$bold" "$1" "$reset"
}

report() {
    local ok=$1 level=$2 name=$3 hint=$4
    if [[ $ok == 1 ]]; then
        printf '  %s✔%s %s\n' "$green" "$reset" "$name"
    elif [[ $level == req ]]; then
        printf '  %s✘ %s%s %s%s%s\n' "$red" "$name" "$reset" "$dim" "$hint" "$reset"
        missing_required+=("$name")
    else
        printf '  %s• %s%s %s%s%s\n' "$yellow" "$name" "$reset" "$dim" "$hint" "$reset"
        missing_optional+=("$name")
    fi
}

# cmd <req|opt> <binary[|alternative...]> [what it is used for]
# Alternatives cover binaries renamed by some distros, e.g. fd|fdfind.
cmd() {
    local level=$1 bins=$2 why=$3
    local ok=0 bin
    local IFS='|'
    for bin in $bins; do
        command -v "$bin" >/dev/null 2>&1 && ok=1
    done
    report "$ok" "$level" "${bins%%|*}" "${why:+($why)}"
}

# check <req|opt> <name> <hint> <test command...>
check() {
    local level=$1 name=$2 hint=$3
    shift 3
    local ok=0
    "$@" >/dev/null 2>&1 && ok=1
    report "$ok" "$level" "$name" "${hint:+($hint)}"
}

check_shell() {
    section "Shell"
    cmd req zsh
    cmd req git
    cmd req stow
    cmd req curl
    cmd req less
    cmd req fzf
    cmd req rg
    cmd req "fd|fdfind"
    cmd req "bat|batcat"
    cmd req eza
    cmd req zoxide
    cmd req jq
    cmd req unzip
    cmd opt vivid "LS_COLORS"
    cmd opt mise "runtime manager"
    cmd opt lazygit "lzg alias"
    cmd opt lazydocker "lzd alias"
    cmd opt "ipython3|ipython" "py alias"
    cmd opt xmllint "xml function"
    cmd opt notify-send "notif/alert functions"
    cmd opt ruby "try.zsh"
    cmd opt qalc
    check opt "fzf zsh keybindings" "" \
        test -f /usr/share/fzf/key-bindings.zsh -o -f /usr/share/doc/fzf/examples/key-bindings.zsh
}

check_neovim() {
    section "Neovim"
    cmd req nvim
    cmd req gcc "treesitter parsers"
    cmd req make
    cmd opt cmake
    cmd opt "node|nodejs" "LSP servers via mason"
    cmd opt npm "LSP servers via mason"
    cmd opt luarocks
    cmd opt "lua5.1|lua51|luajit"
    cmd opt stylua "lua formatter"
    cmd opt black "python formatter"
    cmd opt isort "python formatter"
    cmd opt clang-format "c++ formatter"
    cmd opt gofmt "go formatter"
    check opt "pynvim" "nvim_run_command" python3 -c 'import pynvim'
}

check_terminal() {
    section "Terminal"
    cmd req tmux
    check req "tmux plugin manager" "git clone https://github.com/tmux-plugins/tpm ~/.cache/tmux/plugins/tpm" \
        test -d "$HOME/.cache/tmux/plugins/tpm"
    cmd opt wezterm
    cmd opt ghostty
    cmd opt alacritty
    cmd opt xdg-terminal-exec "scratch / hypr terminal"
    check req "JetBrainsMono Nerd Font" "" \
        bash -c 'fc-list | grep -qi "JetBrainsMono Nerd"'
}

check_desktop() {
    section "Desktop (Hyprland)"
    cmd opt Hyprland
    cmd opt hyprctl
    cmd opt uwsm
    cmd opt hypridle
    cmd opt hyprlock
    cmd opt hyprpaper
    cmd opt hyprsunset
    check opt "hyprpolkitagent" "" bash -c 'for d in /usr/lib /usr/lib64 /usr/libexec /usr/local/lib /usr/local/libexec; do [[ -x $d/hyprpolkitagent/hyprpolkitagent || -x $d/hyprpolkitagent ]] && exit 0; done; exit 1'
    cmd opt noctalia "shell"
    cmd opt dms "shell"
    cmd opt waybar
    cmd opt swaync
    cmd opt walker
    cmd opt elephant
    cmd opt swayosd-server
    cmd opt swayosd-client
    cmd opt matugen "theming"
    cmd opt btop
    cmd opt playerctl
    cmd opt brightnessctl
    cmd opt flameshot "screenshots"
    cmd opt wl-copy
    cmd opt udiskie
    cmd opt deskflow
    cmd opt nwg-displays
    cmd opt gsettings "gtk theme reload"
    cmd opt xdg-open
    cmd opt firefox
    cmd opt seahorse
    cmd opt secret-tool
    cmd opt gnome-keyring-daemon
}

check_setup() {
    section "Setup"
    local dotfiles
    dotfiles="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
    check req "zsh config stowed" "run ./stow.sh" \
        test "$(realpath "$HOME/.config/zsh/.zshrc")" = "$dotfiles/zsh/.config/zsh/.zshrc"
    check req "ZDOTDIR via ~/.zshenv" "run ./stow.sh" test -e "$HOME/.zshenv"
    check opt "login shell is zsh" "chsh -s $(command -v zsh || echo zsh)" \
        bash -c '[[ "$(getent passwd "$USER" | cut -d: -f7)" == */zsh ]]'
    check opt "ssh-agent.service enabled" "systemctl --user enable --now ssh-agent.service" \
        systemctl --user is-enabled ssh-agent.service
}

sections=("$@")
[[ ${#sections[@]} -eq 0 ]] && sections=(shell neovim terminal desktop setup)

for s in "${sections[@]}"; do
    if declare -F "check_$s" >/dev/null; then
        "check_$s"
    else
        echo "Unknown section: $s" >&2
        exit 2
    fi
done

echo
if (( ${#missing_required[@]} )); then
    printf '%s%d required missing:%s %s\n' "$red" "${#missing_required[@]}" "$reset" "${missing_required[*]}"
fi
if (( ${#missing_optional[@]} )); then
    printf '%s%d optional missing:%s %s\n' "$yellow" "${#missing_optional[@]}" "$reset" "${missing_optional[*]}"
fi
if (( ! ${#missing_required[@]} && ! ${#missing_optional[@]} )); then
    printf '%sAll good!%s\n' "$green" "$reset"
fi

(( ${#missing_required[@]} == 0 ))
