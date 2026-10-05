#!/usr/bin/env bash
# Stow the active configs into $HOME.
#
# Usage: ./stow.sh [extra...]
#        ./stow.sh -D|--delete config...

# Configs for the current setup, always stowed
configs=(
    "zsh"
    "tmux"
    "nvim"
    "scripts"
    "theming"
    "hypr"
    "ghostty"
    "noctalia"
    "wezterm"
)

scriptpath="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

usage() {
    sed -n '2,5s/^# \?//p' "${BASH_SOURCE[0]}"
    local dir extra_names=()
    for dir in "$scriptpath"/*/; do
        dir=$(basename "$dir")
        [[ $dir == wallpapers || " ${configs[*]} " == *" $dir "* ]] && continue
        extra_names+=("$dir")
    done
    echo "  Extras: ${extra_names[*]} (default: none)"
}

delete=false
selected=()
for arg in "$@"; do
    case $arg in
        -h|--help) usage; exit 0 ;;
        -D|--delete) delete=true; continue ;;
    esac
    if [[ $arg == wallpapers || ! -d "$scriptpath/$arg" ]]; then
        echo "Unknown config: $arg" >&2
        usage >&2
        exit 2
    fi
    selected+=("$arg")
done

# Unstow only what was named, never the default set
if $delete; then
    if (( ${#selected[@]} == 0 )); then
        echo "No configs given to unstow" >&2
        usage >&2
        exit 2
    fi
    for config in "${selected[@]}"; do
        echo "Unstowing $config"
        stow -D --dir="$scriptpath" --target="${HOME}" "$config"
    done
    exit 0
fi

for config in "${selected[@]}"; do
    [[ " ${configs[*]} " == *" $config "* ]] || configs+=("$config")
done

# Make sure files are symlinked
mkdir -p ~/.local/share/icons/Adwaita-Symbolic
mkdir -p ~/.config/btop/themes
ln -sf ../../../.cache/theming/btop.theme ~/.config/btop/themes/matugen.theme

# btop messes with config in runtime, just set theme
btop_conf=~/.config/btop/btop.conf
# left over from when the config was stowed
[[ -L $btop_conf ]] && rm "$btop_conf"
# btop fills in everything else on launch
if grep -q '^color_theme' "$btop_conf" 2>/dev/null; then
	sed -i 's/^color_theme = .*/color_theme = "matugen"/' "$btop_conf"
else
	echo 'color_theme = "matugen"' >> "$btop_conf"
fi

for config in "${configs[@]}"; do
	echo "Stowing $config"
	stow -R --dir="$scriptpath" --target="${HOME}" "$config"
done
