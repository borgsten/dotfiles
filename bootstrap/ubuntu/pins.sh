# Pinned versions for everything ubuntu.sh does not get from apt.
# Sourced by the scripts in this directory; bump a pin and re-run ubuntu.sh.

TOOLS_DIR="${TOOLS_DIR:-$HOME/tools}"
# Built and downloaded .debs, kept so a reinstall never depends on upstream
DEB_DIR="$TOOLS_DIR/debs"

# Built from source with `cpack -G DEB` (neovim.sh)
NEOVIM_TAG=v0.12.5

# Ubuntu 24.04 fork, built by its packaging/ubuntu/build-deb.sh (noctalia.sh).
# A commit, since the fork's changes sit on top of upstream's release tags
NOCTALIA_REPO=https://github.com/borgsten/noctalia.git
NOCTALIA_REF=cfde6ca5391b97c6b625779d56efea5dd05216d5

# Rolling nightly until a proper release lands; `wezterm.sh --pin` updates these
WEZTERM_NIGHTLY_VERSION=20260917-114457-b09b56c2
WEZTERM_NIGHTLY_SHA256=903d4edac4e4bd15a4720ae4f28dd1b1b5e7224276f9281c2aaaef2c77630e57

NERD_FONTS_VERSION=v3.5.1
