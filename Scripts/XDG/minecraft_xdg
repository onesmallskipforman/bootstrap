#!/bin/sh

#===================================================================
# MINECRAFT XDG TO OSX LINKING
#===================================================================

# Folders
XDG="$XDG_CONFIG_HOME/minecraft"
OSX="$HOME/Library/Application Support/Minecraft"

# prep directories
rm    -rf "$OSX"/{launcher_profiles.json,options.txt,resourcepacks,backups}
mkdir -p  "$OSX"

# link
ln -sf "$XDG"/* "$OSX"
