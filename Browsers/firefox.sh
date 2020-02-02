#!/bin/zsh

#===================================================================
# FIREFOX USER SUPPORT INSTALL
#===================================================================

cd "$(dirname $0)"

# ensure app is not running
osascript -e 'quit app "Firefox"'

# Folders
BACKUP="Private"
CONFIG="$HOME/Library/Application Support/Firefox"
CMD="/Applications/Firefox.app/Contents/MacOS/firefox"

# make support folders and move over
mkdir -p "$CONFIG"
rm -rf "$CONFIG"/*
"$CMD" -CreateProfile default-release
cp -f  "$BACKUP"/*.json            "$CONFIG/Profiles"/*.default-release/
cp -f  "$BACKUP/prefs.js"          "$CONFIG/Profiles"/*.default-release/
cp -f  "$BACKUP/compatibility.ini" "$CONFIG/Profiles"/*.default-release/
cp -rf "$BACKUP/extensions"        "$CONFIG/Profiles"/*.default-release/

# open and close the browser headlessly, ensuring first user open isnt buggy
"$CMD" -headless &>/dev/null & #-setDefaultBrowser

# wait for multiple running processes
until [ $(pgrep -f Firefox | wc -l) -gt 2 ]
do
  sleep 0.5
done

# close and wait for close
osascript -e 'quit app "Firefox"'
open -g -W /Applications/Firefox.app
