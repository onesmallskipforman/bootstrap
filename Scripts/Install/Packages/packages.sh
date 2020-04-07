#!/bin/zsh

#===============================================================================
# HOMEBREW AND MAS INSTALLATION
#===============================================================================

PACKDIR=$(dirname $0)

# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# check for homebrew, mas, and pip3, and install if missing
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

# disable services
brew services stop --all

# upgrade existing installs
echo "Updating Various Installs..."
brew upgrade
brew cask upgrade # brew cask upgrade --greedy # for autoupdate and :latest
mas upgrade

# app installations
# brew bundle -v --file Brewfile
# xargs -n 1 brew tap     < tap.txt
# # xargs brew fetch        < brew.txt
# # xargs brew cask fetch   < cask.txt
# xargs brew install      < brew.txt
# xargs brew cask install < cask.txt
# xargs mas install       < mas.txt

comm -23 <(sort "$PACKDIR/tap.txt")  <(brew tap | sort) | xargs -n 1 brew tap
comm -23 <(sort "$PACKDIR/brew.txt") <(brew leaves | sort) | xargs brew install
comm -23 <(sort "$PACKDIR/cask.txt") <(brew cask list | sort) | xargs brew cask install
comm -23 <(sort "$PACKDIR/mas.txt")  <(mas list | sed 's/[[:space:]].*$//' | sort) | xargs mas install

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


# reenable services
brew services start --all

echo "Brew Setup Complete!"

#===============================================================================
# PIP
#===============================================================================

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

# install packages
xargs pip3 install < "$PACKDIR/pip.txt"

echo "Pip Setup Complete!"

#===============================================================================
# misc setup for various casks
#===============================================================================

# setup so latexindent (part of mactex-no-gui) will work
sudo cpan install Log::Log4perl
sudo cpan install Log::Dispatch::File
sudo cpan install YAML::Tiny
sudo cpan install File::HomeDir

# set up vim directories
# mkdir -p "$XDG_DATA_HOME"/vim/{undo,swap,backup} # TODO: move this

# set up gnupg
# gpg --homedir "$XDG_DATA_HOME"/gnupg
# find $GNUPGHOME -type f -exec chmod 600 {} \;
# find $GNUPGHOME -type d -exec chmod 700 {} \;

echo "Package Manager Setup Complete"
