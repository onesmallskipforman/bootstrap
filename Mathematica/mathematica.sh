#!/bin/zsh

#===============================================================================
# MATHEMATICA DOWNLOAD AND INSTALLATION
#===============================================================================

cd "$(dirname $0)"

# variables based on versioning
version="12.0.0"
pkgname="Mathematica_${version}_MAC_DM"
ipath="Private"
mntpath="/Volumes/Download Manager for Wolfram Mathematica 12"
mntpath2="/Volumes/Download Manager for Wolfram Mathematica 12"
installer="Download Manager for Wolfram Mathematica 12.app"

USER="$(sed '1q;d' "Private/login.txt")"
PASS="$(sed '2q;d' "Private/login.txt")"
# KEY="$(sed '3q;d' "Private/login.txt")"

# cleanup function
set -e
function cleanup {
  rm -f "$ipath/$pkgname.dmg"
  diskutil unmount force "$mntpath"              &>/dev/null
  diskutil unmount force "/Volumes/Mathematica/" &>/dev/null
}
trap cleanup INT TERM EXIT

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "\nRunning Mathematica Install Script"

# make directory for installer
mkdir -p "$ipath"

# check if app is installed and exit
if [[ ! -d "/Applications/Mathematica.app" || ("$1" == "--force" || "$1" == "-f")]]
then

  # check if installer already downloaded, use web scraper otherwise
  if [[ -f "$ipath/$pkgname.dmg.zip" ]]
  then
    echo "Mathematica Installer Already Downloaded."
  else
    python3 mathematica.py "$USER" "$PASS" "$ipath"
  fi

  # unzip and mount dmg, quarantine installer
  unzip "$ipath/$pkgname.dmg.zip" >/dev/null
  hdiutil attach "$ipath/$pkgname.dmg" -nobrowse >/dev/null
  # sudo xattr -rd com.apple.quarantine "$mntpath/$installer" >/dev/null

  # run installer and prompt user with login
  echo 'Starting Installer...'

  # open and wait for app dmg containter to install
  sudo open "$mntpath/$installer" &>/dev/null
  until ls ~/Downloads/M-OSX*/*.dmg; do sleep 1; done &>/dev/null
  killall "${installer%.*}" &>/dev/null

  echo 'Copying Mathematica to /Applications'
  hdiutil attach ~/Downloads/*M-OSX*/*.dmg -nobrowse >/dev/null
  sudo rsync -a -I -u --info=progress2 /Volumes/Mathematica/Mathematica.app /Applications # 2>/dev/null
  # --delete

  # echo 'Opening Mathematica for Sign In'
  # echo "User: $USER"
  # echo "Pass: $PASS"
  # echo "Key:  $KEY"
  # open -g -W -a "Mathematica.app"
else
  echo "Mathematica Already Installed. Run with --force to reinstall"
fi

# add symlink for wolframscript
sudo ln -sf /Applications/Mathematica.app/Contents/MacOS/wolframscript /usr/local/bin/wolframscript

echo 'Install Script Completed!'














# #!/bin/bash

# ###############################################
# # mathematica silent download and installation
# ###############################################

# # rewrite the $2 preceding lines (default 1)
# oprint () {
#   if [[ -z "$2" ]]; then count=1; else count="$2"; fi
#   echo -en "\r\033[K"                      # wipe 0th line

#   for (( i=1; i <= $count; i++ )); do      # wipe next $count lines above
#     echo -en "\r\033[1A\033[K"
#   done
#   echo -en "\r\033[K$1\n"                  # write $count-th line above
# }

# # set -eE -o functrace
# failure () {
#   local lineno=$1
#   local msg=$2
#   echo "Failed at $lineno: $msg"
#   remove
# }

# # in the event of a premature exit, unmount potentially mounted drives and trash downloads
# remove () {
#   set +e
#   sudo diskutil unmount force /Volumes/*Wolfram*   >/dev/null 2>&1
#   sudo diskutil unmount force /Volumes/Mathematica >/dev/null 2>&1

#   trash -F *.dmg*                             >/dev/null 2>&1
#   trash -F *.app                              >/dev/null 2>&1
#   trash -F $HOME/Downloads/*M-OSX*            >/dev/null 2>&1
#   trash -F geckodriver.log                    >/dev/null 2>&1
#   echo "Installer Script Terminated Prematurely."
#   exit
# }
# trap "remove" INT TERM # EXIT
# # trap 'failure ${LINENO} "$BASH_COMMAND"' ERR

# # ask for admin and persist
# sudo -v; while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# # print line so stdout more visible during install
# echo ""

# # check if app is installed and exit
# if [[ -n "$(find /Applications -maxdepth 1 -name 'Mathematica.app')" ]]; then
#   oprint "Mathematica Already Installed."
#   exit
# fi

# # change to directory of script
# cd "$(dirname $0)"

# # use web scraper to sign in and grab installer
# python3 mathematica.py $1

# # mount dmg, copy installer, unmount, quarantine
# hdiutil attach *.dmg -nobrowse            >/dev/null
# cp -R /Volumes/*Wolfram*/*.app ./         >/dev/null
# diskutil unmount force /Volumes/*Wolfram* >/dev/null
# sudo xattr -d com.apple.quarantine *.app

# # run, quit installer
# oprint 'Starting Installation.'
# open -a *.app >/dev/null
# while [[ ! -n "$(find $HOME/Downloads -maxdepth 2 -iname '*mathematica*.dmg')" ]]; do sleep 2; done
# killall -9 "$(basename *Wolfram* .app)"

# # mount dmg, silently copy app over, unmount on completion
# oprint 'Moving App to /Applications...'
# FILE="$HOME/Downloads/*M-OSX*/*.dmg"
# hdiutil attach $FILE -nobrowse >/dev/null
# sudo rsync -a --info=progress2 /Volumes/Mathematica/Mathematica.app /Applications/
# diskutil unmount force /Volumes/Mathematica >/dev/null

# # prompt user with key, run app, continue when gui is quit
# oprint "Opening Authentication. Quit app to continue."
# oprint "Auth KEY: $(cat ../../Backups/mathematica.txt | tail -n 1)" 0
# /Applications/Mathematica.app/Contents/MacOS/Mathematica
# oprint 'Mathematica Installed!' 3

# # remove downloaded items
# rm -f *.dmg*
# rm -rf *.app
# rm -rf $HOME/Downloads/*M-OSX*
# rm -f geckodriver.log
