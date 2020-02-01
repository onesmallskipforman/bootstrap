#!/bin/zsh

#===============================================================================
# MATLAB DOWNLOAD AND INSTALLATION
#===============================================================================

# variables based on versioning
version="R2019b"
pkgname="matlab_${version}_maci64"
ipath="mathroom/matlab/$version"

# cleanup function
set -e
function cleanup {
  rm -f "$ipath/$pkgname.dmg"
  diskutil unmount "/Volumes/$pkgname" &>/dev/null
}
trap cleanup EXIT

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "\nRunning Matlab Install Script"

# change to directory of script
cd $(dirname $0)

# make directory for installer
mkdir -p "$ipath"

# check if app is installed and exit
if [[ -d "/Applications/MATLAB_$version.app" ]]
then
  echo "MATLAB_$version Already Installed."
  exit
fi

# check if installer already downloaded, use web scraper otherwise
if [[ -f "mathcache/$pkgname.dmg.zip" ]]
then
  echo "MATLAB Installer Already Downloaded."
else
  python3 matlab.py $version
fi

# unzip and mount dmg, copy installer, unmount, remove dmg, quarantine
unzip "mathcache/$pkgname.dmg.zip" -d "$ipath"              >/dev/null
hdiutil attach "$ipath/$pkgname.dmg" -nobrowse              >/dev/null
cp -R "/Volumes/$pkgname"/*.app "$ipath/install_matlab.app" >/dev/null
diskutil unmount "/Volumes/$pkgname"                        >/dev/null
rm -f "$pkgname.dmg"
sudo xattr -r -d com.apple.quarantine "$ipath/install_matlab.app" &>/dev/null

# prompt user with username and password for install
echo 'Starting Installer. Quit app to continue.'
echo "User:" "$(sed '1q;d' "../Backup/Private/Matlab/login.txt")"
echo "Pass:" "$(sed '2q;d' "../Backup/Private/Matlab/login.txt")"

# run installer, wait for app to be installed, continue when gui is quit
open "$ipath/install_matlab.app" &>/dev/null


while [[ ! -d "/Applications/MATLAB_$version.app" ]]
  do sleep 2
done 2>/dev/null

# quit (currently buggy when java dialogue is open)
# osascript -e 'quit app "install_matlab"'

# if app is not installed, terminate
if [[ ! -d "/Applications/MATLAB_$version.app"]]
then
  echo "Installer Closed before Install Completed"
  rm -rf "/Applications/MATLAB_$version.app"
fi

echo 'MATLAB Installed!'
