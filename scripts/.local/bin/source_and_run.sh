#!/usr/bin/env zsh

CMD="$1"
SOURCE_FILE="$2"

if [[ -n "$SOURCE_FILE" ]]; then
    if [[ ! -f "$SOURCE_FILE" ]]; then
        echo "Pre run file $SOURCE_FILE does not exist."
        exit 1
    fi
    source "$SOURCE_FILE"
fi

$CMD
