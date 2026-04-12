#!/usr/bin/env bash

source ~/.cache/theming/icon_theme.env

ICON_DIR="$HOME/.local/share/icons/Adwaita-Symbolic"
OUT_DIR="$ICON_DIR/scalable/places"
TEMPLATE_DIR="$HOME/.config/matugen/templates/Adwaita-Symbolic"

mkdir -p "$OUT_DIR"

for template in "$TEMPLATE_DIR"/*.svg; do
    name=$(basename "$template")
    sed \
        -e "s/{{PRIMARY}}/$PRIMARY/g" \
        -e "s/{{ON_PRIMARY}}/$ON_PRIMARY/g" \
        -e "s/{{PRIMARY_CONTAINER}}/$PRIMARY_CONTAINER/g" \
        -e "s/{{ON_PRIMARY_CONTAINER}}/$ON_PRIMARY_CONTAINER/g" \
        "$template" > "$OUT_DIR/$name"
done

gtk-update-icon-cache -f -t "$ICON_DIR"

gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
sleep 0.1
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita-Symbolic'
