#!/bin/bash

# Author: MrBiTs (mrbits@mrbits.com.br)
# Date: 2021-12-05 (Stardate 99527.37)
#
# Function library

function parse_json() {
    # Receive a json formated string and extract the value of a given key
    # Usage: parse_json "JSON" key_to_read

    echo $1 |
        sed -e 's/[{}]/''/g' |
        sed -e 's/", "/'\",\"'/g' |
        sed -e 's/" ,"/'\",\"'/g' |
        sed -e 's/" , "/'\",\"'/g' |
        sed -e 's/","/'\"---SEPERATOR---\"'/g' |
        awk -F=':' -v RS='---SEPERATOR---' "\$1~/\"$2\"/ {print}" |
        sed -e "s/\"$2\"://" |
        tr -d "\n\t" |
        sed -e 's/\\"/"/g' |
        sed -e 's/\\\\/\\/g' |
        sed -e 's/^[ \t]*//g' |
        sed -e 's/^"//' -e 's/"$//'
}

function date_msg() {
    echo "[$(date +%F\ %T\ %z)] - $1"
    echo
}

# Colors
export fgBlack8="$(tput setaf 0)";
export fgRed8="$(tput setaf 1)";
export fgGreen8="$(tput setaf 2)";
export fgYellow8="$(tput setaf 3)";
export fgBlue8="$(tput setaf 4)";
export fgMagenta8="$(tput setaf 5)";
export fgCyan8="$(tput setaf 6)";
export fgWhite8="$(tput setaf 7)";

export bgBlack8="$(tput setab 0)";
export bgRed8="$(tput setab 1)";
export bgGreen8="$(tput setab 2)";
export bgYellow8="$(tput setab 3)";
export bgBlue8="$(tput setab 4)";
export bgMagenta8="$(tput setab 5)";
export bgCyan8="$(tput setab 6)";
export bgWhite8="$(tput setab 7)";

export bold="$(tput bold)"
export color_reset="$(tput sgr0)"

