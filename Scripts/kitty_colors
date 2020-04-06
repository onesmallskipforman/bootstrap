#!/bin/sh

#===============================================================================
# Kitty Config
#===============================================================================

# build themes directory
CONFIG="$HOME/.config/kitty"
rm -rf "$CONFIG/themes"
mkdir -p "$CONFIG/themes"

git clone https://github.com/dexpota/kitty-themes "$CONFIG/kitty-themes"
git clone https://github.com/kdrag0n/base16-kitty "$CONFIG/base16-kitty"
cp "$CONFIG/kitty-themes/themes"/* "$CONFIG/base16-kitty/colors"/* "$CONFIG/themes/"

rm -rf "$CONFIG/kitty-themes" "$CONFIG/base16-kitty"

# set theme
ln -sf "$CONFIG/themes/Monokai_Pro_(Filter_Octagon).conf" "$CONFIG/theme.conf"

# for testing themes
# kitty @ set-colors -a "$CONFIG/themes/<theme>.conf"
