#!/bin/zsh

#===============================================================================
# Yabai Config
#===============================================================================

# Folders
BACKUP="$(dirname $0)"
CONFIG="$HOME"

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# configure from backup
mkdir -p "$CONFIG"
rm -rf "$CONFIG/.yabairc"
ln -sf "$BACKUP/.yabairc" "$CONFIG"

# restart yabai
brew services restart yabai

# install the scripting addition
sudo yabai --uninstall-sa
sudo yabai --install-sa

# load the scripting addition
killall Dock
