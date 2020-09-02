# shell functions for configuring and installing various programs

#===============================================================================
# SYSTEM PREPS
#===============================================================================

function dotfiles() {

  function gitstrap() {
    git -C "$2" init
    git -C "$2" remote add origin "$1"
    git -C "$2" fetch --depth 1 origin master
    git -C "$2" reset --hard origin/master
  }

  # dotfile boostrap
  bigprint "Syncing dotfiles repo to home"
  mkdir -p "Home"
  mv -n "$HOME"/{.config,.local,.zshenv} "$1/Home" &>/dev/null
  GHUB="https://github.com/onesmallskipforman"
  DIR=$(realpath $(dirname $0))
  gitstrap "$GHUB/dotfiles.git"  "$DIR/Home"
  gitstrap "$GHUB/userdata.git"  "$DIR/Home/.local/share"

  # symlink
  ln -sf "$DIR/Home"/{.config,.local,.zshenv} "$HOME"
}

function prep(){
  bigprint "Prepping For Bootstrap"
  which apt-get &>/dev/null && {
    sudo apt-get -y update --fix-missing && sudo apt-get -y dist-upgrade
    sudo apt-get install -y git gcc
  }
  [ $(uname) = "Darwin" ] && {
    sudo softwareupdate -irR && xcode-select --install
      which brew &>/dev/null || (curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash)
  }
  echo "OS Prep Complete."
}

#===============================================================================
# INSTALLATIONS
#===============================================================================

function pkg_install() {
  bigprint "Installing Packages."
  filter "key" | xargs -rn1 sudo apt-key adv --fetch-keys
  filter "ppa" | xargs -I{} sudo add-apt-repository -y "{}"
  filter "apt" | xargs -r sudo apt-get install -y
  filter "brf" | xargs -rn1 brew bundle -v --no-lock
  filter "pip" | xargs -r sudo python3 -m pip install -U "$@"
  filter "git" | xargs -I{} clonepull {}
  filter "ndf" | xargs -I{} nerdfont_install {}
  filter "deb" | xargs -I{} deb_install {}
  echo "Package Install Complete."
}

function nerdfont_install() {
  wget -q --show-progress \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/$arg.zip \
    && unzip -qod /usr/local/share/fonts && rm $arg.zip
}

function deb_install() {
  DEB=$(basename $1); wget -qod $1 && sudo apt-get install ./$DEB && rm $DEB
}

function clonepull() {
  # clone, and pull if already cloned from url $1 into dir
  DIR=$HOME/.local/src/$(basename $1 .git)
  [ ! -d "$DIR/.git" ] && \
    git clone --depth 1 "$1" "$DIR" || git -C "$DIR" pull origin master
}

#===============================================================================
# POST-INSTALL CONFIGS
#===============================================================================

function config() {
  bigprint "Runnung Miscellaneous Post-Package Installs and Configs"

  # default shell to zsh, set os-specific configs
  sudo chsh -s /bin/zsh $(whoami)
  config_$OS

  echo "OS Config Complete. Restart Required"
}

function config_ubuntu() {
  # Set computer name, disable desktop environment, clean installs
  hostnamectl set-hostname SkippersMPB
  sudo systemctl set-default multi-user.target
  sudo apt-get -y autoremove

  # configure ros
  sudo rosdep init && rosdep update
}

function config_osx() {
  # disable time machine and allow apps downloaded from anywhere
  sudo tmutil disable; sudo spctl --master-disable

  # Set computer name
  sudo scutil --set ComputerName  "SkippersMBP"
  sudo scutil --set HostName      "SkippersMBP"
  sudo scutil --set LocalHostName "SkippersMBP"
  dscacheutil -flushcache
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "SkippersMBP"

  # configure osx ui/ux
  $HOME/.config/aqua/defaults

  # set firefox at default browser
  /Applications/Firefox.app/Contents/MacOS/firefox -setDefaultBrowser -silent

  # configure yabai wm with scripting addition
  [ yabai --check-sa ] || sudo yabai --install-sa

  # set symlinks for zathura, minecraft, spotify preferences
  mkdir -p $(brew --prefix zathura)/lib/zathura
  ln -sf $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib
  ln -sf "$HOME/.config/minecraft/options.txt" "$HOME/Library/ApplicationSupport/Minecraft/options.txt"
  ln -sf "$HOME/.local/share/spotify/prefs"    "$HOME/Library/ApplicationSupport/Spotify/prefs"

  # configure xdg shell completion
  $(brew --prefix)/opt/fzf/install --xdg
}

#===============================================================================
# MISCELLANEOUS
#===============================================================================

function quartus_install() {
  # 32-bit architechture for modelsim
  sudo dpkg --add-architecture i386

  ADIR="$HOME/.local/share/altera"

  # Unzip tar
  mkdir -p $ADIR/Install
  tar -C $ADIR/Install -xvf $ADIR/Quartus-web-15.0.0.145-linux.tar

  # install software
  sudo $ADIR/Install/setup.sh --mode unattended \
    --unattendedmodeui minimalWithDialogs --installdir /opt/altera/15.0

  # set up permissions for usb blaster
  echo '# For Altera USB-Blaster permissions. \SUBSYSTEM=="usb",\
  ENV{DEVTYPE}=="usb_device",\ATTR{idVendor}=="09fb",\ATTR{idProduct}=="6001",\
  MODE="0666",\NAME="bus/usb/$env{BUSNUM}/$env{DEVNUM}",\
  RUN+="/bin/chmod 0666 %c"'| \
  sudo tee /etc/udev/rules.d/51-usbblaster.rules > /dev/null
}

function matlab_install() {
  # MATLAB INSTALLATION (EXPERIMENTAL)
  bigprint "Installing MATLAB"

  local version="R2019b"
  local DMGPATH="$XDG_DATA_HOME/matlab/matlab_${version}_maci64.dmg"
  local INSTPATH="/Volumes/matlab_${version}_maci64/InstallForMacOSX.app"

  function dmg_cleanup() {
    # remove dmg and installer on exit, failure, etc.
    local installer=$(basename $1); local mountname=$(dirname $1)
    pgrep "${installer%.*}"       && killall "${installer%.*}"
    [ -d  "/Volumes/$mountname" ] && diskutil unmount force "/Volumes/$mountname"
    rm -f "$2"
  }
  trap "dmg_cleanup $INSTPATH" "$DMGPATH" INT ERR TERM EXIT

  # unzip, mount, and run installer, waiting for installer to close
  unzip -d $(dirname $DMGPATH) "$DMGPATH.zip"
  hdiutil attach "$DMGPATH" -nobrowse
  open -W "/Volumes/matlab_${version}_maci64/InstallForMacOSX.app"

  # symlink tools
  sudo ln -sf /Applications/MATLAB_${version}.app/bin/matlab       /usr/local/bin/matlab
  sudo ln -sf /Applications/MATLAB_${version}.app/bin/maci64/mlint /usr/local/bin/mlint

  # undo traps
  trap - INT ERR TERM EXIT
  echo "MATLAB Install Complete."
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

function filter() { awk -F '"' '/^'"$1"'/{print $2}' Packages/$OS; }
