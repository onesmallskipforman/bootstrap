#!/bin/zsh

#===============================================================================
# Ranger Config
#===============================================================================

# Folders
BACKUP="$(dirname $0)"
CONFIG="$HOME/.config/ranger"

# configure from backup
mkdir -p "$CONFIG"
rm -rf "$CONFIG/rc.conf"
rm -rf "$CONFIG/rifle.conf"
rm -rf "$CONFIG/scope.sh"
ln -sf "$BACKUP/rc.conf"    "$CONFIG"
ln -sf "$BACKUP/rifle.conf" "$CONFIG"
ln -sf "$BACKUP/scope.sh"   "$CONFIG"
