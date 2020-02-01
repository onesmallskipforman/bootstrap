#!/usr/bin/env zsh

#===============================================================================
# INSTALLATION AND QUARANTINE
#===============================================================================

cd $(dirname $0);

# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# check for homebrew, mas, pip3, and npm, and install if missing
which brew &>/dev/null 2>&1 || (
  echo "Installing homebrew..." &&
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
)

which mas &>/dev/null 2>&1 || (
  echo "Installing mas..." &&
  brew install mas
)

which pip3 &>/dev/null 2>&1 || (
  echo "Installing pip3..." &&
  brew install python3
)

which npm &>/dev/null 2>&1 || (
  echo "Installing npm..." &&
  brew install npm
)

# Make sure we’re using the latest of each
brew update
brew upgrade mas
brew upgrade python # pip3 install -U pip
brew upgrade npm # npm install -g npm

# upgrade stuff
echo "Updating Various Installs..."
brew upgrade
brew cask upgrade --greedy
mas upgrade
pip3 list --outdated --format=freeze \
  | grep -v '^\-e' \
  | cut -d = -f 1  \
  | xargs -n1 pip3 install -U
npm update

# app installations
# brew bundle -v --file Stage/Brewfile
xargs -n 1 brew tap     < Lists/tap.txt
# xargs brew fetch        < Stage/brew.txt
# xargs brew cask fetch   < Stage/cask.txt
xargs brew install      < Stage/brew.txt
xargs brew cask install < Stage/cask.txt
xargs mas install       < Stage/mas.txt
xargs pip3 install      < Stage/pip3.txt
xargs npm -g install    < Stage/npm.txt

# remove outdated versions from the cellar
echo "Cleaning Homebrew..."
brew cleanup

# remove extra installs that are not specified in brewfile
# echo "Attempting to clean system of following formulae absent from Brewfile:"
# brew bundle cleanup

# read -p "Are you sure you sure want to uninstall the listed formulae?(y/n) " -n 1 -r
# if [[ $REPLY =~ ^[Yy]$ ]]; then
#   brew bundle cleanup --force
# else
#   echo -e "Bundle Cleanup Cancelled. Run: 'brew cleanup --force' to remove installed formulae absent from the Brewfile"
# fi

# quarantine homebrew apps
echo "Removing Apple Quarantine..."
brew cask list | xargs brew cask info | grep '(App)' \
  | sed 's/^/"\/Applications\//;s/\.app.*/.app"/' \
  | xargs sudo xattr -r -d com.apple.quarantine  &>/dev/null

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
# brew install coreutils
# sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum
