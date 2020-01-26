#!/bin/bash

# ensure app is not running
# osascript -e 'quit app "Visual Studio Code"'
# pkill -a Code

# Backup Folder
BACKUP=${2:-$PWD}
BACKUP=${BACKUP%/}

CONFIG="$HOME/Library/Application Support/Code/User"

# TODO: encrypt/decrypt backups

if [[ $1 == "--backup" ]]; then
  mkdir -p "$BACKUP"
  cp -f  "$CONFIG/keybindings.json"  "$BACKUP/"
  cp -f  "$CONFIG/settings.json"     "$BACKUP/"
  cp -rf "$CONFIG/snippets"          "$BACKUP/"
  code --list-extensions >           "$BACKUP/plugins.txt"
elif [[ $1 == "--restore" ]]; then
  mkdir -p "$CONFIG"
  cp -f  "$CONFIG/keybindings.json" "$CONFIG/"
  cp -f  "$CONFIG/settings.json"    "$CONFIG/"
  cp -rf "$CONFIG/snippets"         "$CONFIG/"

  # install plugins in list htat are not already installed
  comm -23 <(sort -f "$BACKUP/plugins.txt") <(code --list-extensions | sort -f) \
   | xargs -n 1 code --install-extension
else
  echo "Invalid Config Option"
fi
