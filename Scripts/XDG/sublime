#!/bin/sh

#===================================================================
# SUBLIME XDG TO OSX LINKING
#===================================================================

# Folders
XDG="$XDG_CONFIG_HOME/sublime-text-3"
OSX="$HOME/Library/Application Support/Sublime Text 3"

# prep directories
rm    -rf "$OSX"/{Cache/Python,Packages/User}
mkdir -p  "$OSX"/{Cache/Python,Packages/User,Installed\ Packages}

# link
ln -sf "$XDG/Cache/Python/Completion Rules.tmPreferences" "$OSX/Cache/Python"
ln -sf "$XDG/Packages/User"/*                             "$OSX/Packages/User"

# Install Package Control
wget "https://packagecontrol.io/Package%20Control.sublime-package"
mv "Package Control.sublime-package" "$OSX/Installed Packages"
