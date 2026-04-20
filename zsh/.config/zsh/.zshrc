#!/usr/bin/env zsh

# Debug startup time
# zmodload zsh/zprof

# Reaffirm history to prevent truncation
mkdir -p "$XDG_STATE_HOME/zsh"
if [[ ! -f "$XDG_STATE_HOME/zsh/history" ]]; then
    cp "$HOME/.zsh_history" "$XDG_STATE_HOME/zsh/history"
fi
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=1000000
export SAVEHIST=1000000

source "$ZDOTDIR/exports.zsh"
source "$ZDOTDIR/options.zsh"
source "$ZDOTDIR/completion.zsh"
source "$ZDOTDIR/functions.zsh"
source "$ZDOTDIR/alias.zsh"
source "$ZDOTDIR/keybindings.zsh"
source "$ZDOTDIR/prompt.zsh"
source "$ZDOTDIR/try.zsh"

for file in $ZDOTDIR/local/*.sh(N); do
    source "$file"
done

[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# Snytax highlighting needs to be loaded last
source "$ZDOTDIR/plugins.zsh"

# zprof
