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

(( $+commands[dircolors] )) && source <(dircolors -b)

# Ctrl+w deletes whole words
WORDCHARS='-_'

[[ -S "$XDG_RUNTIME_DIR/ssh-agent.socket" ]] && export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
