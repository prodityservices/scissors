#!/usr/bin/env bash

(
PS1="$"
basedir="$(cd "$1" && pwd -P)"
gitcmd="git -c commit.gpgsign=false"
applycmd="$gitcmd am --3way --ignore-whitespace"
# Windows detection to workaround ARG_MAX limitation
windows="$([[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]] && echo "true" || echo "false")"

echo "Rebuilding Forked projects.... "

function applyPatch {
    what=$1
    what_name=$(basename "$what")
    target=$2
    branch=$3

    cd "$basedir/$what"
    $gitcmd fetch
    $gitcmd branch -f upstream "$branch" >/dev/null

    cd "$basedir"
    if [ ! -d  "$basedir/$target" ]; then
        $gitcmd clone "$what" "$target"
    fi
    cd "$basedir/$target"

    echo "Resetting $target to $what_name..."
    $gitcmd remote rm upstream > /dev/null 2>&1
    $gitcmd remote add -f upstream "../$what" >/dev/null 2>&1
    $gitcmd checkout master 2>/dev/null || $gitcmd checkout -b master
    $gitcmd fetch upstream >/dev/null 2>&1
    $gitcmd reset --hard upstream/upstream
	
	if [ ! -f "$basedir/${what_name}-Patches/"*.patch ]; then
        echo "  No patches found to apply to $target!"
		return 0
	fi
	
    echo "  Applying patches to $target..."

    $gitcmd am --abort >/dev/null 2>&1

    # Special case Windows handling because of ARG_MAX constraint
    if [[ $windows == "true" ]]; then
        echo "  Using workaround for Windows ARG_MAX constraint"
        find "$basedir/${what_name}-Patches/"*.patch -print0 | xargs -0 $applycmd
    else
        $applycmd "$basedir/${what_name}-Patches/"*.patch
    fi

    if [ "$?" != "0" ]; then
        echo "  Something did not apply cleanly to $target."
        echo "  Please review above details and finish the apply then"
        echo "  save the changes with rebuildPatches.sh"

        # On Windows, finishing the patch apply will only fix the latest patch
        # users will need to rebuild from that point and then re-run the patch
        # process to continue
        if [[ $windows == "true" ]]; then
            echo ""
            echo "  Because you're on Windows you'll need to finish the AM,"
            echo "  rebuild all patches, and then re-run the patch apply again."
            echo "  Consider using the scripts with Windows Subsystem for Linux."
        fi

        exit 1
    else
        echo "  Patches applied cleanly to $target"
    fi
}

# Move into paper dir
pushd Paper
basedir=$basedir/Paper

# Apply Spigot
(
    applyPatch Bukkit Spigot-API HEAD &&
    applyPatch CraftBukkit Spigot-Server patched
) || (
    echo "Failed to apply Spigot Patches"
    exit 1
) || exit 1

echo "Importing Paper MC Dev"

# Scissors - remove unless this is required down the road.
# ./scripts/importmcdev.sh "$basedir" >/dev/null 2>&1  

# Apply paper
(
    applyPatch Spigot-API Paper-API HEAD &&
    applyPatch Spigot-Server Paper-Server HEAD
) || (
    echo "Failed to apply Paper Patches"
    exit 1
) || exit 1

# Move out of paper
popd 
basedir=$(dirname "$basedir")

echo "Importing Scissors MC Dev"
./scripts/importmcdev.sh "$basedir" >/dev/null 2>&1

# Apply Scissors
(
    applyPatch "Paper/Paper-API" Scissors-API HEAD &&
    applyPatch "Paper/Paper-Server" Scissors-Server HEAD
) || (
    echo "Failed to apply Paper Patches"
    exit 1
) || exit 1

)
