#!/bin/zsh

# experimental library for installing matlab and mathematica

function math_install () {

  local APP="$1"; local pkgname="$2"; local mntpath="$3"; local installer="$4"
  local APPNAME="$5"; local BACKUP="/Math/$APP"

  # cleanup function
  function cleanup {
    if pgrep "${installer%.*}"; then killall "${installer%.*}"; fi
    if [[ -d  "$mntpath" ]]; then diskutil unmount force "$mntpath"; fi
    if [[ "$APP" == "mathematica" ]] && [[ -d  "/Volumes/Mathematica/" ]]; then
      diskutil unmount force "/Volumes/Mathematica/"; >/dev/null
    fi
    rm -f "$BACKUP/$pkgname.dmg"
  } trap cleanup INT ERR TERM EXIT

  # check if app or installer is already installed
  if [[ -d "/Applications/$APPNAME" || ("$1" ~= "--force" || "$1" ~= "-f")]]; then
    echo "$APP Already Installed. Run with --force to reinstall"; exit
  elif [[ -f "$BACKUP/$pkgname.dmg.zip" ]] || [[ -f "$BACKUP/$pkgname.dmg" ]]; then
      echo "$pkgname.dmg.zip Installer Already Downloaded."
  else
    python3 "$APP".py "$USER" "$PASS" "$BACKUP" # TODO: remove versioning from matlab.py
  fi

  # unzip and mount dmg, quarantine installer
  unzip -o "$BACKUP/$pkgname.dmg.zip" -d "$BACKUP/"
  hdiutil attach "$BACKUP/$pkgname.dmg" -nobrowse
  # sudo xattr -rd com.apple.quarantine "$mntpath/$installer" >/dev/null

  # run installer
  if [[ "$APP" == "matlab" ]]; then
    open -W "$mntpath/$installer" # -g
  else
    sudo open "$mntpath/$installer" &>/dev/null
    until ls ~/Downloads/M-OSX*/*.dmg; do sleep 1; done &>/dev/null
    killall "${installer%.*}" &>/dev/null

    # copy mathematica to applications dir
    hdiutil attach ~/Downloads/*M-OSX*/*.dmg -nobrowse >/dev/null
    sudo rsync -a -I -u --info=progress2 /Volumes/Mathematica/Mathematica.app /Applications # 2>/dev/null
  fi

  # add symlinks
  if [[ "$APP" == "matlab" ]]; then
    sudo ln -sf /Applications/MATLAB_R2019b.app/bin/matlab /usr/local/bin/matlab
    sudo ln -sf /Applications/MATLAB_R2019b.app/bin/maci64/mlint /usr/local/bin/mlint
  else
    sudo ln -sf /Applications/Mathematica.app/Contents/MacOS/wolframscript /usr/local/bin/wolframscript
  fi

  echo 'Install Complete.'
}

function mathematica_install () {
  bigprint "Installing Mathematica"

  local version="12.0.0"
  local pkgname="Mathematica_${version}_MAC_DM"
  local mntpath="/Volumes/Download Manager for Wolfram Mathematica 12"
  local installer="Download Manager for Wolfram Mathematica 12.app"
  local appname="Mathematica.app"

  math_install "mathematica" "$pkgname" "$mntpath" "$installer"
  echo "Mathematica Install Complete."
}

function matlab_install () {
  bigprint "Installing MATLAB"

  local version="R2019b"
  local pkgname="matlab_${version}_maci64"
  local mntpath="/Volumes/$pkgname"
  local installer="InstallForMacOSX.app"

  math_install "matlab" "$pkgname" "$mntpath" "$installer"
  echo "MATLAB Install Complete."
}
