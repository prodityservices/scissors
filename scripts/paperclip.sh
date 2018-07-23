#!/usr/bin/env bash

(
set -e
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/Paper/work"
mcver=$(cat "$workdir/BuildData/info.json" | grep minecraftVersion | cut -d '"' -f 4)
scissorsjar="$basedir/Scissors-Server/target/scissors-$mcver.jar"
vanillajar="$workdir/Minecraft/$mcver/$mcver.jar"

(
    cd "$workdir/Paperclip"
    mvn clean package "-Dmcver=$mcver" "-Dpaperjar=$scissorsjar" "-Dvanillajar=$vanillajar"
)
cp "$workdir/Paperclip/assembly/target/paperclip-${mcver}.jar" "$basedir/paperclip.jar"

echo ""
echo ""
echo "" # Scissors - TODO ensure this works as expected.
echo "Build success!"
echo "Copied final jar to $(cd "$basedir" && pwd -P)/paperclip.jar"
)