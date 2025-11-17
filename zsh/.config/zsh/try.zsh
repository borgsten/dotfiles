#!/usr/bin/env bash

if [[ -f ~/.local/try.rb ]]; then
    eval "$(ruby ~/.local/try.rb init ~/dev/tries)"
    function trycpp () {
        try git@github.com:borgsten/cpp_template.git $1
        ./setup.sh
    }
fi
