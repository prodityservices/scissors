#!/usr/bin/env bash

(
set -e
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/Paper/work"
gitcmd="git -c commit.gpgsign=false"

rm -rf $basedir/scissors.jar

($gitcmd submodule update --init --recursive --force && ./scripts/remap.sh "$basedir" && ./scripts/decompile.sh "$basedir" && ./scripts/init.sh "$basedir" && ./scripts/applyPatches.sh "$basedir") || (
    echo "Failed to build Scissors"
    exit 1
) || exit 1
if [ "$2" == "--jar" ]; then
    echo " "
    echo " Compiling and installing scissors jar..."
    echo " "
    mvn clean install
	cp ./Scissors-Server/target/scissors*-SNAPSHOT.jar ./scissors.jar
fi
) || exit 1

echo " "
echo " Scissors build completed successfully."
echo " "