#!/bin/bash

###############################################  
# matlab silent download and installation                                   
###############################################

# rewrite the $2 preceding lines (default 1)
oprint () {
  if [[ -z "$2" ]]; then count=1; else count="$2"; fi
  echo -en "\r\033[K"                      # wipe 0th line
  
  for (( i=1; i <= $count; i++ )); do      # wipe next $count lines above
    echo -en "\r\033[1A\033[K" 
  done
  echo -en "\r\033[K$1\n"                  # write $count-th line above
}

set -eE -o functrace
failure () {
  local lineno=$1
  local msg=$2
  echo "Failed at $lineno: $msg"
  remove
}

# in the event of a premature exit, unmount potentially mounted drives and trash downloads
remove () {
  set +e
  sudo diskutil unmount force /Volumes/*matlab* >/dev/null 2>&1

  trash -F geckodriver.log                      >/dev/null 2>&1
  trash -F *.zip                                >/dev/null 2>&1
  trash -F *.dmg*                               >/dev/null 2>&1
  trash -F *.app                                >/dev/null 2>&1
  echo "Installer Script Terminated Prematurely."
  exit
}
trap "remove" INT TERM # EXIT 
trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

# ask for admin and persist
sudo -v; while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# print line so stdout more visible during install
echo ""

# check if app is installed and exit
if [[ -n "$(find /Applications -maxdepth 1 -name '*MATLAB*.app')" ]]; then
  oprint "MATLAB Already Installed."
  exit
fi

# change to directory of script
cd $(dirname $0)

# use web scraper to sign in and grab installer
python3 matlab.py

# unzip and mount dmg, copy installer, unmount, quarantine
unar *.zip                                       >/dev/null
hdiutil attach *.dmg -nobrowse                   >/dev/null
cp -R /Volumes/*matlab*/*.app ./                 >/dev/null
diskutil unmount /Volumes/*matlab*               >/dev/null
sudo xattr -r -d com.apple.quarantine *.app

# prompt user with username and password for install
oprint 'Starting Installer. Quit app to continue.'
echo "User:" "$(cat ../../Backups/matlab.txt | head -n 1)" 
echo "Pass:" "$(cat ../../Backups/matlab.txt | tail -n 1)"

# run installer, wait for app to be installed, continue when gui is quit
# open -a *.app >/dev/null
InstallForMacOSX.app/Contents/MacOS/InstallForMacOSX >/dev/null 2>&1

# quit (currently buggy when java dialogue is open)
# while [[ ! -n "$(find /Applications -maxdepth 1 -name 'MATLAB*.app')" ]]; do sleep 2; done 2>/dev/null
# killall -9 "$(basename *Install* .app)"

# if app is not installed, terminate
if [[ ! -n "$(find /Applications -maxdepth 1 -name '*MATLAB*.app')" ]]; then
  echo "Installer Closed before Install Completed"; exit 1
fi

oprint 'MATLAB Installed!' 4

# remove downloaded items
rm -f geckodriver.log
rm -f *.zip
rm -f *.dmg*
rm -rf *.app
