#!/usr/bin/env bash

(
set -e
nms="net/minecraft/server"
export MODLOG=""
PS1="$"
basedir="$(cd "$1" && pwd -P)"
gitcmd="git -c commit.gpgsign=false"

workdir="$basedir/Paper/work"
minecraftversion=$(cat "$workdir/BuildData/info.json"  | grep minecraftVersion | cut -d '"' -f 4)
decompiledir="$workdir/Minecraft/$minecraftversion"

export importedmcdev=""
function import {
    export importedmcdev="$importedmcdev $1"
    file="${1}.java"
    target="$basedir/Paper/Paper-Server/src/main/java/$nms/$file"
    base="$decompiledir/$nms/$file"

    if [[ ! -f "$target" ]]; then
        export MODLOG="$MODLOG  Imported $file from mc-dev\n";
        echo "Copying $base to $target"
        cp "$base" "$target"
    else
        echo "UN-NEEDED IMPORT: $file"
    fi
}

(
    cd "Paper/Paper-Server/"
    lastlog=$($gitcmd log -1 --oneline)
    if [[ "$lastlog" = *"mc-dev Imports"* ]]; then
        $gitcmd reset --hard HEAD^
    fi
)

# import ClassNameHere

cd "Paper/Paper-Server/"
rm -rf nms-patches applyPatches.sh makePatches.sh >/dev/null 2>&1
$gitcmd add . -A >/dev/null 2>&1
echo -e "mc-dev Imports\n\n$MODLOG" | $gitcmd commit . -F -
)
