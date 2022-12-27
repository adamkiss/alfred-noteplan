#!/usr/bin/env sh

link () {
    ln -s \
        /Users/adam/Code/alfred-noteplan-fts/workflow \
        /Users/adam/Code/dotfiles/config/alfred5/Alfred.alfredpreferences/workflows/alfred-noteplan-fts;
}

unlink () {
    rm /Users/adam/Code/dotfiles/config/alfred5/Alfred.alfredpreferences/workflows/alfred-noteplan-fts;
}

dal () {
    composer dump-autoload;
}

build () {
    version=`defaults read $(pwd)/workflow/info version`
    mkdir dist
    cd workflow
    zip -r "../dist/alfred-noteplan-fts-$version.alfredworkflow" . -x ./database.sqlite3 -x ./prefs.plist
}

# fake npm scripts hahaha
script=`shift 1`
$script "$@"