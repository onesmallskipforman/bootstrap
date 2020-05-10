# shell functions for configuring and installing various programs on OS X

#===============================================================================
# MAIN BOOTSTRAP
#===============================================================================

# SYSTEM PREP
function prep() {
  bigprint "Prepping For Bootstrap"

  sudo softwareupdate -irR --verbose    # update os
  sudo tmutil disable                   # disable time machine
  sudo spctl --master-disable           # allow apps downloaded from anywhere

  # install command line tools
  xcode-select -p &>/dev/null || (
    echo "Installing Command Line Tools..." &&
    xcode-select --install
  )
  echo "OS Prep Complete."
}

# INSTALLATIONS
function pkg_install() {
  # homebrew-managed installations
  bigprint "Installing Packages."
  # [[ ! "$OSTYPE" = "darwin"* ]] && echo "OS Config Complete." && return
  which brew &>/dev/null || (           # install homebrew if missing
    echo "Installing Homebrew..." &&
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  )
  brew bundle -v --no-lock "Packages/brewfile"
  echo "Brew Setup Complete."
}

# POST-INSTALL CONFIG
function config() {
  bigprint "Configuring"

  # set firefox at default browser
  /Applications/Firefox.app/Contents/MacOS/firefox -setDefaultBrowser -silent

  # default shell to zsh
  sudo chsh -s /bin/zsh

  # Set computer name
  sudo scutil --set ComputerName  "SkippersMBP"
  sudo scutil --set HostName      "SkippersMBP"
  sudo scutil --set LocalHostName "SkippersMBP"
  dscacheutil -flushcache
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "SkippersMBP"

  # configure osx and set dock elements
  $HOME/.config/aqua/defaults

  echo "OS Config Complete. Restart Required"
}

#===============================================================================
# MISCELLANEOUS
#===============================================================================

function misc() {
  yabai_config
  # math_install
}

function yabai_config() {
  bigprint "Setting Up Window Manager"
  # [[ ! "$OSTYPE" = "darwin"* ]] && echo "OS Config Complete." && return
  [ yabai --check-sa ] || sudo yabai --install-sa
  echo "Window Manager Configured."
}

function math_install() {
  # MATH TOOLS INSTALLATION (EXPERIMENTAL)
  function dmg_cleanup() {
    # remove dmg and installer on exit, failure, etc.
    local installer=$(basename $1); local mountname=$(dirname $1)
    pgrep "${installer%.*}"       && killall "${installer%.*}"
    [ -d  "/Volumes/$mountname" ] && diskutil unmount force "/Volumes/$mountname"
    rm -f "$2"
  }

  function dmg_run () {
    # unzip and mount a dmg
    local DMGPATH="$1"; local INSTPATH="$2"
    trap "dmg_cleanup $INSTPATH" "$DMGPATH" INT ERR TERM EXIT
    unzip -d $(dirname $DMGPATH) "$DMGPATH.zip"
    hdiutil attach "$DMGPATH" -nobrowse
  }

  function mathematica_install () {
    bigprint "Installing Mathematica"

    # attatch dmg, move app, symlink
    local version="12.1.0"
    dmg_run \
      "$XDG_DATA_HOME/mathematica/Mathematica_${version}_MAC.dmg" \
      "/Volumes/Mathematica/Mathematica.app"
    sudo rsync -a -I -u --info=progress2 /Volumes/Mathematica/Mathematica.app /Applications
    sudo ln -sf /Applications/Mathematica.app/Contents/MacOS/wolframscript /usr/local/bin/wolframscript
    trap - INT ERR TERM EXIT # undo trap set in dmg_run
    echo "Mathematica Install Complete."

    # "/Volumes/Download Manager for Wolfram Mathematica 12.1/Download Manager for Wolfram Mathematica 12.1.app"
    # setopt +o nomatch
    # while [ ! -f ~/Downloads/M-OSX-L-$version-*/*.dmg]; do sleep 1; done
    # killall "${installer%.*}"
    # hdiutil attach ~/Downloads/*M-OSX*/*.dmg -nobrowse
  }

  function matlab_install() {
    bigprint "Installing MATLAB"

    # run installer in dmg, print password, wait for closure, symlink
    local version="R2019b"
    dmg_run \
      "$XDG_DATA_HOME/matlab/matlab_${version}_maci64.dmg" \
      "/Volumes/matlab_${version}_maci64/InstallForMacOSX.app"
    pass mathematica
    open -W "/Volumes/matlab_${version}_maci64/InstallForMacOSX.app"
    sudo ln -sf /Applications/MATLAB_${version}.app/bin/matlab       /usr/local/bin/matlab
    sudo ln -sf /Applications/MATLAB_${version}.app/bin/maci64/mlint /usr/local/bin/mlint
    trap - INT ERR TERM EXIT # undo trap set in dmg_run
    echo "MATLAB Install Complete."
  }
}
