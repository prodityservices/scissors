#!/usr/bin/env bash

(
set -e
PS1="$"
basedir="$(cd "$1" && pwd -P)"
gitcmd="git -c commit.gpgsign=false"

function update {
    cd "$basedir/$1"
    $gitcmd fetch && $gitcmd reset --hard origin/master
    cd ../
    $gitcmd add $1
}

update Paper

# Scissors start
echo "Updating submodules"
git submodule update --init --recursive
# Scissors end
)