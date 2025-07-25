#!/usr/bin/env zsh

# https://thevaluable.dev/zsh-completion-guide-examples/

autoload -Uz compinit && compinit

# Include .* and .. in completion results unprovoked
# _comp_options+=(globdots)

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

zstyle ':completion:*:*:*:*:*' menu select

# Use cache for commands using cache
mkdir -p "$XDG_CACHE_HOME/zsh"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

# Complete the alias when _expand_alias is used as a function
zstyle ':completion:*' complete true

zstyle ':completion:*' special-dirs true

# squash // to /
zstyle ':completion:*' squeeze-slashes true

zstyle ':completion:*' complete-options true

# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

# Colors
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

autoload -U +X bashcompinit && bashcompinit
