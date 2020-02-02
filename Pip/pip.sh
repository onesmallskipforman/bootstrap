#!/usr/bin/env zsh

#===============================================================================
# PYTHON SETUP
#===============================================================================

cd "$(dirname $0)";

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# check that pip3 is installed
which pip3 &>/dev/null || (
  echo "Installing pip3..." &&
  brew install python
)

# Make sure we’re using the latest python and pip
brew upgrade python # pip3 install -U pip

# upgrade existing packages
pip3 list --outdated --format=freeze \
  | grep -v '^\-e' \
  | cut -d = -f 1  \
  | xargs -n1 pip3 install -U
npm update

# install packages
xargs pip3 install < pip.txt

echo "Pip Setup Complete!"
