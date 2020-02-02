#!/bin/zsh

#===================================================================
# OPENEMU USER SUPPORT INSTALL
#===================================================================

cd "$(dirname $0)"

# ensure app is not running
osascript -e 'quit app "OpenEmu"'

# Folders
BACKUP="Private"
CONFIG="$HOME/Library/Application Support/OpenEmu"

mkdir -p "$CONFIG"
cp -rf "$BACKUP/Bindings"     "$CONFIG/"
cp -rf "$BACKUP/Cores"        "$CONFIG/"
cp -rf "$BACKUP/Mupen64Plus"  "$CONFIG/"
cp -rf "$BACKUP/Game Library" "$CONFIG/"
