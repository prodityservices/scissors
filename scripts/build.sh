#!/usr/bin/env bash

(
set -e
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/Paper/work"
gitcmd="git -c commit.gpgsign=false"

($gitcmd submodule update --init --recursive && ./scripts/remap.sh "$basedir" && ./scripts/decompile.sh "$basedir" && ./scripts/init.sh "$basedir" && ./scripts/applyPatches.sh "$basedir") || (
    echo "Failed to build Scissors"
    exit 1
) || exit 1
if [ "$2" == "--jar" ]; then
    mvn clean install
	mcver=$(cat "$workdir/BuildData/info.json" | grep minecraftVersion | cut -d '"' -f 4)
	scissorsjar="$basedir/Scissors-Server/target/scissors-$mcver.jar"
	cp $scissorsjar $basedir/scissors.jar
fi
)
