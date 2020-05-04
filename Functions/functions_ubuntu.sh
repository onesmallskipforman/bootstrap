# shell functions for configuring and installing various programs on Ubuntu

#===============================================================================
# SYSTEM PREP
#===============================================================================

function os_prep() {
  bigprint "Prepping OS"
  sudo apt-get install -y git curl gcc

  # install 32-bit architechture for modelsim
  sudo dpkg --add-architecture i386


  echo "OS Prep Complete."
}

function key_prep() {
  bigprint "Prepping Keys for Installations"

  # Prep Sublime
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

  # Prep VSCode
  # option 1 - need to test
  # wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
  # sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"

  # option 2
  # curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  # sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
  # sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'


  # option 3
  wget -qO - https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list


  # prep spotify
  # curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
  wget -qO - https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

  # prep ROS
  wget -qO - https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo apt-key add -
  echo "deb http://packages.ros.org/ros/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/ros-latest.list
}

#===============================================================================
# INSTALLATIONS
#===============================================================================

function pkg_install() {
  # Install Apt Package Repos and Packages
  bigprint "Installing Packages."
  sudo apt-get update -y && sudo apt-get dist-upgrade -y

  grep '^repo' "$HOME/.config/packages/aptfile"  \
    | sed 's/^[^"]*"//; s/".*//' \
    | xargs -n1 sudo add-apt-repository -y
  sudo apt-get update -y && sudo apt-get dist-upgrade -y

  grep '^apt' "$HOME/.config/packages/aptfile" \
    | sed 's/^[^"]*"//; s/".*//' \
    | xargs sudo apt-get -y -o Dpkg::Options::=--force-confdef install
  sudo apt-get update -y --fix-missing && sudo apt-get dist-upgrade -y && sudo apt-get -y autoremove
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

#===============================================================================
# APP CONFIGS/SETUPS
#===============================================================================

function os_config() {
  sudo chsh -s /bin/zsh
  hostnamectl set-hostname SkippersMPB
  feh --bg-fill ~/.local/share/wallpapers/beams.jpeg
}

function ros_config() {
  sudo rosdep init
  rosdep update
}

# function wm_config() {
#   cd $HOME/.local/src/xcb-util-xrm
#   ./autogen.sh
#   make
#   sudo make install
#   sudo ldconfig
#   sudo ldconfig -p

#   cd $HOME/.local/src/i3
#   autoreconf --force --install
#   mkdir build
#   cd build/
#   ../configure --prefix=/usr --sysconfdir=/etc
#   make
#   sudo make install
# }
