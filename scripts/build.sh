#!/bin/bash

git submodule update --init --recursive && ./scripts/remap.sh && ./scripts/decompile.sh && ./scripts/init.sh && ./scripts/applyPatches.sh && mvn clean install

echo " Deleting existing scissors.jar (if present)..."
rm -rf ./scissors.jar

echo " Copying new scissors.jar to root directory..."
cp ./Scissors-Server/target/scissors*-SNAPSHOT.jar ./scissors.jar

echo " "
echo " Scissors build complete."
echo " "