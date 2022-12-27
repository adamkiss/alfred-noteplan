#!/usr/bin/env sh

link () {
    ln -s \
        /Users/adam/Code/alfred-noteplan-fts2/workflow \
        /Users/adam/Code/dotfiles/config/alfred5/Alfred.alfredpreferences/workflows/alfred-noteplan-fts2;
}

unlink () {
    rm /Users/adam/Code/dotfiles/config/alfred5/Alfred.alfredpreferences/workflows/alfred-noteplan-fts2;
}

# fake npm scripts hahaha
script=`shift 1`
$script "$@"