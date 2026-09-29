#!/usr/bin/env bash
# Install the pinned WezTerm nightly .deb.
#
# Usage: bootstrap/ubuntu/wezterm.sh [--pin]
#   --pin  pin whatever the current nightly is, then install it
#
# The nightly release asset is overwritten every night, so the pinned .deb is
# cached in $DEB_DIR. Once the nightly moves on, a machine without the cache
# can only install it after re-pinning.

set -euo pipefail

here="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "$here/pins.sh"

url=https://github.com/wezterm/wezterm/releases/download/nightly/wezterm-nightly.Ubuntu24.04.deb
cached() { echo "$DEB_DIR/wezterm-nightly_${1}_amd64.deb"; }

mkdir -p "$DEB_DIR"
tmp="$(mktemp --suffix=.deb)"
chmod 644 "$tmp"
trap 'rm -f "$tmp"' EXIT

if [[ "${1:-}" == --pin ]]; then
    curl -fL --progress-bar -o "$tmp" "$url"
    WEZTERM_NIGHTLY_VERSION="$(dpkg-deb -f "$tmp" Version)"
    WEZTERM_NIGHTLY_SHA256="$(sha256sum "$tmp" | cut -d' ' -f1)"
    mv "$tmp" "$(cached "$WEZTERM_NIGHTLY_VERSION")"
    sed -i \
        -e "s/^WEZTERM_NIGHTLY_VERSION=.*/WEZTERM_NIGHTLY_VERSION=$WEZTERM_NIGHTLY_VERSION/" \
        -e "s/^WEZTERM_NIGHTLY_SHA256=.*/WEZTERM_NIGHTLY_SHA256=$WEZTERM_NIGHTLY_SHA256/" \
        "$here/pins.sh"
    echo "Pinned wezterm-nightly $WEZTERM_NIGHTLY_VERSION (commit $here/pins.sh)"
fi

if [[ "$(dpkg-query -W -f='${Version}' wezterm-nightly 2>/dev/null)" == "$WEZTERM_NIGHTLY_VERSION" ]]; then
    echo "wezterm-nightly $WEZTERM_NIGHTLY_VERSION already installed"
    exit 0
fi

deb="$(cached "$WEZTERM_NIGHTLY_VERSION")"
if [[ ! -f $deb ]]; then
    curl -fL --progress-bar -o "$tmp" "$url"
    if [[ "$(sha256sum "$tmp" | cut -d' ' -f1)" != "$WEZTERM_NIGHTLY_SHA256" ]]; then
        echo "The current nightly ($(dpkg-deb -f "$tmp" Version)) is not the pinned $WEZTERM_NIGHTLY_VERSION." >&2
        echo "Run '$0 --pin' to move the pin to it." >&2
        exit 1
    fi
    mv "$tmp" "$deb"
fi

echo "$WEZTERM_NIGHTLY_SHA256  $deb" | sha256sum --check --quiet
sudo apt-get install -y "$deb"
