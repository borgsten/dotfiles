#!/usr/bin/env zsh

export EDITOR="nvim"
export VISUAL="nvim"

export PAGER='less'
export MANPAGER='nvim +Man!'

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export GOPATH="$HOME/.local/go"

# Keep path arrays free of duplicates (first occurrence wins)
typeset -gU path fpath

export PATH="$GOPATH/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$XDG_RUNTIME_DIR/ssh-agent.socket}"

# Make debian stop fucking with my completion
export skip_global_compinit=1

if [[ -f "${ZDOTDIR}/local/zshenv" ]]; then
    source "${ZDOTDIR}/local/zshenv"
fi
