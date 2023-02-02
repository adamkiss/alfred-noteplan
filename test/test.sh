#!/usr/bin/env zsh
# shellcheck shell=bash

# rebuild
./r.sh build:dart

# set test env variables
user_np_root='/Users/adam/Library/Containers/co.noteplan.NotePlan-setapp/Data/Library/Application Support/co.noteplan.NotePlan-setapp'
user_new_note_template="---\ntitle: TITLE\n---\n\n"

# CWD is the root
echo "RETURN HELP OPTIONS (outputs: 3)"
user_np_root=$user_np_root user_new_note_template=$user_new_note_template \
zsh test/fake-run.sh ! | jq '.items | length'
echo

echo "SHOW DEBUG INFORMATION"
user_np_root=$user_np_root user_new_note_template=$user_new_note_template \
zsh test/fake-run.sh !! | jq -r '.items | map(.subtitle + ": " +.title)'
echo

echo "FORCE REFRESH"
user_np_root=$user_np_root user_new_note_template=$user_new_note_template \
zsh test/fake-run.sh !rf | jq -r '.items[0].title'
echo

echo "REFRESH CHANGED (nothing)"
user_np_root=$user_np_root user_new_note_template=$user_new_note_template \
zsh test/fake-run.sh !r | jq -r '.items[0].title'
echo

echo "CREATE NOTE - folders"
user_np_root=$user_np_root user_new_note_template=$user_new_note_template \
./workflow/noteplan-arm64 create 'Ahoy there captain!' | jq -r '.items | map(.title + ": "+ .arg)'
echo

echo "SEARCH - adam kiss (outputs: 19 [18 + create])"
user_np_root=$user_np_root user_new_note_template=$user_new_note_template \
./workflow/noteplan-arm64 search 'adam kiss' | jq '.items | map(.title + " - " + .subtitle)'
echo

echo "Bookmark search - kirby"
user_np_root=$user_np_root user_new_note_template=$user_new_note_template \
./workflow/noteplan-arm64 hyperlinks 'kirby' | jq '.items | map(.title + " - " + .subtitle)'
echo

echo "All search - kirby"
user_np_root=$user_np_root user_new_note_template=$user_new_note_template \
./workflow/noteplan-arm64 all 'kirby' | jq '.items | map(.title + " - " + .subtitle)'
echo