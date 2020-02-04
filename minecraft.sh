#!/bin/zsh

#===================================================================
# MINECRAFT USER SUPPORT INSTALL
#===================================================================

# ensure app is not running
osascript -e 'quit app "Minecraft"'

# Folders
BACKUP=~/"Dropbox/Backup/Minecraft"
CONFIG="$HOME/Library/Application Support/Minecraft"

# make support folders and move over
mkdir -p "$CONFIG"

rm -rf "$CONFIG/launcher_profiles.json"
rm -rf "$CONFIG/options.txt"
rm -rf "$CONFIG/resourcepacks"
rm -rf "$CONFIG/backups"
rm -rf "$CONFIG/saves"

ln -sf "$BACKUP/launcher_profiles.json" "$CONFIG"
ln -sf "$BACKUP/options.txt"            "$CONFIG"
ln -sf "$BACKUP/resourcepacks"          "$CONFIG"
ln -sf "$BACKUP/backups"                "$CONFIG"
ln -sf "$BACKUP/saves"                  "$CONFIG"
