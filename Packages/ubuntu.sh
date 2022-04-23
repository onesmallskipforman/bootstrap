# only put deps in functions that aren't used anywhere else. addons can be separate i think

# idea: apt --ppa <repo> --key <key>
ppa "ppa:ytvwld/asciiquarium"      && apt "asciiquarium"
ppa "ppa:drdeimosnn/survive-on-wm" && apt "bspwm" "sxhkd" "polybar" # for bspwm, sxhkd, polybar
ppa "ppa:git-core/ppa"             && apt "git"
ppa "ppa:inkscape.dev/stable"      && apt "inkscape"                # for latex drawings
ppa "ppa:dawidd0811/neofetch"      && apt "neofetch"
ppa "ppa:neovim-ppa/stable"        && apt "neovim"
ppa "ppa:deadsnakes/ppa"           && apt "python3" "python3-pip"   # pip and python (both 3.6)
ppa "ppa:dobey/redshift-daily"     && apt "redshift"

apt "alsa-utils"                                               # for audio controls
apt "autojump"                                                 #
apt "cmake"                                                    #
apt "curl"                                                     #
apt "feh"                                                      # image viewer
apt "figlet" && git "https://github.com/xero/figlet-fonts.git" # For writing asciiart text
apt "gcc"                                                      #
apt "htop"                                                     #
apt "make"                                                     #
apt "pulseaudio"                                               # for audio controls
apt "software-properties-common"                               # basic stuff ie apt-add-repository command. may be needed for lightweight installs
apt "sxiv"                                                     #
apt "tty-clock"                                                #
apt "xbacklight"                                               # brightness control
apt "xdotool"                                                  # for grabbing window names (I use it to handle firefox keys)
apt "xserver-xorg-core"                                        # libinput dependency
apt "xserver-xorg-input-libinput"                              # allows for sane trackpad expeirence
apt "zsh"                                                      #
apt "zsh-syntax-highlighting"                                  #

git "https://github.com/zsh-users/zsh-autosuggestions.git"     # zsh autosuggestions
git "https://github.com/dylanaraps/pfetch.git"                 # minimal fetch
git "https://github.com/junegunn/fzf.git"                      # fuzzy finder
git "https://github.com/stark/Color-Scripts.git"               # colorscripts

pip "autopep8"                                                 # python style formatter
pip "flake8"                                                   # python linter
pip "pip"                                                      # installs pip
pip "pycodestyle"                                              # python style linter, requred by autopep8
pip "pylint"                                                   # python linter
pip "pynvim"                                                   # python support for neovim

ndf "DejaVuSansMono"                                           # nerd font
ndf "FiraCode"                                                 # nerd font
ndf "Hack"                                                     # nerd font
ndf "RobotoMono"                                               # nerd font
ndf "SourceCodePro"                                            # nerd font
ndf "UbuntuMono"                                               # nerd font

deb "https://github.com/haikarainen/light/releases/download/v1.2/light_1.2_amd64.deb"
deb "https://launcher.mojang.com/download/Minecraft.deb"

function ros_install() {
  key "http://packages.ros.org/ros.key"
  ppa "deb http://packages.ros.org/ros/ubuntu bionic main"
  apt "python" # python 2.7 (needed for ROS)
  apt "ros-melodic-desktop-full"

  apt "python-rosdep" "python-rosinstall" "python-rosinstall-generator" "python-wstool" "build-essential"
  sudo rosdep init && rosfunny orangutandep update
}; ros_install

function spotify_install() {
  key "http://download.spotify.com/debian/pubkey.gpg"
  ppa "deb http://repository.spotify.com stable non-free"
  apt "spotify-client"
}; spotify_install

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
}; quartus_install

function alacritty_install() {
  ppa "ppa:mmstick76/alacritty" && apt "alacritty"

  # addons
  git "https://github.com/aaron-williamson/base16-alacritty.git"
  git "https://github.com/eendroroy/alacritty-theme.git"
  pip "alacritty-colorscheme" # alacritty color changer
}; alacritty_install
