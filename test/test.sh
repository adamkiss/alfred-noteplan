#!/usr/bin/env zsh

# rebuild
# ./r.sh build:dart

# set test env variables
user_np_root='/Users/adam/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp'

# CWD is the root
echo "RETURN HELP OPTIONS (outputs: 3)"
user_np_root='/Users/adam/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp' \
zsh test/fake-run.sh ! | jq '.items | length'
echo

echo "SHOW DEBUG INFORMATION"
user_np_root='/Users/adam/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp' \
zsh test/fake-run.sh !! | jq -r '.items | map(.subtitle + ": " +.title)'
echo

echo "FORCE REFRESH"
user_np_root='/Users/adam/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp' \
zsh test/fake-run.sh !rf
echo

echo "REFRESH CHANGED (nothing)"
user_np_root='/Users/adam/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp' \
zsh test/fake-run.sh !r
echo

echo "CREATE NOTE - folders"
user_np_root='/Users/adam/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp' \
./workflow/noteplan_fts-arm64 create 'Ahoy there captain!'
echo

echo "SEARCH - adam kiss (outputs: 19 [18 + create])"
user_np_root='/Users/adam/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp' \
./workflow/noteplan_fts-arm64 search 'adam kiss' | jq '.items | map(.title + " - " + .subtitle)'
echo