#!/usr/bin/env sh

link () {
    ln -s \
        /Users/adam/Code/alfred-noteplan-fts2/workflow \
        /Users/adam/Code/dotfiles/config/alfred5/Alfred.alfredpreferences/workflows/alfred-noteplan-fts2;
}

unlink () {
    rm /Users/adam/Code/dotfiles/config/alfred5/Alfred.alfredpreferences/workflows/alfred-noteplan-fts2;
}

dal () {
    composer dump-autoload;
}

build () {
    version=`defaults read $(pwd)/workflow/info version`
    mkdir dist
    cd workflow
    zip -r "../dist/alfred-noteplan-fts-$version.alfredworkflow" . -x ./database.sqlite3
}

# fake npm scripts hahaha
script=`shift 1`
$script "$@"