#!/bin/bash

PS1="$"
basedir=`pwd`
echo "Rebuilding Forked projects.... "

function applyPatch {
    what=$1
	what_name=$(basename "$what")
    target=$2
    branch=$3
    cd "$basedir/$what"
    git fetch
    git branch -f upstream "$branch" >/dev/null

    cd "$basedir"
    if [ ! -d  "$basedir/$target" ]; then
        git clone "$what" "$target"
    fi
    cd "$basedir/$target"
	
    echo "Resetting $target to $what_name..."
	git remote rm upstream > /dev/null 2>&1
    git remote add -f upstream $basedir/$what >/dev/null 2>&1
    git checkout master 2>/dev/null || git checkout -b master
    git fetch upstream >/dev/null 2>&1
    git reset --hard upstream/upstream
	
    if [ ! -f "$basedir/${what_name}-Patches/"*.patch ]; then
        echo "  No patches found to apply to $target!"
        return 0
    fi

    echo "  Applying patches to $target..."
    git am --abort >/dev/null 2>&1
    git am --3way --ignore-whitespace "$basedir/${what_name}-Patches/"*.patch
    if [ "$?" != "0" ]; then
        echo "  Something did not apply cleanly to $target."
        echo "  Please review above details and finish the apply then"
        echo "  save the changes with rebuildPatches.sh"
        exit 1
    else
        echo "  Patches applied cleanly to $target"
    fi
}

pushd Paper

basedir=$basedir/Paper

applyPatch Bukkit Spigot-API HEAD && applyPatch CraftBukkit Spigot-Server patched
applyPatch Spigot-API PaperSpigot-API HEAD && applyPatch Spigot-Server PaperSpigot-Server HEAD

popd

basedir=$(dirname "$basedir")

echo "Importing Scissors MC Dev"
./importmcdev.sh "$basedir"

applyPatch Paper/PaperSpigot-API Scissors-API HEAD && applyPatch Paper/PaperSpigot-Server Scissors-Server HEAD