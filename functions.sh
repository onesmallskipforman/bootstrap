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

  # bootstrap scripts and configs
  bigprint "Syncing dotfiles repo to home"
  GHUB="https://github.com/onesmallskipforman"
  clonepull "$GHUB/bootstrap.git" "$1"

  # dotfile boostrap
  mkdir -p "Home"
  mv -n "$HOME"/{.config,.local,.zshenv} "$1/Home" &>/dev/null
  gitstrap "$GHUB/dotfiles.git"  "$1/Home"
  gitstrap "$GHUB/userdata.git"  "$1/Home/.local/share"

  # symlink
  ln -sf "$1/Home"/{.config,.local,.zshenv} "$HOME"
}

function prep(){
  bigprint "Prepping For Bootstrap"
  prep_$OS
  echo "OS Prep Complete."
}

function prep_osx() {
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

function prep_ubuntu() {
  sudo apt-get install -y git gcc

  # 32-bit architechture for modelsim
  sudo dpkg --add-architecture i386
}

#===============================================================================
# INSTALLATIONS
#===============================================================================

function pkg_install() {
  pkg_install_$OS
  pip_install
  cargo_install
  goget_install
  git_install
}

function pip_install() {
  bigprint "Installing Pip Packages"
  pip3 install -r "Packages/requirements.txt"

  which pip3 &>/dev/null || (
    curl https://bootstrap.pypa.io/get-pip.py | python3
    # wget -qO - https://bootstrap.pypa.io/get-pip.py | python3
    # python3 -m pip uninstall pip
  )

  echo "Pip Installation Complete."
}

function cargo_install() {
  bigprint "Installing Cargo Packages"
  which rustup &>/dev/null || (
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    rustup override set stable
  )
  rustup update stable
  source $HOME/.cargo/env
  cat "Packages/cargo_$OS.txt" | xargs -n1 cargo install --git
}

function goget_install() {
  bigprint "Installing Go Packages"
  which go &>/dev/null || (
    wget -qO - https://dl.google.com/go/go1.11.linux-amd64.tar.gz | tar -C /usr/local -xzf -
  )
  cat "Packages/go_$OS.txt" | xargs -n1
}

function git_install() {
  bigprint "Cloning Git Repos"
  while IFS= read URL; do
    DIR=$HOME/.local/src/$(basename "$URL" .git)
    clonepull "$URL" "$DIR"
  done < "Packages/repos_$OS.txt"
  echo "Repo Cloning Complete."
}

function pkg_install_ubuntu() {
  # Install Apt Package Repos and Packages
  bigprint "Installing Packages."
  sudo apt-get update -y && sudo apt-get dist-upgrade -y

  # import keys
  grep '^key' "Packages/aptfile"  \
    | sed 's/^[^"]*"//; s/".*//' \
    | while read key; do wget -qO - $key | sudo apt-key add -; done
  sudo apt-get update -y && sudo apt-get dist-upgrade -y

  # add repos
  grep '^repo' "Packages/aptfile"  \
    | sed 's/^[^"]*"//; s/".*//' \
    | xargs -n1 -I{} sudo add-apt-repository -y "{}"
  sudo apt-get update -y && sudo apt-get dist-upgrade -y

  # install apt packages
  grep '^apt' "Packages/aptfile" \
    | sed 's/^[^"]*"//; s/".*//' \
    | xargs sudo apt-get -y -o Dpkg::Options::=--force-confdef install
  sudo apt-get update -y --fix-missing && sudo apt-get dist-upgrade -y && sudo apt-get -y autoremove

  # # alternative for deb files
  # grep '^deb' "Packages/aptfile"  \
  #   | while IFS=, read url list; do
  #       url=$(sed 's/^[^"]*"//; s/".*//' <<< $url)
  #       list=$(sed 's/^[^"]*"//; s/".*//' <<< $list)
  #       echo "deb $url" | sudo tee /etc/apt/sources.list.d/$list
  #     done
  # sudo apt-get update -y && sudo apt-get dist-upgrade -y

}

function pkg_install_osx() {
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

#===============================================================================
# POST-INSTALL CONFIGS
#===============================================================================

function config() {
  bigprint "Runnung Post-Install Configs"

  # default shell to zsh
  sudo chsh -s /bin/zsh

  # os-specific configs
  config_$OS

  echo "OS Config Complete. Restart Required"
}

function config_ubuntu() {
  # Set computer name
  hostnamectl set-hostname SkippersMPB
}

function config_osx() {
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

  echo "OS Config Complete. Restart Required"
}

#===============================================================================
# MISCELLANEOUS
#===============================================================================

function misc() {
  bigprint "Running Miscellaneous Installs and Configs"
  misc_$OS
  echo "Misc. operations complete."
}

function misc_ubuntu() {
  quartus_install
  light_install
  ros_config
  ~/.local/src/nerd-fonts/install.sh Hack
}

function misc_osx() {
  # math_install
  mkdir -p $(brew --prefix zathura)/lib/zathura
  ln -sf $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib
  ln -sf "$HOME/.config/minecraft/options.txt" "$HOME/Library/ApplicationSupport/Minecraft/options.txt"
  ln -sf "$HOME/.local/share/spotify/prefs"    "$HOME/Library/ApplicationSupport/Spotify/prefs"
  ln -sfn "$HOME/.config/Code/User"            "$HOME/Library/ApplicationSupport/Code/User"
}

function quartus_install() {
  ADIR="$HOME/.local/share/altera"

  # Unzip tar
  mkdir -p $ADIR/Install
  tar -C $ADIR/Install -xvf $ADIR/Quartus-web-15.0.0.145-linux.tar

  # install software
  sudo $ADIR/Install/setup.sh \
    --mode unattended \
    --unattendedmodeui minimalWithDialogs \
    --installdir /opt/altera/15.0

  # set up permissions for usb blaster
  echo '# For Altera USB-Blaster permissions. \
  SUBSYSTEM=="usb",\
  ENV{DEVTYPE}=="usb_device",\ATTR{idVendor}=="09fb",\ATTR{idProduct}=="6001",\MODE="0666",\NAME="bus/usb/$env{BUSNUM}/$env{DEVNUM}",\RUN+="/bin/chmod 0666 %c"'| sudo tee /etc/udev/rules.d/51-usbblaster.rules > /dev/null
}

function light_install() {
  wget -qO - https://github.com/haikarainen/light/releases/download/v1.2/light-1.2.tar.gz | tar -C $HOME/.local/src -xzf -
  cd $HOME/.local/src/light*
  ./configure && make
  sudo make install
  cd ~-
}

function ros_config() {
  sudo rosdep init
  rosdep update
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

function clonepull() {
  # clone, and pull if already cloned from url $1 into dir $2
  [ ! -d "$2/.git" ] && git clone --depth 1 "$1" "$2" || git -C "$2" pull origin master
}
