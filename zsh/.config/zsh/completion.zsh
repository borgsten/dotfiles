#!/usr/bin/env zsh

autoload -Uz compinit && compinit
_comp_options+=(globdots)

# Use cache for commands using cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
# Complete the alias when _expand_alias is used as a function
zstyle ':completion:*' complete true

zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true

zstyle ':completion:*' complete-options true

# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

autoload -U +X bashcompinit && bashcompinit
