#!/bin/bash

# ensure app is not running
# osascript -e 'quit app "Firefox"'
# pkill -a firefox

# Backup Folder
BACKUP=${2:-$PWD} # BACKUP=${2:-$PWD/FF}
BACKUP=${BACKUP%/}

CONFIG="$HOME/Library/Application Support/Firefox"
CMD="/Applications/Firefox.app/Contents/MacOS/firefox"

# TODO: encrypt/decrypt backups

if [[ $1 == "--backup" ]]; then
  mkdir -p "$BACKUP"
  cp -f  "$CONFIG/Profiles"/*.default-release/*.json            "$BACKUP/"
  cp -f  "$CONFIG/Profiles"/*.default-release/prefs.js          "$BACKUP/"
  cp -f  "$CONFIG/Profiles"/*.default-release/compatibility.ini "$BACKUP/"
  cp -rf "$CONFIG/Profiles"/*.default-release/extensions        "$BACKUP/"
elif [[ $1 == "--restore" ]]; then
  mkdir -p "$CONFIG"
  rm -rf "$CONFIG"/*
  "$CMD" -CreateProfile default-release
  cp -f  "$BACKUP"/*.json            "$CONFIG/Profiles"/*.default-release/
  cp -f  "$BACKUP/prefs.js"          "$CONFIG/Profiles"/*.default-release/
  cp -f  "$BACKUP/compatibility.ini" "$CONFIG/Profiles"/*.default-release/
  cp -rf "$BACKUP/extensions"        "$CONFIG/Profiles"/*.default-release/

  # during first open after sync, the extensions are missing
  # these are optional lines to open and close the browser headlessly

  # open and wait for multiple running processes
  # multiple running processes  seems to be sufficient for a proper open
  "$CMD" -headless &>/dev/null & #-setDefaultBrowser
  until [ $(pgrep -f Firefox | wc -l) -gt 2 ]
  do
    sleep 0.5
  done

  # close and wait
  osascript -e 'quit app "Firefox"'
  open -g -W /Applications/Firefox.app


else
  echo "Invalid Config Option"
fi
