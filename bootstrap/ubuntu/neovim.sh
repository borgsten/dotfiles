#!/usr/bin/env bash
# Build Neovim from the checkout in $NEOVIM_SRC and install it as a .deb.
#
# Usage: bootstrap/ubuntu/neovim.sh [REF]
#   REF  tag, branch or commit to build (default: stable)

set -euo pipefail

src="${NEOVIM_SRC:-$HOME/tools/neovim}"
ref="${1:-stable}"

sudo apt-get install -y --no-install-recommends \
    build-essential cmake curl gettext git ninja-build

if [[ ! -d $src ]]; then
    git clone --filter=blob:none https://github.com/neovim/neovim.git "$src"
fi
git -C "$src" fetch --tags --force origin
git -C "$src" checkout --force --detach "origin/$ref" 2>/dev/null ||
    git -C "$src" checkout --force --detach "$ref"

# Skip the build when the installed nvim was built from this commit
stamp="$src/.git/installed-commit"
if [[ "$(git -C "$src" rev-parse HEAD)" == "$(cat "$stamp" 2>/dev/null)" ]] && command -v nvim >/dev/null; then
    echo "Neovim already built from $ref, skipping"
    exit 0
fi

# Bundled deps are cached per checkout; a stale build dir can mix versions
make -C "$src" distclean
make -C "$src" CMAKE_BUILD_TYPE=Release
(cd "$src/build" && cpack -G DEB)

sudo apt-get install -y "$src/build/nvim-linux-x86_64.deb"
git -C "$src" rev-parse HEAD >"$stamp"
nvim --version | head -1
