#!/bin/zsh

#===================================================================
# FIREFOX USER SUPPORT INSTALL
#===================================================================

cd "$(dirname $0)"

# ensure app is not running
osascript -e 'quit app "Spotify"'

# Folders
BACKUP="Private"
CONFIG="$HOME/Library/Application Support/Spotify"

# make support folders and move over
mkdir -p "$CONFIG"
cp -f "$BACKUP/prefs" "$CONFIG/"
