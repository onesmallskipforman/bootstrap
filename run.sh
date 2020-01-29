#!/bin/bash

#===================================================================
# SKIPPER'S DOTFILES RUN SCRIPT
#===================================================================

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished (thank you to donnemartin/dev-setup/osxprep.sh)
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# install all approprate updates on mac, restarts script after to finish installation
# softwareupdate -i -a -R

# get command line tools (homebrew does this auto i think)
xcode-select -p &>/dev/null 2>&1 || (
echo "Installing Command Line Tools..." &&
xcode-select --install)

# check for homebrew and install if missing
which brew &>/dev/null 2>&1 || (
echo "Installing homebrew..." &&
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)")

# (for homebrew) add sbin to path if not already there and export to bash profile
[[ ":$PATH:" == *":/usr/local/sbin:"* ]] ||
echo 'export PATH="/usr/local/sbin:$PATH"' >> ~/.bash_profile &&
source ~/.bash_profile

# app installations
brew bundle -v
bash install.sh

# quarantine and configure some preferences
# silencing due to 'permission denied' errors for irrelevant files
echo "Removing Apple Quarantine..."
brew cask list | xargs brew cask info | grep '(App)' \
  | sed 's/^/"\/Applications\//;s/\.app.*/.app"/' \
  | xargs sudo xattr -r -d com.apple.quarantine  &>/dev/null

# alternatively read from textfile
# cat casks.txt | xargs brew cask info | grep '(App)' \
#   | sed 's/^/"\/Applications\//;s/\.app.*/.app"/' \
#   | xargs sudo xattr -r -d com.apple.quarantine  &>/dev/null

source config.sh

# Homebrew Cleanup
echo "Attempting to clean system of following formulae absent from Brewfile:"
brew bundle cleanup

read -p "Are you sure you sure want to uninstall the listed formulae?(y/n) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  brew bundle cleanup --force
else
  echo -e "Bundle Cleanup Cancelled. Run: 'brew cleanup --force' to remove installed formulae absent from the Brewfile"
fi

echo "Updating Homebrew Formulae..."
brew upgrade
echo "Cleaning Homebrew..."
brew cleanup
