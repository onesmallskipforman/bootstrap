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

  local HN="wb-sgonzalez"
  # hostnamectl set-hostname $HN
  grep -q "127.0.0.1\s$(hostname)" /etc/hosts || echo "127.0.0.1 $(hostname)" /etc/hosts

  # NOTE: you need systemd for these
  # sudo systemctl enable multi-user.target --force
  # sudo systemctl set-default multi-user.target
  sudo systemctl set-default multi-user.target
  sudo apt -y autoremove
}

function bootstrap() {
  bigprint "Prepping For Bootstrap" && prep && echo "OS Prep Complete."
  bigprint "Syncing dotfiles repo to home" && dotfiles
  bigprint "Syncing dotfiles repo to home" && packages
  bigprint "Runnung Miscellaneous Post-Package Installs and Configs" && config && echo "OS Config Complete. Restart Required"
}

# TODO: move this to personal scripts or aliases or rc file
function launchRl() {
  # This finds all ids-name pairs
  # find ~/.steam/steam/steamapps/ -maxdepth 1 -type f -name '*.acf' -exec awk -F '"' '/"appid/{ appid=$4 } /name/{ name=$4 }; END { print appid" "name }' {} \;

  # get rocket league id
  RLID=$(find ~/.steam/steam/steamapps/ -maxdepth 1 -type f -name '*.acf' -exec awk -F '"' '/"appid/{ appid=$4 } /name/{ name=$4 }; END { if (name == "Rocket League") print appid }' {} \;)

  # launch RL
  steam steam://rungameid/$RLID
  # steam steam://rungameid/252950

  # TODO: hmm looks like these id are static so as long as you have it saved
  # in a file you don't need to search for it

  # install RL
  steamcmd +login +quit
  steamcmd +app_update $RLID validate +quit
}

function install_steam() {
  ppa "multiverse" && ain "steam-installer" "steamcmd" # NOTE: steam-installer is 64bit version

  # TODO: modify configs automatically
  # I wonder if i can throw paths within these files into steamcmd hmmmmmmmmmm
  # compatibility  settings found in $HOME/.steam/debian-installation/config/config.vdf
  # launch opotion settings found in $HOME/.steam/debian-installation/userdata/276429030/config/localconfig.vdf

  # bakkesmod for rocket league
  wget -qP /tmp 'https://github.com/bakkesmodorg/BakkesModInjectorCpp/releases/download/2.0.34/BakkesModSetup.exe' # alternatively 'https://github.com/bakkesmodorg/BakkesModInjectorCpp/releases/latest/download/BakkesModSetup.zip'
  unzip -od /tmp /tmp/BakkesModSetup.zip
  COMPATDATA="$HOME/.steam/debian-installation/steamapps/compatdata/252950/pfx"
  PROTON="$HOME/.steam/debian-installation/steamapps/common/Proton 7.0/dist"
  WINEESYNC=1 WINEPREFIX="$COMPATDATA" "$PROTON"/bin/wine64 /tmp/BakkesModSetup.exe
}

#===============================================================================
# INSTALLATIONS
#===============================================================================

function install_quartus() {
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

function install_alacritty() {
  ghb "alacritty/alacritty"

  ain cargo cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3

  cd ~/.local/src/alacritty
  cargo build --release
  # cargo build --release --no-default-features --features=x11

  # ghb "aaron-williamson/base16-alacritty"
  ghb 'alacritty/alacritty-theme'
  ln -sf ~/.local/src/alacritty-theme/themes ~/.config/alacritty/themes
}

function install_picom() { # PICOM
  ain libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libpcre2-dev \
      libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev        \
      libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev   \
      libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev                 \
      libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev               \
      libxcb-xfixes0-dev libxext-dev meson ninja-build uthash-dev

  # TODO: alternatively use tar
  ghb "yshui/picom"
  meson setup --buildtype=release ~/.local/src/picom/build ~/.local/src/picom
  sudo ninja -C ~/.local/src/picom/build install
}

function install_python3() {
  ain "python3" "python3-pip" "python3-venv" && pin "pip"
  ppa "ppa:deadsnakes/ppa" && ain "python3.11" "python3.11-distutils" # TODO: make sure all (or selected) python versions' programs are on PATH
}

function install_guix() {
  wget -qP /tmp https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh
  chmod +x /tmp/guix-install.sh && /tmp/guix-install.sh
  guix pull && guix package -u
}

function install_tex() {
  ain "texlive-latex-base" && texlive_configure # tex (full pkg: texlive-full)
  ain "ghostscript" # installs ps2pdf
  ain "enscript"    # converts textfile to postscript (use with ps2pdf)
  ppa "ppa:inkscape.dev/stable" && ain "inkscape" # for latex drawings
}

function install_ros() {
  ppa "deb http://packages.ros.org/ros/ubuntu bionic main"
  # TODO: fix key add  -k "http://packages.ros.org/ros.key"
  ain "ros-melodic-desktop-full"
  ain "python"
  ain "python-rosdep"
  ain "python-rosinstall"
  ain "python-rosinstall-generator"
  ain "python-wstool"
  ain "build-essential"
}

# TODO: use this for osx install as well
function install_node20() {
  apt "npm"
  sudo npm install -g n
  sudo n v20.11.0 # sudo n stable
}

function install_extension() {
  local URL=$1
  local DIR=$(mktemp -d)
  local XPI=$DIR/tmp.xpi
  wget -qO $XPI $URL
  local NAME=$(unzip -p $XPI | grep -a '"id":' | sed -r 's/"|,| //g;s/id://g' 2>/dev/null).xpi
  cp $XPI ~/.mozilla/firefox/b7jmddu3.default-release/extensions/$NAME
  # sudo cp dr.xpi /usr/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/$NAME
  rm -r $DIR
}

function packages()
{
  # basics
  sudo apt update && sudo apt upgrade
  sudo DEBIAN_FRONTEND=noninteractive
  DEBIAN_FRONTEND=noninteractive # https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive
  ain "tzdata" # TODO: check if tzdata is needed for /etc/timezone to be correct with noninteractive
  ain "software-properties-common" # essentials (ie apt-add-repository)
  ain "zsh" "zsh-syntax-highlighting" "zsh-autosuggestions" && sudo chsh -s /bin/zsh $(whoami) # ghb "zsh-users/zsh-autosuggestions" # TODO: consider getting both of these straight from github
  ppa "ppa:git-core/ppa" && ain "git"
  fcn "python3"
  fcn "guix"
  ain "less"
  ain "systemd"
  ain "xorg"
  ain "gcc"
  ain "make"
  ain "cmake"
  ain "curl"
  ain "network-manager" # i think this has nmtui # TODO: need to address that you won't be able to use this script without wifi. maybe do some prep step
  ain "cifs-utils" # tool for mounding temp drives
  ain "jq"

  # Desktop Environment
  ain "brightnessctl" # brightness control
  ain "xdotool" # for grabbing window names (I use it to handle firefox keys)
  ain "xserver-xorg-core" # libinput dependency
  ain "xserver-xorg-input-libinput" # allows for sane trackpad expeirence
  ain "pulseaudio" "alsa-utils" "pavucontrol" # for audio controls # TODO: install pavucontrol+pulseaudio (figure out what commands you actually need)
  ain "arandr" # for saving and loading monitor layouts
  ain "autorandr" # gui for managing monitor layouts
  ain "rofi"; ghb "newmanls/rofi-themes-collection"
  ppa "ppa:drdeimosnn/survive-on-wm" && ain "bspwm" "sxhkd" "polybar"
  ain "redshift"
  fcn "picom"
  ndf "Hack" "DejaVuSansMono" "FiraCode" "RobotoMono" "SourceCodePro" "UbuntuMono" # TODO: reduce fonts

  # silly terminal scripts to show off
  ain "figlet"; ghb "xero/figlet-fonts" # For writing asciiart text
  ain "tty-clock" # terminal digial clock
  ppa "ppa:dawidd0811/neofetch" && ain "neofetch"
  ppa "ppa:ytvwld/asciiquarium" && ain "asciiquarium"
  deb 'https://github.com/fastfetch-cli/fastfetch/releases/download/2.5.0/fastfetch-2.5.0-Linux.deb' # TODO: consider grabbing latest instead of version
  ghb "dylanaraps/pfetch"   # minimal fetch # TODO: may need to check this shows up in path
  ghb "stark/Color-Scripts" # colorscripts  # TODO: may need to check this shows up in path

  # essential gui/advanced tui programs
  ain "firefox"
  ain "feh" "sxiv" # image viewer
  fcn "alacritty"
  fcn "nvim" && pin "pynvim" && fcn "node20" && ain "xsel" "calc"
  ghb "junegunn/fzf" && ~/.local/src/fzf/install --all --xdg --completion && ain ripgrep # fuzzy finder
  ain "autojump"
  ain "htop"
  ain "openconnect"; addSudoers "/usr/bin/openconnect, /usr/bin/pkill"
  fcn "tex"
  gin "nyxt"
  ain "firefox" && {
    install_extension https://addons.mozilla.org/firefox/downloads/file/4223104/darkreader-4.9.76.xpi
    install_extension https://addons.mozilla.org/firefox/downloads/file/4216633/ublock_origin-1.55.0.xpi
  }
  ain "thunderbird"

  # gaming/school/work
  fcn "steam"
  deb "https://launcher.mojang.com/download/Minecraft.deb"
  deb "https://zoom.us/client/latest/zoom_amd64.deb"
  fcn "ros"
  # ain "spotify-client"                                       \
  #     -p "deb http://repository.spotify.com stable non-free" \
  #     -k "http://download.spotify.com/debian/pubkey.gpg"
  # fcn "quartus"
  # TODO: add discord
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
