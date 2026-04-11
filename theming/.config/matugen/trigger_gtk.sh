#!/bin/bash

# 1. Reload GTK4 / Libadwaita apps (like Nautilus) by toggling color-scheme
SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)
if [ "$SCHEME" = "'prefer-light'" ]; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
else
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
fi
sleep 0.1
gsettings set org.gnome.desktop.interface color-scheme "$SCHEME"

# 2. Reload GTK3 apps (like your adw-gtk3 themed apps) by toggling gtk-theme
THEME=$(gsettings get org.gnome.desktop.interface gtk-theme)
gsettings set org.gnome.desktop.interface gtk-theme 'HighContrast'
sleep 0.1
gsettings set org.gnome.desktop.interface gtk-theme "$THEME"
