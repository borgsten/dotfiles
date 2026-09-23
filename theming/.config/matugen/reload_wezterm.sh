#!/usr/bin/env bash
# Reload wezterm only when the generated scheme actually changed.
#
# wezterm only re-reads color_scheme_dirs when its config file changes, so the
# colours need a touch to land -- but a reload costs it ~0.5-1s of work
# (re-resolving fonts, palette and window layout), and the templates are
# re-rendered on every theme event, most of which leave these colours alone.
set -euo pipefail

cache="${XDG_CACHE_HOME:-$HOME/.cache}/theming"
scheme="$cache/wezterm/Noctalia.toml"
applied="$cache/wezterm.applied"
config="${XDG_CONFIG_HOME:-$HOME/.config}/wezterm/wezterm.lua"

[ -f "$scheme" ] || exit 0
cmp -s "$scheme" "$applied" && exit 0
cp -- "$scheme" "$applied"

# A wezterm that is not running picks the scheme up on its next start anyway.
pgrep -x wezterm-gui >/dev/null 2>&1 || exit 0
[ -e "$config" ] && touch "$config"
