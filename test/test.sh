#!/usr/bin/env zsh

# rebuild
./r.sh build:dart

# CWD is the root
echo "RETURN HELP OPTIONS"
zsh test/fake-run.sh !
echo
echo

echo "SHOW DEBUG INFORMATION"
zsh test/fake-run.sh !!
echo
echo

echo "FORCE REFRESH"
zsh test/fake-run.sh !rf
echo
echo

echo "REFRESH CHANGED (nothing)"
zsh test/fake-run.sh !r
echo
echo

echo "CREATE NOTE - folders"
./workflow/noteplan_fts-arm64 create 'Ahoy there captain!'
echo
echo