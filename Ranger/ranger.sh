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
cp "$BACKUP/rc.conf"    "$CONFIG"
cp "$BACKUP/rifle.conf" "$CONFIG"
cp "$BACKUP/scope.sh"   "$CONFIG"
