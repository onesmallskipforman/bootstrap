#!/bin/zsh

#===============================================================================
# Skhd Config
#===============================================================================

cd "$(dirname $0)"

# copy config
cp .skhdrc ~/

# restart service
brew services restart skhd

# copy (symlink?) launch.sh to /usr/local/bin
cp launch.sh /usr/local/bin
