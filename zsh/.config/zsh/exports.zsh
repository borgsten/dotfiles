#!/usr/bin/env zsh

# fzf-marker
export MARKER_KEY_NEXT_PLACEHOLDER="^N"

# Highlighting inside manpages and elsewhere.
export LESS_TERMCAP_mb=$'\e[1;31m'          # start blinking
export LESS_TERMCAP_md=$'\e[1;34m'          # start bold mode
export LESS_TERMCAP_me=$'\e[0m'             # end all mode
export LESS_TERMCAP_so=$'\e[38;5;215m'      # start standout mode
export LESS_TERMCAP_se=$'\e[0m'             # end standout mode
export LESS_TERMCAP_us=$'\e[4;35m'          # start underline
export LESS_TERMCAP_ue=$'\e[0m'             # end underline

# less options
less_opts=(
    # Quit if entire file fits on first screen.
    # --quit-if-one-screen
    # Ignore case in searches that do not contain uppercase.
    --ignore-case
    # Allow ANSI colour escapes, but no other escapes.
    --RAW-CONTROL-CHARS
    # Quiet the terminal bell. (when trying to scroll past the end of the buffer)
    --quiet
    # Do not complain when we are on a dumb terminal.
    --dumb
)
export LESS="${less_opts[*]}"

# theme rendered by noctalia from theming/.config/matugen/templates/vivid.yml
typeset -g _vivid_theme="${XDG_CACHE_HOME:-$HOME/.cache}/theming/vivid.yml"
typeset -g _vivid_mtime=0

function _vivid_refresh() {
  local -a mtime
  zstat -A mtime +mtime -- "$_vivid_theme" 2>/dev/null || return
  (( mtime[1] == _vivid_mtime )) && return
  _vivid_mtime=$mtime[1]
  export LS_COLORS="$(vivid generate "$_vivid_theme")"
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
}

if (( $+commands[vivid] )) && [[ -f $_vivid_theme ]]; then
  zmodload -F zsh/stat b:zstat
  _vivid_refresh
  autoload -Uz add-zsh-hook
  # preexec: the theme usually changes while sitting at a prompt, so check
  # before running the command too, not only before drawing the next prompt
  add-zsh-hook preexec _vivid_refresh
  add-zsh-hook precmd _vivid_refresh
elif (( $+commands[vivid] )); then
  export LS_COLORS="$(vivid generate ansi)"
elif (( $+commands[dircolors] )); then
  source <(dircolors -b)
fi

# Ctrl+w deletes whole words
WORDCHARS='-_'

[[ -S "$XDG_RUNTIME_DIR/ssh-agent.socket" ]] && export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
