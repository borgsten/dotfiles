#!/usr/bin/env zsh

source "$ZDOTDIR/exports.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/options.zsh"
source "$ZDOTDIR/completion.zsh"
source "$ZDOTDIR/functions.zsh"
source "$ZDOTDIR/alias.zsh"
source "$ZDOTDIR/keybindings.zsh"
source "$ZDOTDIR/prompt.zsh"

for file in $ZDOTDIR/local/*.sh(N); do
    source "$file"
done

[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
