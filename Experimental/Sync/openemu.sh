#!/bin/bash

# ensure app is not running
# osascript -e 'quit app "OpenEmu"'
# pkill -a OpenEmu

# Backup Folder
BACKUP=${2:-$PWD}
BACKUP=${BACKUP%/}

CONFIG="$HOME/Library/Application Support/OpenEmu"

if [[ $1 == "--backup" ]]; then
  mkdir -p "$BACKUP"
  cp -rf "$CONFIG/Bindings"     "$BACKUP/"
  cp -rf "$CONFIG/Cores"        "$BACKUP/"

  # Library.storedata files needed to recognize where roms are stored
  cp -rf "$CONFIG/Game Library" "$BACKUP/"
  cp -rf "$CONFIG/Mupen64Plus"  "$BACKUP/"
  rm -f  "$BACKUP/Mupen64Plus/mupen64plus.cfg"
elif [[ $1 == "--restore" ]]; then
  mkdir -p "$CONFIG"
  cp -rf "$BACKUP/Bindings"     "$CONFIG/"
  cp -rf "$BACKUP/Cores"        "$CONFIG/"
  cp -rf "$BACKUP/Mupen64Plus"  "$CONFIG/"
  cp -rf "$BACKUP/Game Library" "$CONFIG/"
else
  echo "Invalid Config Option"
fi
