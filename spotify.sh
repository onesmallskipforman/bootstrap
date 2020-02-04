#!/bin/zsh

#===================================================================
# SPOTIFY USER SUPPORT INSTALL
#===================================================================

# ensure app is not running
osascript -e 'quit app "Spotify"'

# Folders
BACKUP=~/"Dropbox/Backup/Spotify"
CONFIG="$HOME/Library/Application Support/Spotify"

# make support folders and move over
mkdir -p "$CONFIG"
rm -rf "$CONFIG/prefs"
ln -sf "$BACKUP/prefs" "$CONFIG"
