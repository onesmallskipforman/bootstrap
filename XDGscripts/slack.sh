#!/bin/sh

#===================================================================
# SLACK XDG TO OSX LINKING
#===================================================================

# Folders
XDG="$XDG_CONFIG_HOME/slack"
OSX="$HOME/Library/Application Support/Slack"

# prep directories
rm    -rf "$OSX"/{Cookies,storage}
mkdir -p  "$OSX"

# link
ln -sf "$XDG"/* "$OSX"
