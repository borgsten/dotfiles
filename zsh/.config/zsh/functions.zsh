#!/usr/bin/env zsh

function mkd() {
    mkdir -p -- "$1" && cd -- "$1"
}

function tmpc() {
    cd -- "$(mktemp -d --tmpdir "td.${1:-$(date +%H_%M)}.XXX")"
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
    xmllint --format "$1" | bat
}

function glog() {
    local -x LESS="${LESS/--quit-if-one-screen}"
    local -a all revs pos
    local line
    # -a: also draw every local and remote branch
    zparseopts -D -E a=all && (( $#all )) && all=(HEAD --branches --remotes)
    local -a gitlog=(git log --graph $all)

    # With -a, start the cursor on the topmost revision given instead of the newest commit
    (( $#all )) && revs=(${(M)${(f)"$(git rev-parse --revs-only --no-flags "$@" 2>/dev/null)"}:#[^^]*})
    if (( $#revs )); then
        line=$($gitlog --format=%H "$@" | grep -n -m1 -F "${(F)revs}")
        [[ -n $line ]] && pos=(--scroll-off=10 --bind "load:pos(${line%%:*})")
    fi

    $gitlog --color=always \
        --format='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' "$@" |
        fzf --ansi --no-sort --reverse --tiebreak=index --toggle-sort=\` $pos \
        --bind 'enter:execute:h=$(printf %s {} | grep -oE "[0-9a-f]{7,}" | head -1); [ -n "$h" ] && git show "$h"'
}
compdef _git glog=git-log

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

function gcm() {
    git rev-parse --git-dir >/dev/null || return
    local branch b
    # origin/HEAD tracks the remote's actual default branch
    branch=$(git symbolic-ref --short -q refs/remotes/origin/HEAD) && branch=${branch#origin/}
    if [[ -z $branch ]]; then
        for b in main master; do
            if git show-ref --verify --quiet refs/heads/$b ||
               git show-ref --verify --quiet refs/remotes/origin/$b; then
                branch=$b
                break
            fi
        done
    fi
    if [[ -z $branch ]]; then
        echo "gcm: can't determine default branch (try: git remote set-head origin -a)" >&2
        return 1
    fi
    git switch "$branch"
}

# This file is stowed from <dotfiles>/zsh/.config/zsh
DOTFILES_DIR=${${(%):-%x}:A:h:h:h:h}

function dot() {
    local cmd=$1
    (( $# )) && shift
    cd "$DOTFILES_DIR" || return
    case $cmd in
        '')
            ls
            ;;
        stow)
            bootstrap/stow.sh "$@"
            ;;
        pull)
            local -a stow
            zparseopts -D -F s=stow || return
            git pull || return
            if (( $#stow )); then
                bootstrap/stow.sh
            fi
            ;;
        install|update)
            bootstrap/install.sh "$@"
            ;;
        check)
            bootstrap/healthcheck.sh "$@"
            ;;
        *)
            echo "Usage: dot [stow [args...] | pull [-s] | install|update [args...] | check [section...]]" >&2
            return 2
            ;;
    esac
}

function _dot() {
    local -a cmds=(
        'stow:stow configs into $HOME'
        'pull:pull the dotfiles repo'
        'install:install missing software for this distro'
        'update:install missing software for this distro'
        'check:check that the tools the dotfiles rely on are installed'
    )
    if (( CURRENT == 2 )); then
        _describe command cmds
        return
    fi
    case $words[2] in
        stow) _arguments '(-D --delete)'{-D,--delete}'[unstow]' '*:config:_path_files -W $DOTFILES_DIR -/' ;;
        pull) _arguments '-s[stow after pulling]' ;;
        check) _values -w section shell neovim terminal desktop setup ;;
    esac
}
compdef _dot dot

function diffdelay() {
    local cmd=$1 first second
    first=$(eval "$cmd")
    echo "Press any key to continue..."
    read -k1 -s
    second=$(eval "$cmd")
    diff <(print -r -- "$first") <(print -r -- "$second")
}

function alert() {
    local start end elapsed formatted_time exit_code

    start=$(date +%s)

    # eval preserves pipes, ;, ||, &&, redirections, etc.
    eval "$*"
    exit_code=$?

    end=$(date +%s)
    elapsed=$((end - start))
    formatted_time=$(printf "%02d:%02d" $((elapsed / 60)) $((elapsed % 60)))

    if [ "$exit_code" -eq 0 ]; then
        notify-send "✅ Command Completed" "$*\nCompleted in $formatted_time."
    else
        notify-send -u critical "❌ Command Failed" "$*\nFailed (exit $exit_code) after $formatted_time."
    fi

    # Bell alert on terminal window
    echo -e '\a'
    return $exit_code
}
