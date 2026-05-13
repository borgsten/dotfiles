#!/usr/bin/env zsh

export EDITOR="nvim"
export VISUAL="nvim"

export PAGER='less'
export MANPAGER='nvim +Man!'

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000
export SAVEHIST=1000000

export GOPATH="$HOME/.local/go"

export PATH="$GOPATH/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

# Make debian stop fucking with my completion
export skip_global_compinit=1

if [[ -f "${ZDOTDIR}/local/zshenv" ]]; then
    source "${ZDOTDIR}/local/zshenv"
fi
