#!/bin/sh


# OSX
brew install basictex
# TODO: double-check you may need to do brew install --cask basictex to ensure the installer is run
# alternative large install: brew install mactex
export PATH="$PATH:/Library/TeX/Root/bin/universal-darwin"
# alterntively run eval "$(/usr/libexec/path_helper)" to update PATH
# for tlmgr gui
# brew install perl
# cpan -i Tk # CPAN = comprehensiver perl archive network

# Ubuntu
sudo apt install texlive-latex-base
# alternative large install: sudo apt install texlive-full
# for tlmgr gui
# sudo apt install perl-tk

# (BOTH) TLMGR
# probably not as much is needed when doing a full install
sudo tlmgr update --self
sudo tlmgr install latexmk
# sudo tlmgr install xelatex # if it's not already installed
sudo tmlgr install \
  preprint \
  titlesec \
  helvetic \
  enumitem \
  xifthen \
  relsize \
  multirow
# for gui
# tlmgr --gui
