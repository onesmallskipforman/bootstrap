#!/bin/bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished (thank you to donnemartin/dev-setup/osxprep.sh)
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# install all approprate updates on mac, immediately restart to finish installation
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

# install jq for json filtering if it's not already installed
source brewcheck.sh && brewcheck jq

# stage for installation, quarantine, and configuration
source stage.sh
stage --all

# install, quarantine, and restore
source install.sh
source quarantine.sh &>/dev/null 2>&1 # silencing due to 'permission denied' errors
source restore.sh 


