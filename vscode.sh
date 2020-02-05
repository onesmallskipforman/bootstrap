#!/bin/zsh

#===================================================================
# VS CODE USER SUPPORT INSTALL
#===================================================================

# ensure app is not running
osascript -e 'quit app "Visual Studio Code"'

# Folders
BACKUP="$BACKUP/VS Code"
CONFIG="$HOME/Library/Application Support/Code/User"

# make support folders and move over
mkdir -p "$CONFIG"

rm -rf "$CONFIG/keybindings.json"
rm -rf "$CONFIG/settings.json"
rm -rf "$CONFIG/snippets"

ln -sf "$BACKUP/keybindings.json" "$CONFIG"
ln -sf "$BACKUP/settings.json"    "$CONFIG"
ln -sf "$BACKUP/snippets"         "$CONFIG"

# install plugins in list htat are not already installed
comm -23 <(sort -f "$BACKUP/plugins.txt") <(code --list-extensions | sort -f) \
  | xargs -n 1 code --install-extension
