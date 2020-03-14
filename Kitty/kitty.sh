#!/bin/zsh

#===============================================================================
# Kitty Config
#===============================================================================

# Folders
BACKUP="$(dirname $0)"
CONFIG="$HOME/.config/kitty"

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# configure from backup
mkdir -p "$CONFIG"
rm -rf "$CONFIG/kitty.conf"
cp "$BACKUP/kitty.conf"    "$CONFIG"

# themes setup
rm -rf "$CONFIG/kitty-themes"
git clone https://github.com/dexpota/kitty-themes "$CONFIG/kitty-themes"
ln -sf "$CONFIG/kitty-themes/themes/Monokai_Pro_(Filter_Machine).conf" "$CONFIG/theme.conf"

# for testing themes
# kitty @ set-colors -a ~/.config/kitty/kitty-themes/themes/<theme>.conf

# photo display alias
echo 'alias icat="kitty +kitten icat"' >> ~/.zshrc && source ~/.zshrc
