#!/usr/bin/env zsh

if [[ -n $ZSH_PROFILE ]]; then
    zmodload zsh/zprof
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -z $ZSH_PROFILE ]] && [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export skip_global_compinit=1

# History settings should not be exported to child preocesses.
typeset +x HISTFILE HISTSIZE SAVEHIST  # drop exports inherited from a parent
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=1000000
SAVEHIST=1000000

# Daily history snapshot (newest 7 kept). Will warn if size has shrinked > 50%.
() {
    local dir=${HISTFILE:h}/backup day
    print -v day -P '%D{%F}'
    [[ -f $HISTFILE && ! -f $dir/history.$day ]] || return
    local -a snaps=($dir/history.*(N.On))
    zmodload -F zsh/stat b:zstat
    if (( $#snaps )) && (( $(zstat +size $HISTFILE) < $(zstat +size $snaps[1]) / 2 )); then
        print -P "%F{red}zsh history shrank, not backing up. Snapshots in $dir%f"
        return
    fi
    mkdir -p $dir
    cp -p $HISTFILE $dir/.tmp$$ && mv -f $dir/.tmp$$ $dir/history.$day  # atomic vs concurrent shells
    rm -f -- $snaps[7,-1]
}

if (( $+commands[mise] )); then
    eval "$(mise activate zsh)"
fi

source "$ZDOTDIR/exports.zsh"
source "$ZDOTDIR/options.zsh"
source "$ZDOTDIR/plugins.zsh"
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

# Syntax highlighting needs to be loaded last
plugin-load $plugins_last

if [[ -n $ZSH_PROFILE ]]; then
    zprof
fi
