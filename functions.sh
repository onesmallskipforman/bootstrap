#!/bin/zsh

# shell functions for configuring and installing various programs

#===============================================================================
# SYSTEM PREP
#===============================================================================

function dotfiles() {
  # bootstrap scripts and configs
  bigprint "Syncing dotfiles repo to home"
  GHUB="https://github.com/onesmallskipforman"
  clonepull "$GHUB/bootstrap.git" "$1"
  clonepull "$GHUB/dotfiles.git"  "$1/Home"
  clonepull "$GHUB/userdata.git"  "$1/Home/.local/share"

  # remove old files, then symlink (or copy)
  rm -rf "$HOME"/{.config,.local,.zshenv}
  ln -sf "$1/Home"/{.config,.local,.zshenv} "$HOME"
  # cp -r "$DIR/Home"/{.config,.local,.zshenv} "$HOME"
}

function osxprep() {
  bigprint "Updating OSX and installing Xcode command line tools"

  # ensure zsh is the default shell
  sudo chsh -s /bin/zsh

  # Update OS
  sudo softwareupdate -iR --verbose #-iaR --verbose # sudo for -R option

  # allows apps downloaded from anywhere
  sudo spctl --master-disable

  # Set computer name (as done via System Preferences → Sharing)
  sudo scutil --set ComputerName "SkippersMBP"
  sudo scutil --set HostName "SkippersMBP"
  sudo scutil --set LocalHostName "SkippersMBP"
  dscacheutil -flushcache
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "SkippersMBP"

  # Turn Dark mode on
  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

  # Set a custom wallpaper image
  WALLPAPER="$XDG_DATA_HOME/wallpapers/beams.jpeg"
  osascript -e "tell application \"Finder\" to set desktop picture to \"$(realpath "$WALLPAPER")\" as POSIX file"
  osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$(realpath "$WALLPAPER")\""

  # Disable local Time Machine snapshots
  sudo tmutil disable

  # install command line tools
  xcode-select -p &>/dev/null 2>&1 || (
    echo "Installing Command Line Tools..." &&
    xcode-select --install
  )

  echo "OSX Prep Config Complete."
}

#===============================================================================
# INSTALLATIONS
#===============================================================================

function homebrew_install () {
  # homebrew-managed installations
  bigprint "Installing Packages (Homebrew, Cask, Mas)."

  # check for homebrew  mas, and install if missing
  which brew &>/dev/null 2>&1 || (
    echo "Installing homebrew..." &&
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  )

  which mas &>/dev/null 2>&1 || (
    echo "Installing mas..." &&
    brew install mas
  )

  # run installs/upgrades
  # brew update
  brew bundle -v
  # brew cleanup

  # quarantine homebrew gui apps
  echo "Removing Apple Quarantine..."
  HOMEBREW_NO_AUTO_UPDATE=1
  brew cask list | xargs brew cask info | grep '(App)' \
    | sed 's/^/"\/Applications\//;s/\.app.*/.app"/' \
    | xargs sudo xattr -r -d com.apple.quarantine  &>/dev/null
  HOMEBREW_NO_AUTO_UPDATE=0

  echo "Brew Setup Complete."
}

function termpdf_install() {
  # termpdf.py installation
  bigprint "Installing Termpdf"

  git clone https://github.com/dsanson/termpdf.py
  pip3 install -r termpdf.py/requirements.txt -U
  cp -f termpdf.py/termpdf.py /usr/local/bin/termpdf
  rm -rf "termpdf.py"

  echo "Termpdf Installtion Complete."
}

function refind_install() {
  # install rEFInd boot manager
  bigprint "Setting Up rEFInd"

  # Folders
  local DATA="$HOME/.local/share/refind"
  local CONFIG="$HOME/.config/refind"
  local REFDIR="/Volumes/ESP/EFI/refind"

  # if not installed or forced, run install prep
  mkdir -p $DATA
  rm -rf $DATA/refind-bin*
  wget --hsts-file="$XDG_CACHE_HOME/wget-hsts" -O $DATA/refind.zip \
    https://sourceforge.net/projects/refind/files/latest/download
  unzip $DATA/refind.zip -d $DATA/
  rm $DATA/refind.zip
  sudo $DATA/refind-bin*/mountesp
  rm -rf "$REFDIR"

  # install/upgrade
  sudo $DATA/refind-bin*/refind-install

  # clean upgrade contents, copy refind.conf
  rm -f "$REFDIR/refind.conf-sample"
  rm -rf "$REFDIR/icons-backup"
  cp "$CONFIG/refind.conf" "$REFDIR/refind.conf"

  # install themes
  mkdir "$REFDIR/themes"

  # refind theme Regular
  git clone https://github.com/bobafetthotmail/refind-theme-regular.git "$REFDIR/themes/refind-theme-regular"
  echo "include themes/refind-theme-regular/theme.conf" >> "$REFDIR/refind.conf"
  cp "$CONFIG/theme.conf" "$REFDIR/themes/refind-theme-regular/theme.conf"

  # major theme
  # git clone https://github.com/kgoettler/ursamajor-rEFInd.git "$REFDIR/themes/rEFInd-minimal-black"
  # echo "include themes/ursamajor-rEFInd/theme.conf" >> "$REFDIR/refind.conf"

  # minimalist black theme
  # git clone https://github.com/andersfischernielsen/rEFInd-minimal-black "$REFDIR/themes/rEFInd-minimal-black"
  # echo "include themes/rEFInd-minimal-black/theme.conf" >> "$REFDIR/refind.conf"

  # unmount ESP/EFI
  sudo diskutil unmount /Volumes/ESP

  echo "Refind Installation Complete."
}

# experimental
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

# experimental
function matlab_install () {
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

#===============================================================================
# APP CONFIGS/SETUPS
#===============================================================================

function gpg_perm() {
  # set permisisons for relevant dirs used by gpg
  bigprint "Set GPG Store Permissions"

  # make directory and set permissions
  mkdir -p "$GNUPGHOME"
  find $GNUPGHOME -type f -exec chmod 600 {} \;
  find $GNUPGHOME -type d -exec chmod 700 {} \;

  echo "GPG Directory Permissions Set."
}

function docker() {
  # setup of docker virtual machine and account login
  bigprint "Sign In To Docker Account"

  # restart service
  brew services restart docker-machine

  # create driver, set environment variables, login
  docker-machine create --driver virtualbox default
  eval $(docker-machine env default)
  pass docker | xargs -n2 sh -c 'docker login -u "$1" --password-stdin <<< "$2"' sh
  # pass docker | xargs -n2 sh -c 'docker login -u "$1" -p "$2"' sh

  echo "Docker Setup Complete."
}

function editors() {
  # configuration for text editors
  bigprint "Setting Up Text Editor Packages"

  # vscode: install plugins in list that are not already installed
  comm -23 \
    <(sort "$XDG_CONFIG_HOME/Code/plugins.txt") \
    <(code --list-extensions | sort) \
    | xargs -n 1 code --install-extension

  # Sublime: Install Package Control
  local URL="https://packagecontrol.io/Package%20Control.sublime-package"
  local DIR="$HOME/Library/ApplicationSupport/Sublime Text 3/Installed Packages"

  [ ! -f "$DIR/Package Control.sublime-package" ] &&
    wget --hsts-file="$XDG_CACHE_HOME/wget-hsts" "$URL" &&\
    mv "Package Control.sublime-package" "$DIR"

  echo "Text Editor Config Complete."
}

function osx() {
  # set osx defaults
  bigprint "Configuring OSX"

  # Close any open System Preferences panes
  osascript -e 'quit app "System Preferences"'

  # configure osx and set dock elements
  $XDG_CONFIG_HOME/osx/osx
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

  echo "OSX Config Complete."
}

function xdg() {
  bigprint "Linking XDG Files"

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
  xdg_generic "$OSX/Übersicht" \
    "$XDG_CONFIG_HOME/ubersicht/widgets"
  xdg_generic "$OSX/tracesOf.Uebersicht" \
    "$XDG_CONFIG_HOME/ubersicht/WidgetSettings.json"

  echo "XDG Linking Complete."
}

function yabai_sa() {
  bigprint "Setting Up Yabai Scripting Addon"

  # install the scripting addition
  sudo yabai --uninstall-sa
  sudo yabai --install-sa

  # load the new scripting addition
  killall Dock; brew services restart yabai

  echo "Yabai Scripting Addition Installed."
}

function kitty_themes() {
  # kitty themes install

  # build themes directory
  DATA="$XDG_DATA_HOME/kitty"
  CONFIG="$XDG_CONFIG_HOME/kitty"
  rm -rf "$DATA/themes"
  mkdir -p "$DATA/themes"

  git clone https://github.com/dexpota/kitty-themes "$DATA/kitty-themes"
  git clone https://github.com/kdrag0n/base16-kitty "$DATA/base16-kitty"
  cp "$DATA/kitty-themes/themes"/* "$DATA/base16-kitty/colors"/* "$DATA/themes/"

  rm -rf "$DATA/kitty-themes" "$DATA/base16-kitty"

  # set theme (copy or link)
  rm -rf "$CONFIG/theme.conf"
  cp "$DATA/themes/Monokai_Pro_(Filter_Octagon).conf" "$CONFIG/theme.conf"

  # for testing themes
  # kitty @ set-colors -a "$DATA/themes/<theme>.conf"

  echo "Kitty Themes Installed."
}

function config() {
  bigprint "Configuring Various Programs"
  # run above configs
  gpg_perm
  docker
  editors
  osx
  xdg
  yabai_sa
  kitty_themes
}

#===============================================================================
# UTILITIES
#===============================================================================

function bigprint() {
  # print section
  echo ""
  echo "-------------------------------------------------------------------"
  echo "$1"
  echo "-------------------------------------------------------------------"
  echo ""
}

function clonepull() {
  [ ! -d "$2/.git" ] && git clone "$1" "$2" || git -C "$2" pull origin master
}

# experimental
function dmg_cleanup {
  # remove dmg and installer on exit, failure, etc.
  local installer=$(basename $1); local mountname=$(dirname $1)
  pgrep "${installer%.*}"       && killall "${installer%.*}"
  [ -d  "/Volumes/$mountname" ] && diskutil unmount force "/Volumes/$mountname"
  rm -f "$2"
}

# experimental
function dmg_run () {
  # unzip and mount a dmg
  local DMGPATH="$1"; local INSTPATH="$2"
  trap "dmg_cleanup $INSTPATH" "$DMGPATH" INT ERR TERM EXIT
  unzip -d $(dirname $DMGPATH) "$DMGPATH.zip"
  hdiutil attach "$DMGPATH" -nobrowse
}
