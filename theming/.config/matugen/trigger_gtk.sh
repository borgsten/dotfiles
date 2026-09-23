#!/bin/bash

# Forces running GTK apps to re-read ~/.cache/theming/gtk.css, which they only
# do when an interface setting changes -- hence the toggle-and-restore below.
#
# Both toggles are guarded, because the colour-scheme flip is a global
# appearance change and wezterm answers one of those by re-evaluating its
# config ~260 times over ~10s at 100% CPU, hanging every wezterm on screen.
# The gtk-theme and icon-theme toggles cost it nothing, only this one.

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/theming"
CSS="$CACHE/gtk.css"
APPLIED="$CACHE/gtk.css.applied"

# Terminals that carry libadwaita but get their theme by other means, so they
# are no reason to flip the appearance.
IGNORE='ghostty'

libadwaita_app_running() {
  local maps pid comm
  for maps in $(grep -ls libadwaita /proc/[0-9]*/maps 2>/dev/null); do
    pid=${maps#/proc/}; pid=${pid%/maps}
    comm=$(cat "/proc/$pid/comm" 2>/dev/null) || continue
    grep -qxF "$comm" <<<"$IGNORE" || return 0
  done
  return 1
}

# 1. Reload GTK4 / Libadwaita apps (like Nautilus) by toggling color-scheme
if [ -f "$CSS" ] && ! cmp -s "$CSS" "$APPLIED" && libadwaita_app_running; then
  SCHEME=$(gsettings get org.gnome.desktop.interface color-scheme)
  if [ "$SCHEME" = "'prefer-light'" ]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  fi
  sleep 0.1
  gsettings set org.gnome.desktop.interface color-scheme "$SCHEME"
fi

# 2. Reload GTK3 apps (like your adw-gtk3 themed apps) by toggling gtk-theme
if [ -f "$CSS" ] && ! cmp -s "$CSS" "$APPLIED"; then
  THEME=$(gsettings get org.gnome.desktop.interface gtk-theme)
  gsettings set org.gnome.desktop.interface gtk-theme 'HighContrast'
  sleep 0.1
  gsettings set org.gnome.desktop.interface gtk-theme "$THEME"
fi

[ -f "$CSS" ] && cp -- "$CSS" "$APPLIED"
exit 0
