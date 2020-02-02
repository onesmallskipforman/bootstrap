#!/bin/zsh

#===================================================================
# MINECRAFT USER SUPPORT INSTALL
#===================================================================

cd $(dirname $0)

# ensure app is not running
osascript -e 'quit app "Minecraft"'

# Folders
BACKUP="Private"
CONFIG="$HOME/Library/Application Support/Minecraft"

# make support folders and move over
mkdir -p "$CONFIG"
cp -f  "$BACKUP/launcher_profiles.json" "$CONFIG/"
cp -f  "$BACKUP/options.txt"            "$CONFIG/"
cp -rf "$BACKUP/resourcepacks"          "$CONFIG/"
cp -rf "$BACKUP/backups"                "$CONFIG/"
cp -rf "$BACKUP/saves"                  "$CONFIG/"
