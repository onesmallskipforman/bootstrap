#!/bin/zsh

#===================================================================
# SLACK USER SUPPORT INSTALL
#===================================================================

# ensure app is not running
osascript -e 'quit app "Slack"'

# Folders
BACKUP=~/"Dropbox/Backup/Slack"
CONFIG="$HOME/Library/Application Support/Slack"

mkdir -p "$CONFIG"

rm -rf "$CONFIG/Cookies"
rm -rf "$CONFIG/storage"

ln -sf "$BACKUP/Cookies" "$CONFIG"
ln -sf "$BACKUP/storage" "$CONFIG"
