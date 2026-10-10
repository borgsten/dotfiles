#!/usr/bin/env zsh

# https://thevaluable.dev/zsh-completion-guide-examples/
export ZSH_COMPLETION_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions"
mkdir -p "$ZSH_COMPLETION_DIR"

fpath+=("$ZSH_COMPLETION_DIR")

autoload -Uz compinit
# Rebuild the dump once every 24h, otherwise load the cache
mkdir -p "$XDG_CACHE_HOME/zsh"
compdump=$XDG_CACHE_HOME/zsh/zcompdump
if [[ ! -e $compdump || -n $(print -r -- $compdump(N.mh+24)) ]]; then
    compinit -d $compdump
    touch $compdump
else
    compinit -C -d $compdump
fi
{ [[ $compdump.zwc -nt $compdump ]] || zcompile -R -- $compdump.zwc $compdump } &!
unset compdump

# Include .* and .. in completion results unprovoked
# _comp_options+=(globdots)

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

zstyle ':completion:*:*:*:*:*' menu select

# Use cache for commands using cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# Complete the alias when _expand_alias is used as a function
zstyle ':completion:*' complete true

# offer ../ only when .. is typed; never list . and .. among hidden files
zstyle -e ':completion:*' special-dirs '[[ $PREFIX == (*/|).. ]] && reply=(..) || reply=(false)'

# squash // to /
zstyle ':completion:*' squeeze-slashes true

zstyle ':completion:*' complete-options true

# case insensitive, then foo-bar from f-b (also . and _), then substring
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Autocomplete processes
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Colors. Set on the default tag only: per-tag styles get copied once per
# group, multiplying the ~700 LS_COLORS patterns and slowing menu redraws.
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

# Group candidates under headers
zstyle ':completion:*' group-name ''
# Header colours follow the matugen theme (same as the prompt, see p10k.zsh)
zstyle -e ':completion:*:*:*:*:descriptions' format 'reply=("%F{${P10K_DIR_FG:-green}}-- %d --%f")'
zstyle -e ':completion:*:*:*:*:corrections' format 'reply=("%F{${P10K_VCS_MODIFIED_FG:-yellow}}-- %d (errors: %e) --%f")'
zstyle -e ':completion:*:warnings' format 'reply=("%F{${P10K_ERROR_FG:-red}}-- no matches found --%f")'

# Pick up newly installed binaries without a manual rehash
zstyle ':completion:*' rehash true

# Hide completion functions and hooks from command-name completion
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Keep man sections apart, e.g. printf(1) vs printf(3)
zstyle ':completion:*:manuals' separate-sections true

autoload -U +X bashcompinit && bashcompinit
