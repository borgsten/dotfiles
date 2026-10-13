#!/usr/bin/env zsh

# Login shells: put mise shims on PATH so tools started from login shell can resolve shims.
if (( $+commands[mise] )); then
    eval "$(mise activate zsh --shims)"
fi
