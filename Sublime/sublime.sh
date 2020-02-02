#!/bin/zsh

#===================================================================
# SUBLIME USER SUPPORT INSTALL
#===================================================================

cd "$(dirname $0)"

# ensure app is not running
osascript -e 'quit app "Sublime Text"'

# Folders
BACKUP="$PWD"
CONFIG="$HOME/Library/Application Support/Sublime Text 3/Packages/User"
PYCACHE="$HOME/Library/Application Support/Sublime Text 3/Cache/Python"
PCTRL="$HOME/Library/Application Support/Sublime Text 3/Installed Packages"

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
