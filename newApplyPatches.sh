#!/bin/bash

PS1="$"
basedir=`pwd`
echo "Rebuilding Forked projects.... "

function applyPatch {
    what=$1
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
    echo "Resetting $target to $what..."
    git remote add -f upstream ../$what >/dev/null 2>&1
    git checkout master >/dev/null 2>&1
    git fetch upstream >/dev/null 2>&1
    git reset --hard upstream/upstream
    echo "  Applying patches to $target..."
    git am --abort >/dev/null 2>&1
    git am --3way --ignore-whitespace "$basedir/${what}-Patches/"*.patch
    if [ "$?" != "0" ]; then
        echo "  Something did not apply cleanly to $target."
        echo "  Please review above details and finish the apply then"
        echo "  save the changes with rebuildPatches.sh"
        exit 1
    else
        echo "  Patches applied cleanly to $target"
    fi
}

applyPatch Paper/Bukkit Paper/Spigot-API HEAD && applyPatch Paper/CraftBukkit Paper/Spigot-Server patched
applyPatch Paper/Spigot-API Paper/PaperSpigot-API HEAD && applyPatch Paper/Spigot-Server Paper/PaperSpigot-Server HEAD
applyPatch Paper/PaperSpigot-API Scissors-API HEAD && applyPatch Paper/PaperSpigot-Server Scissors-Server HEAD