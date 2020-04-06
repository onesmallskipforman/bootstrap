#!/bin/sh

#===================================================================
# SPOTIFY XDG TO OSX LINKING
#===================================================================

# Folders
XDG="$XDG_CONFIG_HOME/spotify"
OSX="$HOME/Library/Application Support/Spotify"

# prep directories
rm    -rf "$OSX/prefs"
mkdir -p  "$OSX"

# link
ln -sf "$XDG"/* "$OSX"
