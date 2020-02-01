#!/bin/bash

# ensure app is not running
osascript -e 'quit app "Sublime Text"'
# pkill -a merge
# pkill -a Sublime

# Backup Folder
BACKUP=${2:-$PWD}
BACKUP=${BACKUP%/}

CONFIG="$HOME/Library/Application Support/Sublime Text 3/Packages/User"
PYCACHE="$HOME/Library/Application Support/Sublime Text 3/Cache/Python"
PCTRL="$HOME/Library/Application Support/Sublime Text 3/Installed Packages"

# TODO: encrypt/decrypt backups

if [[ $1 == "--backup" ]]; then
  mkdir -p "$BACKUP"
  mkdir -p "$BACKUP/Settings"
  cp -f  "$CONFIG"/*.{sublime-settings,sublime-keymap} "$BACKUP/Settings/"
  cp -rf "$CONFIG/Snippets"                            "$BACKUP/"
  cp -rf "$CONFIG/Builds"                              "$BACKUP/"
elif [[ $1 == "--restore" ]]; then
  mkdir -p "$PYCACHE"
  mkdir -p "$CONFIG"
  mkdir -p "$PCTRL"
  cp -f  "$BACKUP/Completion Rules.tmPreferences" "$PYCACHE/"
  cp -f  "$BACKUP/Monokai-Contrast.tmTheme"       "$CONFIG/"
  cp -rf "$BACKUP/Snippets"                       "$CONFIG/"
  cp -rf "$BACKUP/Builds"                         "$CONFIG/"
  cp -rf "$BACKUP/Settings/"                      "$CONFIG/"
  # cp -f  "$BACKUP/CleanPreferences.sublime-settings" "$CONFIG/Preferences.sublime-settings"

  # Install Package Control
  wget "https://packagecontrol.io/Package%20Control.sublime-package"
  mv "Package Control.sublime-package" "$PCTRL"

  # ensures backup folder stays clean of extra downloads
  rm -f *.sublime-package
else
  echo "Invalid Config Option"
fi
