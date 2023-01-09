#!/usr/bin/env zsh

# rebuild
# ./r.sh build:dart

# CWD is the root
echo "RETURN HELP OPTIONS (outputs: 3)"
zsh test/fake-run.sh ! | jq '.items | length'
echo

echo "SHOW DEBUG INFORMATION  (outputs: 4)"
zsh test/fake-run.sh !! | jq '.items | length'
echo

echo "FORCE REFRESH"
zsh test/fake-run.sh !rf
echo

echo "REFRESH CHANGED (nothing)"
zsh test/fake-run.sh !r
echo

echo "CREATE NOTE - folders"
./workflow/noteplan_fts-arm64 create 'Ahoy there captain!'
echo

echo "SEARCH - adam kiss (outputs: 19 [18 + create])"
./workflow/noteplan_fts-arm64 search 'adam kiss' | jq '.items | map(.title + " - " + .subtitle)'
echo