#!/usr/bin/env zsh
# fake npm scripts hahaha

about () { #: show help & commands
    NAME='alfred-noteplan-fts'
    echo "$NAME script runner"
    echo "Commands:"
    cat r.sh | sed -nr 's/^(.*) \(\).* #: (.*)$/  \1\t\2/p' | expand -20
}

build:licenses () { #: Get all the licenses from pubspec.lock
    dart-pubspec-licenses-lite -i pubspec.lock | grep -v null > LICENSES
}

build:dart () { #: Build the version for the current architecture
    dart compile exe bin/noteplan_fts.dart -o "workflow/noteplan_fts-$(uname -m)"
}

build:icons () { #: Build the icns file from iconsets
    echo "not implemented yet."
}

build:workflow () { #: Zip the workflow folder into release/dist folder
    echo "not implemented yet."
}

build () { #: Run the whole build
    build:icons
    build:dart
    build:workflow
}

version () { #: get the workflow version
    defaults read "$(pwd)/workflow/info" version
}

dev:link () { #: link the WIP version to Alfred
    ln -s \
        /Users/adam/Code/alfred-noteplan-fts-dart/workflow \
        /Users/adam/Code/dotfiles/config/alfred5/Alfred.alfredpreferences/workflows/alfred-noteplan-fts-dart;
}

dev:unlink () { #: remove the WIP version link from Alfred
    rm /Users/adam/Code/dotfiles/config/alfred5/Alfred.alfredpreferences/workflows/alfred-noteplan-fts-dart;
}

if [[ $# > 0 ]]; then
    script=`shift 1`
    $script "$@"
else
    about
fi