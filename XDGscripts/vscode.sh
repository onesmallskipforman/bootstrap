#!/bin/zsh

#===================================================================
# VSCODE XDG TO OSX LINKING
#===================================================================

# Folders
XDG="$XDG_CONFIG_HOME/Code"
OSX="$HOME/Library/Application Support/Code"

# prep directories
rm    -rf "$OSX"/{keybindings.json,settings.json,snippets}
mkdir -p  "$OSX/User"

# link
ln -sf "$XDG/User"/* "$OSX/User"

# install plugins in list that are not already installed
comm -23 <(sort "$XDG/plugins.txt") <(code --list-extensions | sort) \
  | xargs -n 1 code --install-extension
