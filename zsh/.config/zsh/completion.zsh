#!/usr/bin/env zsh

autoload -Uz compinit && compinit
_comp_options+=(globdots)

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

# Use cache for commands using cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"
# Complete the alias when _expand_alias is used as a function
zstyle ':completion:*' complete true

zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs false

# squash // to /
zstyle ':completion:*' squeeze-slashes true

zstyle ':completion:*' complete-options true

# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

# Colors
zstyle ':completion:*' list-colors ''

autoload -U +X bashcompinit && bashcompinit
