#!/bin/zsh

#===================================================================
# SLACK USER SUPPORT INSTALL
#===================================================================

cd $(dirname $0)

# ensure app is not running
osascript -e 'quit app "Slack"'

# Folders
BACKUP="Private"
CONFIG="$HOME/Library/Application Support/Slack"

mkdir -p "$CONFIG"
cp -f  "$BACKUP/Cookies" "$CONFIG/"
cp -rf "$BACKUP/storage" "$CONFIG/"
