#!/bin/zsh

#===============================================================================
# OPENEMU USER SUPPORT INSTALL
#===================================================================

# ensure app is not running
osascript -e 'quit app "OpenEmu"'

# Folders
BACKUP=~/"Dropbox/Backup/OpenEmu"
CONFIG="$HOME/Library/Application Support/OpenEmu"

mkdir -p "$CONFIG"

rm -rf "$CONFIG/Bindings"
rm -rf "$CONFIG/Cores"
rm -rf "$CONFIG/Mupen64Plus"
rm -rf "$CONFIG/Game Library"

ln -sf "$BACKUP/Bindings"     "$CONFIG"
ln -sf "$BACKUP/Cores"        "$CONFIG"
ln -sf "$BACKUP/Mupen64Plus"  "$CONFIG"
ln -sf "$BACKUP/Game Library" "$CONFIG"
