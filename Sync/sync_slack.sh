#!/bin/bash

# ensure app is not running
# osascript -e 'quit app "Slack"'
# pkill -a Slack

# Backup Folder
BACKUP=${2:-$PWD}
BACKUP=${BACKUP%/}

CONFIG="$HOME/Library/Application Support/Slack"

# TODO: encrypt/decrypt backups

if [[ $1 == "--backup" ]]; then
  mkdir -p "$BACKUP"
  cp -f  "$CONFIG/Cookies" "$BACKUP/"
  cp -rf "$CONFIG/storage" "$BACKUP/"
elif [[ $1 == "--restore" ]]; then
  mkdir -p "$CONFIG"
  cp -f  "$BACKUP/Cookies" "$CONFIG/"
  cp -rf "$BACKUP/storage" "$CONFIG/"
else
  echo "Invalid Config Option"
fi
