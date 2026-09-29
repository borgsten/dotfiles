#!/usr/bin/env bash
# Build the pinned noctalia fork commit as a .deb and install it.
#
# Usage: bootstrap/ubuntu/noctalia.sh [--ref REF] [--force]
#   --ref    build REF (branch, tag or commit) instead of the pin, to try it
#            out before moving NOCTALIA_REF in pins.sh
#   --force  rebuild even if that version is already installed
#
# The fork's packaging/ubuntu/build-deb.sh does the building, so a checkout in
# $TOOLS_DIR/noctalia can also be built by hand the same way.

set -euo pipefail

source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/pins.sh"

ref=$NOCTALIA_REF
force=0
while (($#)); do
    case $1 in
        --ref) ref=$2; shift ;;
        --force) force=1 ;;
        *) sed -n '2,10s/^# \?//p' "$0" >&2; exit 2 ;;
    esac
    shift
done

src="$TOOLS_DIR/noctalia"
if [[ ! -d $src ]]; then
    git clone --filter=blob:none "$NOCTALIA_REPO" "$src"
fi
git -C "$src" fetch --force origin
# A branch name means its latest commit on the fork, not a stale local branch
git -C "$src" checkout --force --detach "origin/$ref" 2>/dev/null ||
    git -C "$src" checkout --force --detach "$ref"

packaging="$src/packaging/ubuntu"
version="$("$packaging/build-deb.sh" --version)"
arch="$(dpkg --print-architecture)"

if ((!force)) && [[ "$(dpkg-query -W -f='${Version}' noctalia 2>/dev/null)" == "$version" ]]; then
    echo "noctalia $version already installed"
    exit 0
fi

deb="$DEB_DIR/noctalia_${version}_${arch}.deb"
if ((force)) || [[ ! -f $deb ]]; then
    "$packaging/build-deb.sh" --out "$DEB_DIR"
fi

# Pulls in libsdbus-c++2 from ppa:cppiber/hyprland
sudo apt-get install -y "$deb"
