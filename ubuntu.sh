source library.sh

#===============================================================================
# SYSTEM PREPS
#===============================================================================

function prep(){
  which sudo || { apt -y update && apt install -y "sudo"; }
  sudo apt -y update --fix-missing && sudo apt -y dist-upgrade
  sudo dpkg --add-architecture i386
  # sudo apt install -y git gcc software-properties-common
}

#===============================================================================
# POST-INSTALL CONFIGS
#===============================================================================

function config() {
  # Set computer name, disable desktop environment, clean installs
  # hostnamectl set-hostname Skipper #TODO: make this more interesting or device-specific
  sudo systemctl set-default multi-user.target
  sudo apt -y autoremove
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
  ain "libc6:i386" "libncurses5:i386" "libstdc++6:i386" "libxext6:i386" "libxft2:i386" # dependencies

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


function alacritty_install() {
  ghb "alacritty/alacritty" ~/.local/src/alacritty

  ain cargo cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3

  cd ~/.local/src/alacritty
  cargo build --release
  # cargo build --release --no-default-features --features=x11

  # ghb "aaron-williamson/base16-alacritty"
  ghb 'alacritty/alacritty-theme'
  ln -sf ~/.local/src/alacritty-theme/themes ~/.config/alacritty/themes
}

function picom_install() { # PICOM
  ain libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libpcre2-dev \
      libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev        \
      libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev   \
      libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev                 \
      libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev               \
      libxcb-xfixes0-dev libxext-dev meson ninja-build uthash-dev

  # TODO: alternatively use tar
  ghb "yshui/picom.git" ~/.local/src/picom
  meson setup --buildtype=release ~/.local/src/picom/build ~/.local/src/picom
  sudo ninja -C ~/.local/src/picom/build install
}

function packages()
{

  #############################################################################
  # LAYER 1: Command-Line Fundamentals
  #############################################################################

  sudo apt update && sudo apt upgrade
  sudo DEBIAN_FRONTEND=noninteractive
  DEBIAN_FRONTEND=noninteractive
  # https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive

  # TODO: specify python version for pip install function
  # TODO: check if tzdata is needed for /etc/timezone to be correct with noninteractive
  ain "tzdata"
  ain "software-properties-common" # essentials (ie apt-add-repository)
  ain "zsh" "zsh-syntax-highlighting" "zsh-autosuggestions"; sudo chsh -s /bin/zsh $(whoami)
  ppa "ppa:git-core/ppa" && ain "git"
  ain "python3" "python3-pip" "python3-venv" && pin "pip" \
    && ppa "ppa:deadsnakes/ppa" && ain "python3.11" "python3.11-distutils" # TODO: make sure all (or selected) python versions' programs are on PATH
  wget -P /tmp https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh && {
    chmod +x /tmp/guix-install.sh && /tmp/guix-install.sh
    guix pull && guix package -u
  }
  ain "less"
  ain "systemd"
  ain "xorg"
  ain "gcc"
  ain "make"
  ain "cmake"
  ain "curl"
  ain "network-manager" # i think this has nmtui # TODO: need to address that you won't be able to use this script without wifi. maybe do some prep step
  ain "cifs-utils" # tool for mounding temp drives

  # Desktop Environment
  ain "brightnessctl" # brightness control
  ain "xdotool" # for grabbing window names (I use it to handle firefox keys)
  ain "xserver-xorg-core" # libinput dependency
  ain "xserver-xorg-input-libinput" # allows for sane trackpad expeirence
  ain "pulseaudio" "alsa-utils" # for audio controls # TODO: install pavucontrol+pulseaudio (figure out what commands you actually need)
  ain "arandr"
  ain "autorandr"
  ain "rofi" && ghb "newmanls/rofi-themes-collection"
  ain "bspwm" -p "ppa:drdeimosnn/survive-on-wm"
  ain "sxhkd" -p "ppa:drdeimosnn/survive-on-wm"
  ain "redshift"
  ain "polybar" -p "ppa:drdeimosnn/survive-on-wm"
  picom_install
  ndf "Hack" "DejaVuSansMono" "FiraCode" "RobotoMono" "SourceCodePro" "UbuntuMono" # TODO: reduce fonts

  # silly terminal scripts to show off
  ain "figlet" && ghb "xero/figlet-fonts" # For writing asciiart text # TODO: probably need to symlink the fonts somewhere
  ain "tty-clock" # terminal digial clock
  ppa "ppa:dawidd0811/neofetch" && ain "neofetch"
  ppa "ppa:ytvwld/asciiquarium" && ain "asciiquarium"
  deb 'https://github.com/fastfetch-cli/fastfetch/releases/download/2.5.0/fastfetch-2.5.0-Linux.deb' # TODO: consider grabbing latest instead of version
  ghb "dylanaraps/pfetch"   # minimal fetch # TODO: may need to check this shows up in path
  ghb "stark/Color-Scripts" # colorscripts  # TODO: may need to check this shows up in path

  # essential gui/advanced tui programs
  ain "firefox"
  ain "feh" "sxiv" # image viewer
  alacritty_install
  install_nvim && pin "pynvim" && ain "npm" # TODO: see if you can specify npm version
  ghb "junegunn/fzf" && ~/.local/src/fzf/install --all --xdg --completion && ain ripgrep # fuzzy finder
  ain "autojump"
  ain "htop"
  ain "openconnect"; addSudoers "/usr/bin/openconnect, /usr/bin/pkill"
  ain "texlive-latex-base" && texlive_configure; { # tex (full pkg: texlive-full)
    ain "ghostscript" # installs ps2pdf
    ain "enscript"    # converts textfile to postscript (use with ps2pdf)
    ain "inkscape" -p "ppa:inkscape.dev/stable" # for latex drawings
  }
  guix install nyxt

  # gaming
  ppa "multiverse" && ain "steam-installer" "steamcmd" # ain "steam" # TODO: not really sure what the difference is
  deb "https://launcher.mojang.com/download/Minecraft.deb"
  # ain "spotify-client"                                       \
  #     -p "deb http://repository.spotify.com stable non-free" \
  #     -k "http://download.spotify.com/debian/pubkey.gpg"
  # TODO: add discord

  # probably just school/work
  deb "https://zoom.us/client/latest/zoom_amd64.deb"
  ppa "deb http://packages.ros.org/ros/ubuntu bionic main" && {
  # ain "ros-melodic-desktop-full" #  -k "http://packages.ros.org/ros.key" \
    ain "ros-melodic-desktop-full"
    ain "python"
    ain "python-rosdep"
    ain "python-rosinstall"
    ain "python-rosinstall-generator"
    ain "python-wstool"
    ain "build-essential"
  }
  # quartus_install
  # TODO: add slack
}

bootstrap() {
    supersist
    bigprint "Prepping For Bootstrap"  ; prep
    bigprint "Copying dotfiles to home"; syncDots
    bigprint "Installing Packages"     ; packages
    bigprint "Configure OS"            ; config
    bigprint "OS Config Complete. Restart Required"
}
