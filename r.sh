#!/usr/bin/env zsh
# shellcheck shell=bash

build:licenses () { #: Get all the licenses from pubspec.lock
    cat LICENSE > workflow/LICENSES
    echo "\n\n----------\n" >> workflow/LICENSES
    dart-pubspec-licenses-lite -i pubspec.lock | grep -v null >> workflow/LICENSES
}

build:dart () { #: Build the version for the current architecture
    dart compile exe bin/noteplan_fts.dart -o "workflow/noteplan_fts-$(uname -m)"
}

build:dart-local () { #: Build the version in the version controlled space
    dart compile exe bin/noteplan_fts.dart -o "bin-cache/noteplan_fts-$(uname -m)"
}

build:icons () { #: Build the icns file from iconsets
    mkdir workflow/icons
    rm workflow/icons/*.icns
    mkdir icons/iconsets
    rm -fr icons/iconsets/**
    # shellcheck disable=all
    for I (create folder note daily weekly monthly quarterly yearly); do
        mkdir icons/iconsets/icon-$I.iconset
    
        cp icons/ps-export/icon-$I-16.png icons/iconsets/icon-$I.iconset/icon_16x16.png
    
        cp icons/ps-export/icon-$I-32.png icons/iconsets/icon-$I.iconset/icon_16x16@2x.png
        cp icons/ps-export/icon-$I-32.png icons/iconsets/icon-$I.iconset/icon_32x32.png

        cp icons/ps-export/icon-$I-64.png icons/iconsets/icon-$I.iconset/icon_32x32@2x.png
        cp icons/ps-export/icon-$I-128.png icons/iconsets/icon-$I.iconset/icon_128x128.png
        
        cp icons/ps-export/icon-$I-256.png icons/iconsets/icon-$I.iconset/icon_128x128@2x.png
        cp icons/ps-export/icon-$I-256.png icons/iconsets/icon-$I.iconset/icon_256x256.png

        convert icons/ps-export/icon-$I-1024.png -resize 50% icons/iconsets/icon-$I.iconset/icon_256x256@2x.png
        convert icons/ps-export/icon-$I-1024.png -resize 50% icons/iconsets/icon-$I.iconset/icon_512x512.png
        cp icons/ps-export/icon-$I-1024.png icons/iconsets/icon-$I.iconset/icon_512x512@2x.png

        iconutil --convert icns icons/iconsets/icon-$I.iconset
    done

    mv icons/iconsets/*.icns workflow/icons
}

build:script () { #: Copy the script part from the workflow.sh into info.plist
    cp workflow/info.plist workflow/info.plist.bak
    SCRIPT=`cat test/workflow-search.sh | sed -E 's/(["'\''])/\\\\\1/g'`
    /usr/libexec/PlistBuddy -c "Set :objects:0:config:script $SCRIPT" workflow/info.plist
    SCRIPT=`cat test/workflow-date.sh | sed -E 's/(["'\''])/\\\\\1/g'`
    /usr/libexec/PlistBuddy -c "Set :objects:3:config:script $SCRIPT" workflow/info.plist
}

build:workflow () { #: Zip the workflow folder into release/dist folder
    cd workflow
    VERSION=`/usr/libexec/PlistBuddy -c "Print :version" info.plist`
    BUILD=`git rev-parse --short HEAD`
    zip -r "../alfred-noteplan-fts-$VERSION-$BUILD.alfredworkflow" icons/ info.plist icon.png LICENSES noteplan_fts-arm64 noteplan_fts-x86_64
}

prebuild () { #: Run the whole build - the local part
    # build:icons
    build:dart-local
    build:script
}

build () { #: Run the build and packaging - on the runner
    build:dart
    cp bin-cache/noteplan_fts-arm64 workflow/ # GA doesn't run on arm64 arch
    build:licenses
    build:workflow
}

version () { #: get the workflow version
    defaults read "$(pwd)/workflow/info" version
}

dev:link () { #: link the WIP version to Alfred
    ln -s \
        /Users/adam/Code/alfred-noteplan-fts/workflow \
        /Users/adam/Code/dotfiles/config/alfred5/Alfred.alfredpreferences/workflows/alfred-noteplan-fts;
}

dev:unlink () { #: remove the WIP version link from Alfred
    rm /Users/adam/Code/dotfiles/config/alfred5/Alfred.alfredpreferences/workflows/alfred-noteplan-fts;
}

dev:dumplist () { #: dump the info.plist into plist.txt
    /usr/libexec/PlistBuddy -c 'print: ":name"' workflow/info.plist > plist.txt
}

dev:plisttest () { #: dumps the objects "prebuild" tries update with scripts in test/workflow-*.sh
    # should return: 
    # "Full-text search for Noteplan" in line 1
    # "Opens exact Calendar note" in line 2
    /usr/libexec/PlistBuddy -c "Print :objects:0:config:subtext" workflow/info.plist
    /usr/libexec/PlistBuddy -c "Print :objects:3:config:subtext" workflow/info.plist
}

test () { #: run tests
    zsh test/test.sh
}

#
# BOILERPLATE
#
r='./r.sh'
NAME='alfred-noteplan-fts'

about () { #: show help & commands
    echo "$NAME script runner"
    echo "Commands:"
    sed -nr 's/^(.*) \(\).* #: (.*)$/  \1	\2/p' $r | expand -20
}

if [[ $# -gt 0 ]]; then
    command="$1"
    shift 1
    if type "$command" 2>/dev/null | grep -q 'function'; then
        $command "$@"
    else
        about
        echo "No command '$command'."
    fi;
else
    about
fi