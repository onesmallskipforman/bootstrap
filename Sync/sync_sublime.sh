#!/bin/sh

# ensure app is not running
# osascript -e 'quit app "Sublime Text"'
pkill -a Sublime
# pkill -a merge

# Backup Folder
BACKUP=${2:-$PWD}
BACKUP=${BACKUP%/}

CONFIG="$HOME/Library/Application Support/Sublime Text 3"

# TODO: encrypt/decrypt backups

if [[ $1 == "--backup" ]]; then
  mkdir -p "$BACKUP"
  cp -f "$CONFIG/Packages/User"/*.{sublime-settings,sublime-keymap,sublime-build}   "$BACKUP/"
  cp -f "$CONFIG/Packages/Python"/*.{sublime-settings,sublime-keymap,sublime-build} "$BACKUP/"
elif [[ $1 == "--restore" ]]; then
  mkdir -p "$CONFIG/Packages"
  mkdir -p "$CONFIG/Installed Packages"
  cp -rf "$BACKUP/User"   "$CONFIG/Packages/"
  cp -rf "$BACKUP/Python" "$CONFIG/Packages/"

  # Install Package Control
  wget "https://packagecontrol.io/Package%20Control.sublime-package"
  mv "Package Control.sublime-package" "$CONFIG/Installed Packages/"
else
  echo "Invalid Config Option"
fi
