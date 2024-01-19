source library.sh

#===============================================================================
# SYSTEM PREPS
#===============================================================================

function prep(){
  sudo apt -y update --fix-missing && sudo apt -y dist-upgrade
  sudo apt install -y git gcc software-properties-common
}

#===============================================================================
# POST-INSTALL CONFIGS
#===============================================================================

function config() {
  # default shell to zsh, set os-specific configs
  sudo chsh -s /bin/zsh $(whoami)

  # Set computer name, disable desktop environment, clean installs
  hostnamectl set-hostname Skipper
  sudo systemctl set-default multi-user.target
  sudo apt -y autoremove

  # add user to dialup group from serial coms, and video group for brightness management
  # TODO: move this next to the brightness tool you use
  usermod -aG video,dialup $(whoami)
}

function bootstrap() {
  bigprint "Prepping For Bootstrap" && prep && echo "OS Prep Complete."
  bigprint "Syncing dotfiles repo to home" && dotfiles
  bigprint "Syncing dotfiles repo to home" && packages
  bigprint "Runnung Miscellaneous Post-Package Installs and Configs" && config && echo "OS Config Complete. Restart Required"
}

#===============================================================================
# INSTALLATIONS
#===============================================================================

function quartus_install() {
  # 32-bit architechture for modelsim
  sudo dpkg --add-architecture i386
  apt "libc6:i386" "libncurses5:i386" "libstdc++6:i386" "libxext6:i386" "libxft2:i386" # dependencies

  wget 'https://cdrdv2.intel.com/v1/dl/getContent/666224/666242?filename=Quartus-web-13.1.0.162-linux.tar'

  local ADIR="$HOME/.local/share/altera"

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

function install_nvim() {
    LINK='https://github.com/neovim/neovim/releases/download/v0.9.4/nvim-linux64.tar.gz'
    SDIR=$HOME/.local/src
    MDIR=$HOME/.local/share/man
    BDIR=$HOME/.local/bin
    mkdir -p $SDIR $MDIR $BDIR

    wget -qO- $LINK | tar xzv -C $SDIR && {
        ln -sf $SDIR/nvim-linux64/bin/nvim $BDIR/nvim
        ln -sf $SDIR/nvim-linux64/man/man1/nvim.1 $MDIR/man1/nvim.1
    }
}

function packages()
{

  sudo apt update && sudo apt upgrade

  sudo DEBIAN_FRONTEND=noninteractive
  DEBIAN_FRONTEND=noninteractive

  # TODO: specify python version for pip install function
  # TODO: check if tzdata is needed for /etc/timezone to be correct with noninteractive
  apt "sudo"
  apt "tzdata"
  apt "software-properties-common" # basic stuff ie apt-add-repository command. may be needed for lightweight installs
  apt "less"
  apt "git" -p "ppa:git-core/ppa"
  apt "xorg"
  apt "network-manager"

  # TODO: see if you can specify npm version
  install_nvim && pin "pynvim" && apt "npm"

  # TODO: consider grabbing latest instead of version
  deb 'https://github.com/fastfetch-cli/fastfetch/releases/download/2.5.0/fastfetch-2.5.0-Linux.deb'

  # TODO: make sure all (or selected) python versions' programs are on PATH
  apt "python3" && apt "python3-pip" && pin "pip" # pip installs pip
      pin "pynvim" # python support for neovim
  apt "python3.11" -p "ppa:deadsnakes/ppa"
  apt "python3.11-distutils" -p "ppa:deadsnakes/ppa"

  # TODO: this will require more research
  # also this is installed as a dep of xorg
  apt "systemd"


  apt "alacritty" -p "ppa:mmstick76/alacritty"   \
      && ghb "aaron-williamson/base16-alacritty" \
      && ghb "eendroroy/alacritty-theme"
    # mkdir -p ~/.config/alacritty/themes
    # git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
  apt "asciiquarium" -p "ppa:ytvwld/asciiquarium"
  apt "autojump"
  apt "bspwm" -p "ppa:drdeimosnn/survive-on-wm"
  apt "cmake"
  apt "curl"
  apt "feh" # image viewer
  apt "figlet" && ghb "xero/figlet-fonts" # For writing asciiart text
  apt "gcc"
  apt "htop"
  apt "inkscape" -p "ppa:inkscape.dev/stable" # for latex drawings
  apt "make"
  apt "neofetch" -p "ppa:dawidd0811/neofetch"
  apt "neovim" -p "ppa:neovim-ppa/stable"
  apt "polybar" -p "ppa:drdeimosnn/survive-on-wm"
  apt "pulseaudio" "alsa-utils" # for audio controls
  apt "redshift" -p "ppa:dobey/redshift-daily"
  apt "ros-melodic-desktop-full" -p "deb http://packages.ros.org/ros/ubuntu bionic main" -k "http://packages.ros.org/ros.key" \
      && apt "python"                      \
      && apt "python-rosdep"               \
      && apt "python-rosinstall"           \
      && apt "python-rosinstall-generator" \
      && apt "python-wstool"               \
      && apt "build-essential"
  apt "spotify-client"                                       \
      -p "deb http://repository.spotify.com stable non-free" \
      -k "http://download.spotify.com/debian/pubkey.gpg"
  apt "sxhkd" -p "ppa:drdeimosnn/survive-on-wm"
  apt "sxiv"
  apt "texlive-latex-base" && texlive_configure # tex (full pkg: texlive-full)
    # sudo apt install perl-tk
  apt "tty-clock"
  apt "xbacklight" # brightness control
  apt "xdotool" # for grabbing window names (I use it to handle firefox keys)
  apt "xserver-xorg-core" # libinput dependency
  apt "xserver-xorg-input-libinput" # allows for sane trackpad expeirence
  apt "zsh" \
    && apt "zsh-syntax-highlighting" \
    && ghb "zsh-users/zsh-autosuggestions" \
    && sudo chsh -s /bin/zsh $(whoami)
  ghb "dylanaraps/pfetch"   # minimal fetch
  ghb "junegunn/fzf" && ~/.local/src/fzf/install --all --xdg --completion # fuzzy finder
  ghb "stark/Color-Scripts" # colorscripts
  ndf "DejaVuSansMono"
  ndf "FiraCode"
  ndf "Hack"
  ndf "RobotoMono"
  ndf "SourceCodePro"
  ndf "UbuntuMono"
  deb "https://github.com/haikarainen/light/releases/download/v1.2/light_1.2_amd64.deb"
  deb "https://launcher.mojang.com/download/Minecraft.deb"
  quartus_install
}

bootstrap() {
    supersist
    bigprint "Prepping For Bootstrap"  ; prep
    bigprint "Copying dotfiles to home"; syncDots
    bigprint "Installing Packages"     ; packages
    bigprint "Configure OS"            ; config
    bigprint "OS Config Complete. Restart Required"
}
