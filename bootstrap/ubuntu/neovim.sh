#!/usr/bin/env bash
# Build a Neovim release from source and install it as a .deb.
#
# Usage: bootstrap/ubuntu/neovim.sh [--tag TAG] [--force]
#   --tag    build TAG instead of the pin, to try a release before moving
#            NEOVIM_TAG in pins.sh
#   --force  rebuild even if that version is already installed

set -euo pipefail

source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/pins.sh"

tag=$NEOVIM_TAG
force=0
while (($#)); do
    case $1 in
        --tag) tag=$2; shift ;;
        --force) force=1 ;;
        *) sed -n '2,7s/^# \?//p' "$0" >&2; exit 2 ;;
    esac
    shift
done

version="${tag#v}"
deb="$DEB_DIR/neovim_${version}_amd64.deb"
src="$TOOLS_DIR/neovim"

if ((!force)) &&
    [[ "$(dpkg-query -W -f='${Version}' neovim 2>/dev/null)" == "$version" ]]; then
    echo "neovim $version already installed"
    exit 0
fi

if ((force)) || [[ ! -f $deb ]]; then
    sudo apt-get install -y --no-install-recommends \
        build-essential cmake curl gettext git ninja-build

    if [[ ! -d $src ]]; then
        git clone --filter=blob:none https://github.com/neovim/neovim.git "$src"
    fi
    git -C "$src" fetch --tags --force origin
    git -C "$src" checkout --force "$tag"

    # Bundled deps are cached per checkout; a stale build dir can mix versions
    make -C "$src" distclean
    make -C "$src" CMAKE_BUILD_TYPE=Release
    (cd "$src/build" && cpack -G DEB)

    mkdir -p "$DEB_DIR"
    cp "$src/build/nvim-linux-x86_64.deb" "$deb"
fi

sudo apt-get install -y "$deb"
nvim --version | head -1
