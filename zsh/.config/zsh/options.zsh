#!/usr/bin/env zsh

# https://zsh.sourceforge.io/Doc/Release/Options.html

# CD related
setopt autocd               # try cd if not a command
setopt autopushd            # perform pushd when cd
setopt pushdignoredups      # no dups to pushd
setopt pushdminus           # switch + and - when consuming stack with numbers

# Completion
setopt alwaystoend          # move cursor to end of completion
setopt completeinword       # don't move cursor until completion is done
setopt globcomplete         # do not expand globs until completion is done TODO
setopt nullglob             # if glob pattern does not match remove pattern

# History
setopt extendedhistory      # save history with timestamp
setopt histexpiredupsfirst  # remove dups from history first
setopt histfindnodups       # ignore duplicates in history search
setopt histignoredups       # ignore command if it is previous
setopt histignorespace      # do no record commands with leading space
setopt histverify           # do not remove comand from history directly
setopt sharehistory         # write history from multiple instances directly

# Input/Output
setopt noflowcontrol        # disable flow control. Why? TODO
setopt interactivecomments  # allow comments in shell

# Job control
setopt autocontinue         # auto continue stopped processes on disown TODO
setopt monitor              # allow job control
setopt longlistjobs         # print job notif in long format

# Prompt
setopt promptsubst          # allow prompt substitution
setopt transientrprompt     # remove right prompt while accepting input
