#!/bin/zsh

#===================================================================
# SUBLIME USER SUPPORT INSTALL
#===================================================================

# ensure app is not running
osascript -e 'quit app "Sublime Text"'

# Folders
BACKUP="$BACKUP/Sublime"
CONFIG="$HOME/Library/Application Support/Sublime Text 3/Packages/User"
PYCACHE="$HOME/Library/Application Support/Sublime Text 3/Cache/Python"
PCTRL="$HOME/Library/Application Support/Sublime Text 3/Installed Packages"

mkdir -p "$PYCACHE"
mkdir -p "$CONFIG"
mkdir -p "$PCTRL"

rm -rf "$PYCACHE/Completion Rules.tmPreferences"
rm -rf "$CONFIG/Monokai-Contrast.tmTheme"
rm -rf "$CONFIG/Snippets"
rm -rf "$CONFIG/Builds"
rm -rf "$CONFIG/Settings"

ln -sf "$BACKUP/Completion Rules.tmPreferences" "$PYCACHE"
ln -sf "$BACKUP/Monokai-Contrast.tmTheme"       "$CONFIG"
ln -sf "$BACKUP/Snippets"                       "$CONFIG"
ln -sf "$BACKUP/Builds"                         "$CONFIG"
ln -sf "$BACKUP/Settings"/*                     "$CONFIG"
# cp -f  "$BACKUP/CleanPreferences.sublime-settings" "$CONFIG/Preferences.sublime-settings"

# Install Package Control
wget "https://packagecontrol.io/Package%20Control.sublime-package"
mv "Package Control.sublime-package" "$PCTRL"
