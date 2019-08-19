#!/bin/bash

###############################################  
# mathematica silent download and installation                                    
###############################################

# in the event of an error, unmount potentially mounted drives and delete low risk installed files
remove() {
  if [[ -n "$(find /Volumes/ -maxdepth 1 -name '*Wolfram*')" ]]; then 
    diskutil unmount force /Volumes/*Wolfram* 2>/dev/null
  fi

  if [[ -n "$(find /Volumes/ -maxdepth 1 -name 'Mathematica')" ]]; then 
    diskutil unmount force /Volumes/Mathematica 2>/dev/null
  fi

  rm -f *.dmg
  rm -rf install_mathematica.app

}
trap remove EXIT

# ask for admin and set to exit on errors
sudo -v
set -e 

# update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# use web scraper to sign in and grab installer, delete scraper log
python3 mathematica.py
rm geckodriver.log

# mount dmg, silently copy installer over, unmount
hdiutil attach *.dmg -nobrowse -quiet
cp -R /Volumes/*Wolfram*/*.app install_mathematica.app
diskutil unmount /Volumes/*Wolfram* 2>/dev/null

# quarantine and run installer, wait for completion and quit
sudo xattr -r -d com.apple.quarantine install_mathematica.app
echo 'starting install'
open -a install_mathematica.app &>/dev/null 2>&1
while [[ ! -n "$(find $HOME/Downloads/M-OSX* -maxdepth 1 -name '*.dmg')" ]]; do sleep 2; done 2>/dev/null

# mount dmg, silently copy app over, unmount
FILE="$HOME/Downloads/*M-OSX*/*.dmg"
hdiutil attach $FILE -nobrowse -quiet
echo 'Moving App to /Applications...'
sudo rsync -a --info=progress2 /Volumes/Mathematica/Mathematica.app /Applications/
diskutil unmount /Volumes/Mathematica 2>/dev/null

# prompt user with key, run app
echo "KEY:" "$(cat ../../Backups/mathematica.txt | tail -n 1)"
/Applications/Mathematica.app/Contents/MacOS/Mathematica

# unmount drives and remove downloaded items
rm -f *.dmg
rm -rf $HOME/Downloads/*M-OSX*
rm -rf install_mathematica.app