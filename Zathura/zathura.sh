#!/bin/zsh

#===============================================================================
# Zathura Config
#===============================================================================

# Folders
BACKUP="$(dirname $0)"
CONFIG="$HOME/.config/zathura"

# setup
mkdir -p $(brew --prefix zathura)/lib/zathura
ln -s $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib

# configure from backup
mkdir -p "$CONFIG"
rm -rf "$CONFIG/zathurarc"
ln -sf "$BACKUP/zathurarc" "$CONFIG"
