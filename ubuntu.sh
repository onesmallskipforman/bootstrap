source library.sh

#===============================================================================
# SYSTEM PREPS
#===============================================================================

function prep(){
  sudo apt -y update --fix-missing && sudo apt -y dist-upgrade
  sudo dpkg --add-architecture i386
  # sudo apt install -y git gcc software-properties-common
}

#===============================================================================
# POST-INSTALL CONFIGS
#===============================================================================

function config() {
  # default shell to zsh, set os-specific configs
  sudo chsh -s /bin/zsh $(whoami)

  # Set computer name, disable desktop environment, clean installs
  # hostnamectl set-hostname Skipper #TODO: make this more interesting or device-specific
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

  #############################################################################
  # LAYER 1: Command-Line Fundamentals
  #############################################################################

  sudo apt update && sudo apt upgrade
  sudo DEBIAN_FRONTEND=noninteractive
  DEBIAN_FRONTEND=noninteractive
  # https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive

  # TODO: add some 'layer 1 install group and make sure it includes a font'
  # TODO: specify python version for pip install function
  # TODO: check if tzdata is needed for /etc/timezone to be correct with noninteractive
  which sudo || apt install "sudo"
  apti "tzdata"
  apti "software-properties-common" # basic stuff ie apt-add-repository command. may be needed for lightweight installs
  apti "less"
  apti "git" -p "ppa:git-core/ppa"
  apti "xorg"
  apti "gcc"
  apti "network-manager" # i think this has nmtui
  {
    apti "zsh"
    apti "zsh-syntax-highlighting"
    ghb "zsh-users/zsh-autosuggestions"
    sudo chsh -s /bin/zsh $(whoami)
  }


  # TODO: install pavucontrol+pulseaudio (figure out what commands you actually need)


  {
      ndf "DejaVuSansMono"
      ndf "FiraCode"
      ndf "Hack"
      ndf "RobotoMono"
      ndf "SourceCodePro"
      ndf "UbuntuMono"
  }

  deb "https://zoom.us/client/latest/zoom_amd64.deb"

  { #STEAM

    ppa multiverse
    apti steam # TODO: not really sure what the difference is
    # apti steam-installer
    apti steamcmd
  }


  { # PICOM
    apti libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libpcre2-dev \
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

  apti arandr
  apti autorandr
  apti rofi && ghb "newmanls/rofi-themes-collection"

  apti "bspwm" -p "ppa:drdeimosnn/survive-on-wm"
  apti "sxhkd" -p "ppa:drdeimosnn/survive-on-wm"
  apti "cmake"
  apti "make"
  apti "curl"
  apti "feh" # image viewer
  apti "figlet" && ghb "xero/figlet-fonts" # For writing asciiart text
  apti "gcc"
  apti "htop"
  apti "neofetch" -p "ppa:dawidd0811/neofetch"
  apti "pulseaudio" "alsa-utils" # for audio controls

  apti "cifs-utils" # tool for mounding temp drives

  apti "tty-clock"
  apti "brightnessctl" # brightness control
  apti "xdotool" # for grabbing window names (I use it to handle firefox keys)
  apti "xserver-xorg-core" # libinput dependency
  apti "xserver-xorg-input-libinput" # allows for sane trackpad expeirence


  # TODO: make sure all (or selected) python versions' programs are on PATH
  apti "python3" && apt "python3-pip" && pin "pip" # pip installs pip
      pin "pynvim" # python support for neovim
  apti "python3.11" -p "ppa:deadsnakes/ppa"
  apti "python3.11-distutils" -p "ppa:deadsnakes/ppa"



  #############################################################################
  # LAYER 2: Key Programs
  #############################################################################

  # apti "alacritty" -p "ppa:mmstick76/alacritty"   \
  #     && ghb "aaron-williamson/base16-alacritty" \
  #     && ghb "eendroroy/alacritty-theme"
  #   # mkdir -p ~/.config/alacritty/themes
  #   # git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes

  {
    ghb "alacritty/alacritty.git" ~/.local/src/alacritty

    apti cargo cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3

    cd ~/.local/src/alacritty
    cargo install alacritty
    # cargo build --release
    # cargo build --release --no-default-features --features=x11
    sudo ninja -C ~/.local/src/picom/build install
  }




  apti "firefox"

  apti "polybar" -p "ppa:drdeimosnn/survive-on-wm"
  apti "redshift" -p "ppa:dobey/redshift-daily"


  # TODO: see if you can specify npm version
  install_nvim && pin "pynvim" && apti "npm"

  ghb "junegunn/fzf" && ~/.local/src/fzf/install --all --xdg --completion && apti ripgrep # fuzzy finder


  # TODO: consider grabbing latest instead of version
  deb 'https://github.com/fastfetch-cli/fastfetch/releases/download/2.5.0/fastfetch-2.5.0-Linux.deb'



  #############################################################################
  # LAYER 3: Extra
  #############################################################################

  # { # GUIX
  #   cd /tmp
  #   wget https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh
  #   chmod +x guix-install.sh
  #   ./guix-install.sh
  #   guix pull
  #
  #   guix install nyxt
  # }


  # # TODO: this will require more research
  # # also this is installed as a dep of xorg
  # apti "systemd"

  { # VPN
    apti "openconnect"
    sudo echo "$(whoami) ALL=(root) NOPASSWD: /usr/bin/openconnect, /usr/bin/pkill" | sudo tee /etc/sudoers.d/$(whoami)
  }

  # apti "asciiquarium" -p "ppa:ytvwld/asciiquarium"
  # apti "autojump"
  # apti "ros-melodic-desktop-full" -p "deb http://packages.ros.org/ros/ubuntu bionic main" -k "http://packages.ros.org/ros.key" \
  #     && apti "python"                      \
  #     && apti "python-rosdep"               \
  #     && apti "python-rosinstall"           \
  #     && apti "python-rosinstall-generator" \
  #     && apti "python-wstool"               \
  #     && apti "build-essential"
  # apti "spotify-client"                                       \
  #     -p "deb http://repository.spotify.com stable non-free" \
  #     -k "http://download.spotify.com/debian/pubkey.gpg"
  # apti "sxiv"
  # {
  #     apti "texlive-latex-base" && texlive_configure # tex (full pkg: texlive-full)
  #     apti "inkscape" -p "ppa:inkscape.dev/stable" # for latex drawings
  #     # sudo apti install perl-tk # for tlmgr gui
  #     apti "ghostscript" # installs ps2pdf
  #     apti "enscript" # converts textfile to postscript (use with ps2pdf)
  # }




  # ghb "dylanaraps/pfetch"   # minimal fetch
  # ghb "stark/Color-Scripts" # colorscripts

  # deb "https://launcher.mojang.com/download/Minecraft.deb"
  # quartus_install
}

bootstrap() {
    supersist
    bigprint "Prepping For Bootstrap"  ; prep
    bigprint "Copying dotfiles to home"; syncDots
    bigprint "Installing Packages"     ; packages
    bigprint "Configure OS"            ; config
    bigprint "OS Config Complete. Restart Required"
}
