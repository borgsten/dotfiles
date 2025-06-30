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

        if [[ -n "$ref" && -d "$ZPLUGINDIR/$repo/.git" ]]; then
            current_ref=$(git -C "$ZPLUGINDIR/$repo" rev-parse HEAD)
            desired_ref=$(git -C "$ZPLUGINDIR/$repo" rev-parse "$ref" 2>/dev/null)

            if [[ "$current_ref" != "$desired_ref" ]]; then
                echo "Checking out ${ref} in ${repo}"
                git -C "$ZPLUGINDIR/$repo" fetch -q --depth 1 origin "${ref}"
                git -C "$ZPLUGINDIR/$repo" checkout -q "${ref}"
                git -C "$ZPLUGINDIR/$repo" submodule update -q --init --recursive --depth 1
            fi
        fi

        if [[ ! -e $initfile ]]; then
            initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
            (( $#initfiles )) || { echo >&2 "No init file found '$repo'." && continue }
            ln -sf $initfiles[1] $initfile
        fi
        fpath+=$plugdir
        (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
    done
}

ZPLUGINDIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh_plugins"
mkdir -p "$ZPLUGINDIR"

plugins=(
    # Async git prompt
    woefe/git-prompt.zsh@0193adeb09fbc51fac738081a4718a3cf8427ff8
    zsh-users/zsh-completions@e07f6fb780725e9c0f50a7666700cf91ded30222

    # Should be last
    zsh-users/zsh-syntax-highlighting@5eb677bb0fa9a3e60f0eff031dc13926e093df92
)
plugin-load $plugins
