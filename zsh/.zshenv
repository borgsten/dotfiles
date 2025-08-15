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
export HISTSIZE=100000
export SAVEHIST=100000

export GOPATH="$HOME/.local/go"

export PATH="$GOPATH/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

