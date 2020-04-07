#!/bin/zsh

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#===============================================================================
# HOMEBREW
#===============================================================================

# check for homebrew, mas, and pip3, and install if missing
which brew &>/dev/null 2>&1 || (
  echo "Installing homebrew..." &&
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
)

which mas &>/dev/null 2>&1 || (
  echo "Installing mas..." &&
  brew install mas
)

# run installs/upgrades
brew bundle -v
echo "Brew Setup Complete."

# quarantine homebrew gui apps
echo "Removing Apple Quarantine..."
brew cask list | xargs brew cask info | grep '(App)' \
  | sed 's/^/"\/Applications\//;s/\.app.*/.app"/' \
  | xargs sudo xattr -r -d com.apple.quarantine  &>/dev/null

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
xargs pip3 install < "$PACKAGES_FOLDER/pip.txt"

echo "Pip Setup Complete!"

#===============================================================================
# MISC
#===============================================================================

# setup so latexindent (part of mactex-no-gui) will work
# sudo cpan install Log::Log4perl
# sudo cpan install Log::Dispatch::File
# sudo cpan install YAML::Tiny
# sudo cpan install File::HomeDir

# set up vim directories
# mkdir -p "$XDG_DATA_HOME"/vim/{undo,swap,backup} # TODO: move this

# set up gnupg
# gpg --homedir "$XDG_DATA_HOME"/gnupg
# find $GNUPGHOME -type f -exec chmod 600 {} \;
# find $GNUPGHOME -type d -exec chmod 700 {} \;

echo "Package Manager Setup Complete"
