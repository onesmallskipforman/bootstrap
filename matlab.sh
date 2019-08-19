#!/bin/bash

###############################################  
# matlab silent download and installation                                   
###############################################


# in the event of an error or early exit, delete installed files
remove() {
  rm -f *.zip
  rm -f *.dmg
  rm -rf install_matlab.app
}
trap remove EXIT

# ask for admin and set to exit on errors
sudo -v
set -e 

# update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# use web scraper to sign in and grab installer, delete scraper log
python3 matlab.py
rm geckodriver.log

# unzip dmg and remove zip
unar *.zip
rm *.zip

# mount dmg, silently copy installer over, unmount and delete
hdiutil attach *.dmg -nobrowse -quiet
cp -R /Volumes/*matlab*/*.app install_matlab.app
diskutil unmount /Volumes/*matlab*
rm -f *.dmg

# quarantine installer 
sudo xattr -r -d com.apple.quarantine install_matlab.app

# prompt user with username and password for installer gui
echo "User:" "$(cat ../../Backups/matlab.txt | head -n 1)" 
echo "Pass:" "$(cat ../../Backups/matlab.txt | tail -n 1)"

# run installer, wait for completion and quit
echo 'starting install'
open -a install_matlab.app
FILE=/Applications/*MATLAB*.app
while [[ ! -n "$(find /Applications -maxdepth 1 -name 'MATLAB*.app')" ]]; do sleep 2; done 2>/dev/null

# shut down and remove installer
rm -rf install_matlab.app
# osascript -e 'quit app "install_matlab"'
