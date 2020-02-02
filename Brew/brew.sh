#!/usr/bin/env zsh

#===============================================================================
# HOMEBREW AND MAS INSTALLATION
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

# Make sure we’re using the latest of each
brew update
brew upgrade mas

# upgrade existing installs
echo "Updating Various Installs..."
brew upgrade
brew cask upgrade # brew cask upgrade --greedy # for autoupdate and :latest
mas upgrade

# app installations
# brew bundle -v --file Brewfile
xargs -n 1 brew tap     < tap.txt
# xargs brew fetch        < brew.txt
# xargs brew cask fetch   < cask.txt
xargs brew install      < brew.txt
xargs brew cask install < cask.txt
xargs mas install       < mas.txt

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
