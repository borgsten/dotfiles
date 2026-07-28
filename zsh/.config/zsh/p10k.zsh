#!/usr/bin/env zsh

_p10k_apply_matugen_colors() {
  source ~/.cache/theming/p10k.zsh

  # ---- Simple variable-driven segments (Lean style: plain text, no
  # colored background pills).
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=$P10K_DIR_FG
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$P10K_DIR_ANCHOR_FG

  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$P10K_VCS_CLEAN_FG
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$P10K_VCS_MODIFIED_FG
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=$P10K_VCS_UNTRACKED_FG
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=$P10K_VCS_CONFLICTED_FG

  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=$P10K_OK_FG
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$P10K_ERROR_FG

  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=$P10K_VCS_CLEAN_FG
  typeset -g POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR=$P10K_VCS_LOADING_FG

  typeset -g POWERLEVEL9K_TIME_FOREGROUND=$P10K_TIME_FG
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=$P10K_CONTEXT_FG
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$P10K_VENV_FG

  function my_git_formatter() {
    emulate -L zsh

    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi

    if (( $1 )); then
      local       meta='%f'
      local      clean="%F{${P10K_VCS_CLEAN_FG}}"
      local   modified="%F{${P10K_VCS_MODIFIED_FG}}"
      local  untracked="%F{${P10K_VCS_UNTRACKED_FG}}"
      local conflicted="%F{${P10K_VCS_CONFLICTED_FG}}"
    else
      local       meta="%F{${P10K_VCS_LOADING_FG}}"
      local      clean="%F{${P10K_VCS_LOADING_FG}}"
      local   modified="%F{${P10K_VCS_LOADING_FG}}"
      local  untracked="%F{${P10K_VCS_LOADING_FG}}"
      local conflicted="%F{${P10K_VCS_LOADING_FG}}"
    fi

    local res

    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
      (( $#branch > 32 )) && branch[13,-13]="…"
      res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
    fi

    if [[ -n $VCS_STATUS_TAG && -z $VCS_STATUS_LOCAL_BRANCH ]]; then
      local tag=${(V)VCS_STATUS_TAG}
      (( $#tag > 32 )) && tag[13,-13]="…"
      res+="${meta}#${clean}${tag//\%/%%}"
    fi

    [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&
      res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"

    if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
      res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
    fi

    if [[ $VCS_STATUS_COMMIT_SUMMARY == (|*[^[:alnum:]])(wip|WIP)(|[^[:alnum:]]*) ]]; then
      res+=" ${modified}wip"
    fi

    if (( VCS_STATUS_COMMITS_AHEAD || VCS_STATUS_COMMITS_BEHIND )); then
      (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
      (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
      (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
    elif [[ -n $VCS_STATUS_REMOTE_BRANCH ]]; then
      :
    fi

    (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
    (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" "
    (( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
    (( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
    [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
    (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
    (( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"
    (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─"

    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null
}

_p10k_colors_check() {
  local f=~/.cache/theming/p10k.zsh mtime
  mtime=$(zstat +mtime "$f" 2>/dev/null)
  if [[ "$mtime" != "$_p10k_colors_mtime" ]]; then
    _p10k_colors_mtime=$mtime
    p10k reload
    _p10k_apply_matugen_colors
    p10k reload
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _p10k_colors_check

source ${ZDOTDIR:-$HOME}/.p10k.zsh
_p10k_apply_matugen_colors
