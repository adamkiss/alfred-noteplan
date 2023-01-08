#!/usr/bin/env zsh

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