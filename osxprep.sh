#!/bin/bash

#===============================================================================
# SKIPPER'S DOTFILES RUN SCRIPT
#===============================================================================

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ensure zsh is the default shell
echo "Changing User Shell to ZSH"
chsh -s /bin/zsh

# Update OS
echo "Updating OSX.  If this requires a restart, run the script again."
softwareupdate -i -a -R --verbose

# update command line tools
xcode-select -p &>/dev/null 2>&1 || (
  echo "Installing Command Line Tools..." &&
  xcode-select --install
)

#===============================================================================
# APP CONFIG SCRIPTS
#===============================================================================



#===============================================================================
# APP RESTORE SUPPORT FILES/FOLDERS
#===============================================================================

Sync/firefox.sh   --restore
Sync/minecraft.sh --restore
Sync/openemu.sh   --restore
Sync/slack.sh     --restore
Sync/spotify.sh   --restore
Sync/sublime.sh   --restore
Sync/vscode.sh    --restore
