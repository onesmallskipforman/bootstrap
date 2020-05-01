# shell functions for configuring and installing various programs on OS X

#===============================================================================
# SYSTEM PREP
#===============================================================================

function os_prep() {
  bigprint "Prepping OS"

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

#===============================================================================
# INSTALLATIONS
#===============================================================================

function pkg_install() {
  # homebrew-managed installations
  bigprint "Installing Packages."
  # [[ ! "$OSTYPE" = "darwin"* ]] && echo "OS Config Complete." && return
  which brew &>/dev/null || (           # install homebrew if missing
    echo "Installing Homebrew..." &&
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  )
  brew bundle -v --no-lock
  echo "Brew Setup Complete."
}

function cargo_install() {
  bigprint "Installing Cargo Packages"
  which rustup &>/dev/null || (
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    rustup override set stable
  )
  rustup update stable
  source $HOME/.cargo/env
  cat "$HOME/.config/cargo/cargo_osx.txt" | xargs -n1 cargo install --git
}

function git_install() {
  bigprint "Cloning Git Repos"
  while IFS= read URL; do
    DIR=$HOME/.local/src/$(basename "$URL" .git)
    clonepull "$URL" "$DIR"
  done < "$HOME/.config/git/repos_osx.txt"
  echo "Repo Cloning Complete."
}

#===============================================================================
# APP CONFIGS/SETUPS
#===============================================================================

function os_config() {
  # set osx defaults
  bigprint "Configuring OS"
  # [[ ! "$OSTYPE" = "darwin"* ]] && echo "OS Config Complete." && return

  # Close any open System Preferences panes
  osascript -e 'quit app "System Preferences"'

  # default shell to zsh
  sudo chsh -s /bin/zsh

  # Set computer name (as done via System Preferences → Sharing)
  sudo scutil --set ComputerName  "SkippersMBP"
  sudo scutil --set HostName      "SkippersMBP"
  sudo scutil --set LocalHostName "SkippersMBP"
  dscacheutil -flushcache
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "SkippersMBP"

  # Set a custom wallpaper image
  WALLPAPER="$XDG_DATA_HOME/wallpapers/beams.jpeg"
  osascript -e "tell application \"Finder\" to set desktop picture to \"$(realpath "$WALLPAPER")\" as POSIX file"
  osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$(realpath "$WALLPAPER")\""

  # configure osx and set dock elements
  $XDG_CONFIG_HOME/osx/defaults
  $XDG_CONFIG_HOME/osx/dock

  for app in "Activity Monitor" \
    "Dock" \
    "Finder" \
    "Messages" \
    "Safari" \
    "cfprefsd" \
    "SystemUIServer"; do
    killall "${app}" &> /dev/null
  done

  echo "OS Config Complete."
}

function wm_config() {
  bigprint "Setting Up Window Manager"
  # [[ ! "$OSTYPE" = "darwin"* ]] && echo "OS Config Complete." && return
  sudo yabai --uninstall-sa; sudo yabai --install-sa
  echo "Window Manager Configured."
}

function xdg_link() {
  bigprint "Linking XDG Files"
  # [[ ! "$OSTYPE" = "darwin"* ]] && echo "OS Config Complete." && return

  function xdg_generic() {
    # links personal files that follow XDG standard to those that do not

    OS="$1" # path to files on specific OS
    for item in "${@:2}"; do
      # Trim Path and Prepend OS Path
      sed 's!.*/!!; s,^,'"$OS/"',' <<< "$item" | xargs -I{} rm -r {}
    done

    # link items
    ln -sf "${@:2}" "$OS"
    ls -l "$OS"
  }

  OSX="$HOME/Library/ApplicationSupport"
  xdg_generic "$OSX/Code/User" \
    "$XDG_CONFIG_HOME/Code/User"/*
  xdg_generic "$OSX/Minecraft" \
    "$XDG_CONFIG_HOME/minecraft"/* "$XDG_DATA_HOME/minecraft"/*
  xdg_generic "$OSX/Slack" \
    "$XDG_DATA_HOME/slack"/*
  xdg_generic "$OSX/Spotify" \
    "$XDG_DATA_HOME/spotify"/*
  xdg_generic "$OSX/Sublime Text 3" \
    "$XDG_CONFIG_HOME/sublime-text-3/User"
  xdg_generic "$OSX/Sublime Text 3/Cache/Python" \
    "$XDG_CONFIG_HOME/sublime-text-3/Cache/Python/Completion Rules.tmPreferences"
  xdg_generic "$OSX/Sublime Text 3/Installed Packages" \
    "$XDG_CONFIG_HOME/sublime-text-3/Installed Packages/Package Control.sublime-package"
  xdg_generic "$OSX/Übersicht" \
    "$XDG_CONFIG_HOME/ubersicht/widgets"
  xdg_generic "$OSX/tracesOf.Uebersicht" \
    "$XDG_CONFIG_HOME/ubersicht/WidgetSettings.json"

  echo "XDG Linking Complete."
}

#===============================================================================
# MATH TOOLS INSTALLATION (EXPERIMENTAL)
#===============================================================================

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
