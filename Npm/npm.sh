#!/usr/bin/env zsh

#===============================================================================
# NPM SETUP
#===============================================================================

cd $(dirname $0);

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# check that npm is installed
which npm &>/dev/null 2>&1 || (
  echo "Installing npm..." &&
  brew install npm
)

# Make sure we’re using the latest npm
brew upgrade npm # npm install -g npm

# upgrade existing packages
npm update

# package installations
xargs npm -g install < npm.txt

echo "Npm Setup Complete!"
