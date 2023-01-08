#!/usr/bin/env zsh
# fake npm scripts hahaha

about () { #: show help & commands
    NAME='alfred-noteplan-fts'
    echo "$NAME script runner"
    echo "Commands:"
    cat r.sh | sed -nr 's/^(.*) \(\).* #: (.*)$/  \1\t\2/p' | expand -20
}

build:dart () { #: Build the version for the current architecture
    dart compile exe bin/refresh.dart -o "workflow/refresh-$(uname -m)"
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

if [[ $# > 0 ]]; then
    script=`shift 1`
    $script "$@"
else
    about
fi