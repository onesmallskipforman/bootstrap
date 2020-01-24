#!/bin/sh

# ensure app is not running
pkill -a Spotify
# osascript -e 'quit app "Spotify"'

# Backup Folder
BACKUP=${2:-$PWD}
BACKUP=${BACKUP%/}

CONFIG="$HOME/Library/Application Support/Spotify"

# TODO: encrypt/decrypt backups

if [[ $1 == "--backup" ]]; then
  mkdir -p "$BACKUP"
  cp -f "$CONFIG/prefs" "$BACKUP/"
elif [[ $1 == "--restore" ]]; then
  mkdir -p "$CONFIG"
  cp -f "$BACKUP/prefs" "$CONFIG/"
else
  echo "Invalid Config Option"
fi
