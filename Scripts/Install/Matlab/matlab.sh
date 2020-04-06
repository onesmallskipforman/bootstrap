#!/bin/zsh

#===============================================================================
# MATLAB DOWNLOAD AND INSTALLATION
#===============================================================================

# variables based on versioning
version="R2019b"
pkgname="matlab_${version}_maci64"
BACKUP="$BACKUP/Matlab"
mntpath="/Volumes/$pkgname"
installer="InstallForMacOSX.app"

USER="$(sed '1q;d' "$BACKUP/login.txt")"
PASS="$(sed '2q;d' "$BACKUP/login.txt")"

# cleanup function
function cleanup {
  if pgrep "${installer%.*}"; then killall "${installer%.*}"; fi >/dev/null
  if [[ -d  "$mntpath" ]]; then diskutil unmount force "$mntpath"; fi >/dev/null
  rm -f "$BACKUP/$pkgname.dmg"
}
trap cleanup INT TERM EXIT ERR

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "\nRunning Matlab Install Script"

# make directory for installer
mkdir -p "$BACKUP"

# check if app is installed and exit
if [[ ! -d "/Applications/MATLAB_$version.app" || ("$1" == "--force" || "$1" == "-f")]]
then

  # check if installer already downloaded, use web scraper otherwise
  if [[ -f "$BACKUP/$pkgname.dmg.zip" ]]
  then
    echo "MATLAB Installer Already Downloaded."
  else
    python3 matlab.py "$USER" "$PASS" "$BACKUP" "$version"
    exit
  fi

  # unzip and mount dmg, quarantine installer
  unzip -o "$BACKUP/$pkgname.dmg.zip" -d "$BACKUP/" >/dev/null

  sudo xattr -rd com.apple.quarantine "$BACKUP/$pkgname.dmg" &>/dev/null
  hdiutil attach "$BACKUP/$pkgname.dmg" -nobrowse >/dev/null
  # sudo xattr -rd com.apple.quarantine "$mntpath/$installer" &>/dev/null

  # run installer and prompt user with login
  echo 'Starting Installer...'
  echo "User: $USER"
  echo "Pass: $PASS"

  # open and wait for close
  open -W "$mntpath/$installer" # -g

else
  echo "MATLAB_$version Already Installed. Run with --force to reinstall"
fi

# add symlinks for matlab and mlint
sudo ln -sf /Applications/MATLAB_R2019b.app/bin/matlab /usr/local/bin/matlab
sudo ln -sf /Applications/MATLAB_R2019b.app/bin/maci64/mlint /usr/local/bin/mlint

echo 'Install Script Completed!'
