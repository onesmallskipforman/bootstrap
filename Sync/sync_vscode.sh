#!/bin/sh

# ensure app is not running
# TODO: figure out correct names
# osascript -e 'quit app "Visual Studio"'
pkill -a Vscode

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
  cat plugins.txt | xargs -n 1 code --install-extension
else
  echo "Invalid Config Option"
fi
