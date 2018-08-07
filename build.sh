#!/bin/bash

git submodule update --init --recursive && ./remap.sh && ./decompile.sh && ./init.sh && ./applyPatches.sh && mvn clean install

cp ./Scissors-Server/target/scissors*-SNAPSHOT.jar ./scissors.jar