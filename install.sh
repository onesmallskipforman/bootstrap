#!/bin/bash

#===============================================================================
# SKIPPER'S DOTFILES RUN SCRIPT
#===============================================================================

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ensure zsh is the default shell
chsh -s /bin/zsh

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

#===============================================================================
# APP INSTALLATION AND QUARANTINE
#===============================================================================

# app installations
# brew bundle -v
xargs -n 1 brew tap     < Lists/tap.txt
xargs brew install      < Lists/brew.txt
xargs brew cask install < Lists/cask.txt
xargs mas install       < Lists/mas.txt
xargs pip3 install      < Lists/pip3.txt
xargs npm -g install    < Lists/npm.txt

# MATLAB and Mathematica install
Math/mathematica.py "Backups/Private/mathematica.txt"
Math/matlab.py      "Backups/Private/matlab.txt"

# quarantine and configure some preferences
# silencing due to 'permission denied' errors for irrelevant files
echo "Removing Apple Quarantine..."
brew cask list | xargs brew cask info | grep '(App)' \
  | sed 's/^/"\/Applications\//;s/\.app.*/.app"/' \
  | xargs sudo xattr -r -d com.apple.quarantine  &>/dev/null

#===============================================================================
# APP CONFIG SCRIPTS
#===============================================================================

Config/dock.sh
Config/iterm.sh
Config/osx.sh
Config/safari.sh
Config/terminal.sh
Config/git.sh
Config/docker.sh

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

#===================================================================
# CLEANUP
#===================================================================

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
