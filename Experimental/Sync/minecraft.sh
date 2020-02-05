#!/bin/bash

# ensure app is not running
# osascript -e 'quit app "Minecraft"'
# pkill -a java
# pkill -a minecraft

# Backup Folder
BACKUP=${2:-$PWD}
BACKUP=${BACKUP%/}

CONFIG="$HOME/Library/Application Support/Minecraft"

if [[ $1 == "--backup" ]]; then
  mkdir -p "$BACKUP"
  cp -f  "$CONFIG/launcher_profiles.json" "$BACKUP/"
  cp -f  "$CONFIG/options.txt"            "$BACKUP/"
  cp -rf "$CONFIG/resourcepacks"          "$BACKUP/"
  cp -rf "$CONFIG/backups"                "$BACKUP/"
  cp -rf "$CONFIG/saves"                  "$BACKUP/"
elif [[ $1 == "--restore" ]]; then
  mkdir -p "$CONFIG"
  cp -f  "$BACKUP/launcher_profiles.json" "$CONFIG/"
  cp -f  "$BACKUP/options.txt"            "$CONFIG/"
  cp -rf "$BACKUP/resourcepacks"          "$CONFIG/"
  cp -rf "$BACKUP/backups"                "$CONFIG/"
  cp -rf "$BACKUP/saves"                  "$CONFIG/"
else
  echo "Invalid Config Option"
fi
