#!/usr/bin/env zsh

# Unwrap dots
alias ...=../..
alias ....=../../..
alias .....=../../../..
alias ......=../../../../..
alias .......=../../../../../..

# alias for consuming dirstack
for index ({1..9}) do
  alias "$index"="cd -${index}"
done
unset index

# Git aliases
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gca='git commit --amend'
alias gd='git diff'
alias gdc='git diff --cached'
alias gl='git pull'
alias gp='git push'
alias gst='git status'

# ls/eza
alias la='ls -lA'
alias ll='ls -l'
if (( $+commands[eza] )); then
    alias ls='eza'
    alias llt='ll -T'
    alias lat='la -T'
else
    alias ls='ls --color=tty -h'
fi

# zoxide
if (( $+commands[zoxide] )); then
    alias cd='echo use z;cd'
else
    alias z='cd'
fi

# pacman alias
alias pacin='sudo pacman -S'
alias pacsearch='pacman -Ss'
alias pacupd='sudo pacman -Sy'
alias pacupg='sudo pacman -Syu'
alias pacrem='sudo pacman -Rns'

# bookmarks
alias dl='cd ~/Downloads && ls'
alias tmp='cd /tmp && ls'

# File alias
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias grep='grep --color'
alias opn='xdg-open'

alias py='ipython3'
alias history='fc -l 1'

alias :q='exit'
alias please='sudo !!'

alias addkey='ssh-add ~/.ssh/id_rsa'

alias vim='nvim'

alias vact='source venv/bin/activate'
