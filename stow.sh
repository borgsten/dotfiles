#!/usr/bin/env bash

configs=(
    "zsh"
    "tmux"
    "nvim"
    "scripts"
    "alacritty"
    "i3"
    "sway"
    "walker"
    "waybar"
    "polybar"
    "rofi"
    "theming"
    "hypr"
    "ghostty"
    "services"
    "applications"
    "noctalia"
    "wezterm"
)

# Make sure files are symlinced
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
	stow -R --target="${HOME}" "$config"
done
