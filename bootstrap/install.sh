#!/usr/bin/env bash
# Run the bootstrap script for this distro.
#
# Usage: bootstrap/install.sh [args...]
#   args are passed on, e.g. extras for arch.sh

set -euo pipefail

here="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
id="$(source /etc/os-release && echo "$ID")"

case $id in
    arch|ubuntu) exec "$here/$id.sh" "$@" ;;
    *) echo "No bootstrap script for '$id'" >&2; exit 1 ;;
esac
