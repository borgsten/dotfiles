#!/usr/bin/env zsh

function mkd() {
    mkdir -p "$@" && cd "$@" || exit
}

function tmpc() {
    dir=$(mktemp -d)
    cd "$dir" || exit
}

function fo() {
    local out file key
    IFS=$'\n' out=($(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e))
    key=$(head -1 <<< "$out")
    file=$(head -2 <<< "$out" | tail -1)
    if [ -n "$file" ]; then
        [ "$key" = ctrl-o ] && xdg-open "$file" || ${EDITOR:-vim} "$file"
    fi
}

function ipaddress() {
    curl ifconfig.co
}

function f() {
    find . -name "$1" 2>&1 | grep -v 'Permission denied'
}

function notif() {
    if [ $# -eq 0 ]; then
        notify-send "DONE"
    else
        notify-send "$1" "$2"
    fi
}

function grp() {
    grep "$1" | grep -v grep
}

function xml() {
    xmllint --format $1 | bat
}

function glog() {
    LESS="${LESS[*]/--quit-if-one-screen /}"

    git log --graph --color=always --abbrev-commit \
        --format='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' "$@" |
        fzf --ansi --no-sort --reverse --tiebreak=index --toggle-sort=\` \
        --bind "ctrl-m:execute: echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % sh -c 'git show --color=always % | less -R'"
}

function venv() {
    if [ -e venv ]; then
        source venv/bin/activate
        return 0
    fi

    if [ -e .venv ]; then
        source .venv/bin/activate
        return 0
    fi

    echo "No virtual environment found"
    return 1
}

# Remove non-unique entries from an environment variable
function remove_non_unique_env_list() {
    variable_name=$1
    unique_entries=$(echo "${!variable_name}" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:\+$//')
    export "$variable_name=$unique_entries"
}

function gcm() {
    if git show-ref --verify --quiet refs/remotes/origin/main; then
        git checkout main
    elif git show-ref --verify --quiet refs/remotes/origin/master; then
        git checkout master
    else
      echo "Neither origin/main nor origin/master exists"
    fi
}

function diffdelay() {
    command="$1"
    first=$($command)
    echo "Press any key to continue..."
    read
    second=$($command)
    diff <(echo "$first") <(echo "$second")
}
