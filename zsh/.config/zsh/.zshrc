#!/usr/bin/env zsh

PROFILE=0

if [[ $PROFILE == 1 ]]; then
    zmodload zsh/zprof
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export skip_global_compinit=1

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
source "$ZDOTDIR/p10k.zsh"
source "$ZDOTDIR/try.zsh"

for file in $ZDOTDIR/local/*.sh(N); do
    # Skip reloading local zshenv
    if [[ "${file:t}" == "zshenv" ]]; then
        continue
    fi

    source "$file"
done

[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# Snytax highlighting needs to be loaded last
source "$ZDOTDIR/plugins.zsh"

if [[ $PROFILE == 1 ]]; then
    zprof
fi
