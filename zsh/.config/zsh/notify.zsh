#!/usr/bin/env zsh

# Notify when a command runs longer than LONGCMD_NOTIFY_THRESHOLD seconds.
# Sends a desktop notification and rings the terminal bell, which the terminal
# turns into an urgency hint on the window (SUPER+U jumps to it in Hyprland).
#
# Interactive programs are detected rather than listed: the kernel bumps the
# atime of the tty whenever something reads input from it (this is what `w`
# uses for idle time). We only notify if the command ran for the threshold
# *after* its last read, so editors/TUIs/REPLs (which read your keys until you
# quit them) are skipped, while e.g. `sudo make` still notifies after the
# password prompt. Note the kernel only updates tty times with ~8s granularity.
#
# Nothing is sent while the terminal window (and on WezTerm, the pane) running
# the shell is focused. Focus detection is currently only done on Hyprland.
#
# Commands the detection gets wrong can be opted out explicitly:
#   LONGCMD_NOTIFY_IGNORE+=(foo bar)

typeset -g LONGCMD_NOTIFY_THRESHOLD=${LONGCMD_NOTIFY_THRESHOLD:-120}
typeset -ga LONGCMD_NOTIFY_IGNORE

# Prefixes that just wrap the real command
typeset -ga _longcmd_wrappers=(sudo doas env time nohup nice command builtin exec noglob)

zmodload zsh/datetime
zmodload -F zsh/stat b:zstat

_longcmd_preexec() {
    emulate -L zsh
    typeset -g _longcmd_start=$EPOCHREALTIME _longcmd_cmd=$1

    # Show the resumed job rather than `fg`/`%n` in the notification
    local -a words=(${(z)1})
    if [[ $words[1] == fg || $words[1] == %* ]]; then
        local spec=${${words[1]:#fg}:-${words[2]:-%+}}
        _longcmd_cmd=${jobtexts[$spec]:-$1}
        words=(${(z)_longcmd_cmd})
    else
        # $3 has aliases expanded
        words=(${(z)3})
    fi

    # Skip assignments, options and wrappers to find the actual command
    local word
    for word in $words; do
        [[ $word == *=* || $word == -* || ${_longcmd_wrappers[(Ie)$word]} -gt 0 ]] || break
    done
    (( ${LONGCMD_NOTIFY_IGNORE[(Ie)${word:t}]} )) && unset _longcmd_start
}

# Whether the window running this shell is focused
_longcmd_focused() {
    emulate -L zsh
    [[ -n $HYPRLAND_INSTANCE_SIGNATURE ]] && (( $+commands[hyprctl] )) || return 1
    local active_pid=${${(M)${(f)"$(hyprctl activewindow 2>/dev/null)"}:#*pid: *}##*pid: }
    [[ $active_pid == <-> ]] || return 1

    # WezTerm runs all its windows in one process, so ask it which pane has focus
    if [[ -n $WEZTERM_PANE ]] && (( $+commands[wezterm] && $+commands[jq] )); then
        wezterm cli list-clients --format json 2>/dev/null |
            jq -e --argjson pid $active_pid --argjson pane $WEZTERM_PANE \
                'any(.[]; .pid == $pid and .focused_pane_id == $pane)' >/dev/null
        return
    fi

    # Otherwise it's ours if the focused window's process is one of our ancestors
    local pid=$$ stat
    while (( pid > 1 )); do
        (( pid == active_pid )) && return 0
        [[ -r /proc/$pid/stat ]] || return 1
        stat=$(</proc/$pid/stat)
        pid=${${(s: :)${stat##*) }}[2]}
    done
    return 1
}

_longcmd_precmd() {
    local exit_code=$?
    emulate -L zsh
    [[ -n $_longcmd_start ]] || return
    local now=$EPOCHREALTIME start=$_longcmd_start
    local elapsed=$(( now - start ))
    unset _longcmd_start

    # Killed/stopped from the keyboard (^C, ^\, ^Z), so you were there to see it.
    # $signals[n+1] is the name of signal n
    (( exit_code > 128 )) && [[ ${signals[exit_code - 127]} == (INT|QUIT|TSTP) ]] && return

    # Time since the command last read from the terminal (or since it started)
    local last_input
    zstat -A last_input +atime -- $TTY 2>/dev/null || last_input=0
    local idle=$(( now - (last_input > start ? last_input : start) ))

    (( idle >= LONGCMD_NOTIFY_THRESHOLD )) || return
    _longcmd_focused && return

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
