#!/usr/bin/env zsh

# https://wiki.archlinux.org/title/zsh#Key_bindings

bindkey -v

typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Ctrl-Left]="${terminfo[kLFT5]}"
key[Ctrl-Right]="${terminfo[kRIT5]}"

typeset -ga home_keys end_keys
home_keys=("${key[Home]}" $'\e[H' $'\eOH' $'\e[1~' $'\e[7~')
end_keys=("${key[End]}" $'\e[F' $'\eOF' $'\e[4~' $'\e[8~')

# load widgets
autoload -U up-line-or-beginning-search down-line-or-beginning-search reverse-menu-complete
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N reverse-menu-complete

# setup key accordingly
[[ -n "${key[Insert]}"     ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}"  ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"     ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Shift-Tab]}"  ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete

# Navigation keys need binding in both viins and vicmd: bindkey without -M only
# hits viins (bindkey -v already made that the "main" keymap above), so in vi
# command mode their raw escape sequences fell through to the vi keymap and got
# parsed as commands (e.g. Home/End end in "~", which is vi-swap-case - hence
# text randomly turning uppercase after pressing Home/End).
for km in viins vicmd; do
    for seq in "${home_keys[@]}"; do
        [[ -n "$seq" ]] && bindkey -M $km -- "$seq" beginning-of-line
    done
    for seq in "${end_keys[@]}"; do
        [[ -n "$seq" ]] && bindkey -M $km -- "$seq" end-of-line
    done
    [[ -n "${key[Up]}"         ]] && bindkey -M $km -- "${key[Up]}"         up-line-or-beginning-search
    [[ -n "${key[Down]}"       ]] && bindkey -M $km -- "${key[Down]}"       down-line-or-beginning-search
    [[ -n "${key[Left]}"       ]] && bindkey -M $km -- "${key[Left]}"       backward-char
    [[ -n "${key[Right]}"      ]] && bindkey -M $km -- "${key[Right]}"      forward-char
    [[ -n "${key[PageUp]}"     ]] && bindkey -M $km -- "${key[PageUp]}"     beginning-of-buffer-or-history
    [[ -n "${key[PageDown]}"   ]] && bindkey -M $km -- "${key[PageDown]}"   end-of-buffer-or-history
    [[ -n "${key[Ctrl-Left]}"  ]] && bindkey -M $km -- "${key[Ctrl-Left]}"  backward-word
    [[ -n "${key[Ctrl-Right]}" ]] && bindkey -M $km -- "${key[Ctrl-Right]}" forward-word
done

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start { echoti smkx }
    function zle_application_mode_stop { echoti rmkx }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi
