#!/usr/bin/env bash

PERF_LOG="${HOME}/perf.log"

function print_banner() {
    title="$1"
    character="$2"

    width=80
    left=$(printf "%*s" $(( (width - ${#title}) / 2 )) "" | tr ' ' "$character")
    right=$(printf "%*s" $(( (width - ${#title} + 1) / 2 )) "" | tr ' ' "$character")
    printf "\n%s%s%s\n" "$left" "$title" "$right"
}

while true; do
    {
        print_banner " $(date) " "+"

        # printf "\n++++++++++++ Free memory ++++++++++++\n"
        print_banner " Free memory " "+"
        free -h

        # printf "\n++++++++++++ Top 10 MEM ++++++++++++\n"
        print_banner " Top 10 MEM " "+"
        ps aux --sort=-%mem | head -n 11

        # printf "\n++++++++++++ Top 10 CPU ++++++++++++\n"
        print_banner " Top 10 CPU " "+"
        ps aux --sort=-%cpu | head -n 11
        print_banner "" "="
    } | tee -a "${PERF_LOG}"
    sleep 10
done
