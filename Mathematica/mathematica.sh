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
function cleanup {
  if pgrep "${installer%.*}"; then killall "${installer%.*}"; fi >/dev/null
  if [[ -d  "$mntpath" ]]; then diskutil unmount force "$mntpath"; fi >/dev/null
  if [[ -d  "/Volumes/Mathematica/" ]]; then diskutil unmount force "/Volumes/Mathematica/"; fi >/dev/null
  rm -f "$ipath/$pkgname.dmg"
}
trap cleanup INT ERR TERM EXIT

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
  unzip -o "$ipath/$pkgname.dmg.zip" -d "$ipath/" >/dev/null
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


exit
