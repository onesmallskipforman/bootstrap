#!/bin/zsh

#===============================================================================
# OSX/COMMANDLINETOOLS UPDATE
#===============================================================================

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ensure zsh is the default shell
echo "Changing User Shell to ZSH"
sudo chsh -s /bin/zsh

# Update OS
echo "Updating OSX"
softwareupdate -i -a --verbose # use sudo -s if you want -R option

# install command line tools
xcode-select -p &>/dev/null 2>&1 || (
  echo "Installing Command Line Tools..." &&
  xcode-select --install
)
