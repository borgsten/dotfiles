#!/usr/bin/env zsh

NEWLINE='
'

curr_time() {
    echo -n "%{$fg_bold[green]%}%T "
}

#Print current user, if root in red else in yellow
user() {
    if [[ $USER == "root" ]]; then
        echo -n "%{$fg_bold[red]%}"
    else
        echo -n "%{$fg_bold[yellow]%}"
    fi
    echo -n "%n%{$reset_color%}"
}

host() {
    if [[ -n $SSH_CONNECTION ]]; then
        echo -n "$(user)"
        echo -n "@"
        echo -n "%{$fg_bold[yellow]%}%m%{$reset_color%} "
    elif [[ $LOGNAME != $USER ]] || [[ $USER == 'root' ]];then
        echo -n "$(user)"
        echo -n " %Bin%b "
        echo -n "%{$reset_color%} "
    fi
}

# Return only three last items of path
curr_dir() {
    echo -n "%{$fg_bold[cyan]%}%~%{$reset_color%}"
}

PROMPT_SYMBOL="${PROMPT_SYMBOL:-➔}"
return_status() {
    echo -n "%(?.%{$fg[green]%}.%{$fg[red]%})"
    echo -n "%B${PROMPT_SYMBOL}%b "
    echo -n "%{$reset_color%}"
}

venv_status() {
    if [[ -z $VIRTUAL_ENV ]]; then
        return
    fi
    VENV_NAME=$(basename $VIRTUAL_ENV)
    echo -n "%{$fg_bold[yellow]%}"
    echo -n "%B(${VENV_NAME})%b"
    echo -n "%{$reset_color%}"
}

prompt() {
    autoload -U colors && colors
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd prompt

    # Git theming
    ZSH_GIT_PROMPT_SHOW_LOCAL_COUNTS=0

    PROMPT='$(curr_time)$(host)$(curr_dir) $(venv_status)$NEWLINE$(return_status)'
    RPROMPT='$(gitprompt)'
}
prompt
