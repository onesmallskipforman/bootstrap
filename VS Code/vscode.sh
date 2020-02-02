#!/bin/zsh

#===================================================================
# VS CODE USER SUPPORT INSTALL
#===================================================================

cd $(dirname $0)

# ensure app is not running
osascript -e 'quit app "Visual Studio Code"'

# Folders
BACKUP="VS Code"
CONFIG="$HOME/Library/Application Support/Code/User"

# make support folders and move over
mkdir -p "$CONFIG"
cp -f  "$BACKUP/keybindings.json" "$CONFIG/"
cp -f  "$BACKUP/settings.json"    "$CONFIG/"
cp -rf "$BACKUP/snippets"         "$CONFIG/"

# install plugins in list htat are not already installed
comm -23 <(sort -f "$BACKUP/plugins.txt") <(code --list-extensions | sort -f) \
  | xargs -n 1 code --install-extension

# setup so latexindent will work
sudo cpan install Log::Log4perl
sudo cpan install Log::Dispatch::File
sudo cpan install YAML::Tiny
sudo cpan install File::HomeDir
