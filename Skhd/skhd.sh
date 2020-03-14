#!/bin/zsh

#===============================================================================
# Skhd Config
#===============================================================================

# Folders
BACKUP="$(dirname $0)"
CONFIG="$HOME"

# configure from backup
mkdir -p "$CONFIG"
rm -rf "$CONFIG/.skhdrc"
cp "$BACKUP/.skhdrc" "$CONFIG"

# restart service
brew services restart skhd

# copy (symlink?) launch.sh to /usr/local/bin
cp launch.sh /usr/local/bin
