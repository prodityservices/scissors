#!/usr/bin/env bash

(
set -e

rm -rf ./scissors.jar

(git submodule update --init --recursive && ./scripts/remap.sh && ./scripts/decompile.sh && ./scripts/init.sh && ./scripts/applyPatches.sh) || (
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