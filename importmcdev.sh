#!/usr/bin/env bash

echo "GO!"

(
set -e
nms="net/minecraft/server"
export MODLOG=""
PS1="$"
basedir="$(cd "$1" && pwd -P)"
gitcmd="git -c commit.gpgsign=false"

workdir="$basedir/Paper"
minecraftversion=$(cat "$workdir/BuildData/info.json"  | grep minecraftVersion | cut -d '"' -f 4)
decompiledir="$workdir/work/$minecraftversion"

function import {
    file="${1}.java"
    target="$basedir/Paper/PaperSpigot-Server/src/main/java/$nms/$file"
    base="$decompiledir/$nms/$file"

    if [[ ! -f "$target" ]]; then
        export MODLOG="$MODLOG  Imported $file from mc-dev\n";
        echo "Copying $base to $target"
        cp "$base" "$target"
    fi
}

function importAll {
	echo "Importing ALL files from mc-dev..."
	export MODLOG="$MODLOG  Imported ALL files from mc-dev\n";
    cp -nrv $decompiledir/$nms/* $basedir/Paper/PaperSpigot-Server/src/main/java/$nms/
	echo "Import complete."
}

(
    cd "$workdir/PaperSpigot-Server/"
    lastlog=$($gitcmd log -1 --oneline)
    if [[ "$lastlog" = *"mc-dev Imports"* ]]; then
        $gitcmd reset --hard HEAD^
    fi
)

# Scissors imports
import BlockState
import BlockStateList
import PacketPlayOutPlayerInfo
import ShapeDetector
import StructureBoundingBox
import WorldGenCaves

cd "$workdir/PaperSpigot-Server/"
rm -rf nms-patches applyPatches.sh makePatches.sh >/dev/null 2>&1
$gitcmd add . -A >/dev/null 2>&1
echo -e "mc-dev Imports\n\n$MODLOG" | $gitcmd commit . -F -
)


echo "stop!"