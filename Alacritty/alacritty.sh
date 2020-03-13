#!/bin/zsh

#===============================================================================
# Alacritty Config
#===============================================================================

# Folders
BACKUP="$(dirname $0)"
CONFIG="$HOME/.config/alacritty"

# configure from backup
mkdir -p "$CONFIG"
rm -rf "$CONFIG/alacritty.yml"
ln -sf "$BACKUP/alacritty.yml" "$CONFIG"
