source library.sh

#===============================================================================
# SYSTEM PREPS
#===============================================================================

function prep(){
  sudo apt -y update --fix-missing && sudo apt -y dist-upgrade
  sudo apt install -y git gcc
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

function packages()
{
  apt "alacritty"    -p "ppa:mmstick76/alacritty" && ghb "aaron-williamson/base16-alacritty" "eendroroy/alacritty-theme" && pip "alacritty-colorscheme"
  apt "alsa-utils"                                               # for audio controls
  apt "asciiquarium" -p "ppa:ytvwld/asciiquarium"
  apt "autojump"                                                 #
  apt "bspwm"        -p "ppa:drdeimosnn/survive-on-wm"
  apt "cmake"                                                    #
  apt "curl"                                                     #
  apt "feh"                                                      # image viewer
  apt "figlet" && ghb "xero/figlet-fonts"               # For writing asciiart text
  apt "gcc"                                                      #
  apt "git"          -p "ppa:git-core/ppa"
  apt "htop"                                                     #
  apt "inkscape"     -p "ppa:inkscape.dev/stable"                # for latex drawings
  apt "make"                                                     #
  apt "neofetch"     -p "ppa:dawidd0811/neofetch"
  apt "neovim"       -p "ppa:neovim-ppa/stable"
  apt "polybar"      -p "ppa:drdeimosnn/survive-on-wm"
  apt "pulseaudio"                                               # for audio controls
  apt "python3"      -p "ppa:deadsnakes/ppa" && apt "python3-pip"  -p "ppa:deadsnakes/ppa"
  apt "python3-pip"  -p "ppa:deadsnakes/ppa"
  apt "redshift"     -p "ppa:dobey/redshift-daily"
  apt "ros-melodic-desktop-full" -p "deb http://packages.ros.org/ros/ubuntu bionic main" \
      && apt "python"                      \
      && apt "python-rosdep"               \
      && apt "python-rosinstall"           \
      && apt "python-rosinstall-generator" \
      && apt "python-wstool"               \
      && apt "build-essential"
  apt "software-properties-common"                               # basic stuff ie apt-add-repository command. may be needed for lightweight installs
  apt "spotify-client" -p "deb http://repository.spotify.com stable non-free" -k "http://packages.ros.org/ros.key"
  apt "spotify-client" -k "http://packages.ros.org/ros.key" -p "deb http://repository.spotify.com stable non-free"
  apt "sxhkd"        -p "ppa:drdeimosnn/survive-on-wm"
  apt "sxiv"                                                     #
  apt "tty-clock"                                                #
  apt "xbacklight"                                               # brightness control
  apt "xdotool"                                                  # for grabbing window names (I use it to handle firefox keys)
  apt "xserver-xorg-core"                                        # libinput dependency
  apt "xserver-xorg-input-libinput"                              # allows for sane trackpad expeirence
  apt "zsh" \
    && apt "zsh-syntax-highlighting" \
    && ghb "zsh-users/zsh-autosuggestions" \
    && sudo chsh -s /bin/zsh $(whoami)

  ghb "dylanaraps/pfetch"   # minimal fetch
  ghb "junegunn/fzf"        # fuzzy finder
  ghb "stark/Color-Scripts" # colorscripts

  pip "autopep8"       # python style formatter
  pip "flake8"         # python linter
  pip "pip"            # installs pip
  pip "pycodestyle"    # python style linter, requred by autopep8
  pip "pylint"         # python linter
  pip "pynvim"         # python support for neovim

  ndf "DejaVuSansMono" # nerd font
  ndf "FiraCode"       # nerd font
  ndf "Hack"           # nerd font
  ndf "RobotoMono"     # nerd font
  ndf "SourceCodePro"  # nerd font
  ndf "UbuntuMono"     # nerd font

  deb "https://github.com/haikarainen/light/releases/download/v1.2/light_1.2_amd64.deb"
  deb "https://launcher.mojang.com/download/Minecraft.deb"

  quartus_install
}


# only put deps in functions that aren't used anywhere else. addons can be separate i think
# TODO: idea -> -c flag to add comment about what is getting installed. if nothing, just print package name
# TODO: figure out how to combine mulitple packages into one call
# IDEA: while getopts '' OPTARG is false ... do stuff with args
# TODO: idea -> add generic dependency flag -d where you can pass a command like sudo dpkg
