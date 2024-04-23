#!/usr/bin/env zsh

ZNAP_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/znap_plugins/znap"
[[ -r "${ZNAP_DIR}/znap.zsh" ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git "${ZNAP_DIR}"

source "${ZNAP_DIR}/znap.zsh"

# Async git prompt
znap source woefe/git-prompt.zsh

znap source zsh-users/zsh-syntax-highlighting
znap install zsh-users/zsh-completions
