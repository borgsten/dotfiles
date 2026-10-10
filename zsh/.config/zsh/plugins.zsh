#!/usr/bin/env zsh

# https://github.com/mattmc3/zsh_unplugged
function plugin-load {
    local repo plugdir initfile initfiles=()
    for plugin in $@; do
        repo="${plugin%@*}"
        ref="${plugin#*@}"
        if [[ "$repo" == "$plugin" ]]; then
            ref=""
        fi

        plugdir=$ZPLUGINDIR/${repo}
        initfile=$plugdir/${repo:t}.plugin.zsh
        if [[ ! -d $plugdir ]]; then
            echo "Cloning $repo..."
            git clone -q --depth 1 --recursive --shallow-submodules \
                https://github.com/$repo $plugdir
        fi

        # Fast path: a detached HEAD already at the pinned sha needs no git calls
        if [[ -n "$ref" && -f "$plugdir/.git/HEAD" && "$(<$plugdir/.git/HEAD)" != "$ref" ]]; then
            current_ref=$(git -C "$ZPLUGINDIR/$repo" rev-parse HEAD)
            desired_ref=$(git -C "$ZPLUGINDIR/$repo" rev-parse "$ref" 2>/dev/null)

            if [[ "$current_ref" != "$desired_ref" ]]; then
                echo "Checking out ${ref} in ${repo}"
                git -C "$ZPLUGINDIR/$repo" fetch -q --depth 1 origin "${ref}"
                git -C "$ZPLUGINDIR/$repo" checkout -q "${ref}"
                git -C "$ZPLUGINDIR/$repo" submodule update -q --init --recursive --depth 1
            else
                # Detach so the fast path above hits next time
                git -C "$ZPLUGINDIR/$repo" checkout -q --detach
            fi
        fi

        if [[ ! -e $initfile ]]; then
            initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
            (( $#initfiles )) || { echo >&2 "No init file found '$repo'." && continue }
            ln -sf $initfiles[1] $initfile
        fi
        fpath+=($plugdir)
        (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
    done
}

# Source a tool's generated init script, cached and compiled until the tool is
# reinstalled. Uses ctime: pacman restores the package mtime on binaries.
function cached-init() {
    local bin=${commands[$1]} cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init/$1.zsh
    local -a bin_ctime cache_mtime
    [[ -n $bin ]] || return 1
    zmodload -F zsh/stat b:zstat
    zstat -A bin_ctime +ctime -- $bin
    zstat -A cache_mtime +mtime -- $cache 2>/dev/null
    if (( ${cache_mtime:-0} <= bin_ctime )); then
        mkdir -p ${cache:h}
        if ! "$@" >| $cache 2>/dev/null || [[ ! -s $cache ]]; then
            rm -f $cache
            print -P "%F{yellow}cached-init: '$*' failed, $1 shell integration not loaded%f" >&2
            return 1
        fi
        zcompile -R $cache
    fi
    source $cache
}

ZPLUGINDIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh_plugins"
mkdir -p "$ZPLUGINDIR"

# zsh-vim-mode config
function zvm_config() {
    # Enable zsh vim mode yank-to-clipboard
    ZVM_SYSTEM_CLIPBOARD_ENABLED=true

    # Reload fzf keybindings after VI mode plugin
    # Sources the cache made by cached-init in .zshrc directly: zvm runs hooks
    # with a local $commands, hiding the one cached-init looks tools up in
    function reload_fzf_keybinds() {
        local init=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init/fzf.zsh
        [[ -r $init ]] && source $init
    }
    zvm_after_init_commands+=(reload_fzf_keybinds)
}

plugins=(
    zsh-users/zsh-completions@e07f6fb780725e9c0f50a7666700cf91ded30222

    # VI mode
    jeffreytse/zsh-vi-mode@80f78d9a3cc06843c776f60e4535b20bb857b1d4

    romkatv/powerlevel10k@9253fb1c5034410c43a0c681ff8294181c54016c
)
plugin-load $plugins

# Loaded at the very end of .zshrc, after all widgets are defined
plugins_last=(
    zsh-users/zsh-syntax-highlighting@5eb677bb0fa9a3e60f0eff031dc13926e093df92
)
