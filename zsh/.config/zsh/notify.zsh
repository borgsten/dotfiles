#!/usr/bin/env zsh

# Notify when a command runs longer than LONGCMD_NOTIFY_THRESHOLD seconds.
# Sends a desktop notification and rings the terminal bell, which the terminal
# turns into an urgency hint on the window (SUPER+U jumps to it in Hyprland).
# Interactive/TUI programs are skipped, since their runtime is just how long
# you had them open.

typeset -g LONGCMD_NOTIFY_THRESHOLD=${LONGCMD_NOTIFY_THRESHOLD:-120}
typeset -ga LONGCMD_NOTIFY_IGNORE=(
    nvim vim vi nano emacs less more man bat
    ssh mosh tmux zellij
    htop btop top nvtop watch
    lazygit lazydocker tig yazi ranger nnn fzf
    python python3 ipython node irb psql mysql sqlite3 iex ghci
    claude
)

zmodload zsh/datetime

# Prefixes that just wrap the real command
typeset -ga _longcmd_wrappers=(sudo doas env time nohup nice command builtin exec noglob)

_longcmd_preexec() {
    emulate -L zsh
    typeset -g _longcmd_start=$EPOCHREALTIME _longcmd_cmd=$1

    # $3 has aliases expanded
    local -a words=(${(z)3})
    local word
    for word in $words; do
        [[ $word == *=* || $word == -* || ${_longcmd_wrappers[(Ie)$word]} -gt 0 ]] && continue
        break
    done

    # Resolve `fg`/`%n` to the job being resumed (e.g. a suspended nvim)
    if [[ $word == fg || $word == %* ]]; then
        local spec=${words[2]:-%+}
        [[ $word == %* ]] && spec=$word
        local num
        if [[ $spec == %(+|%|) ]]; then
            for num in ${(k)jobstates}; do
                [[ ${jobstates[$num]} == *:+:* ]] && break
            done
        else
            num=${spec#%}
        fi
        word=${${(z)jobtexts[$num]}[1]}
    fi

    typeset -g _longcmd_ignored=${${LONGCMD_NOTIFY_IGNORE[(Ie)${word:t}]}:#0}
}

_longcmd_precmd() {
    local exit_code=$?
    emulate -L zsh
    [[ -n $_longcmd_start ]] || return
    local elapsed=$(( EPOCHREALTIME - _longcmd_start ))
    unset _longcmd_start

    (( elapsed >= LONGCMD_NOTIFY_THRESHOLD )) && [[ -z $_longcmd_ignored ]] || return

    local secs=${elapsed%.*} took
    took=$(printf '%d:%02d:%02d' $((secs / 3600)) $((secs % 3600 / 60)) $((secs % 60)))

    if (( exit_code == 0 )); then
        notify-send -a zsh "✅ Command completed" "$_longcmd_cmd\nTook $took" &!
    else
        notify-send -a zsh -u critical "❌ Command failed (exit $exit_code)" "$_longcmd_cmd\nTook $took" &!
    fi
    print -n '\a' > $TTY
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _longcmd_preexec
add-zsh-hook precmd _longcmd_precmd
