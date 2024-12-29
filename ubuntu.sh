source library.sh

#===============================================================================
# SYSTEM PREPS
#===============================================================================

function prepRoot() {
  apt update -y; apt install -y sudo
  USER=$1
  useradd -m $USER || echo "User $USER exists"; passwd -d $USER
  echo "$USER ALL=(ALL) ALL" | tee -a /etc/sudoers.d/$USER
  chown $USER /home/$USER; chmod ug+w /home/$USER
}

function prep(){
  sudo apt update -y
  # sudo apt full-upgrade -y
  sudo dpkg --add-architecture i386
  sudo ln -sfT /usr/share/zoneinfo/UTC /etc/localtime # prevents tz dialogue
}




#===============================================================================
# POST-INSTALL CONFIGS
#===============================================================================

function install_steamgames() {
  steam_install_game 1493710 # proton experiemental
  steam_install_game 2805730 # proton 9.0
  steam_install_game 252950  # rocket league

  # bakkesmod for rocket league
  local URL='https://github.com/bakkesmodorg/BakkesModInjectorCpp/releases/latest/download/BakkesModSetup.zip'
  local DIR=$(mktemp -d)
  wget -qP $DIR $URL; unzip $DIR/BakkesModSetup.zip -d $DIR

  local COMPATDATA="$HOME/.steam/steam/steamapps/compatdata/252950"
  local PROTON="$(sed -n 4p "$COMPATDATA"/config_info | xargs -d '\n' dirname)"
  WINEESYNC=1 WINEPREFIX="$COMPATDATA"/pfx "$PROTON"/bin/wine64 $DIR/BakkesModSetup.exe

  installBakkesExtensions
}

#===============================================================================
# CUSTOM INSTALL FUNCTIONS
#===============================================================================

function install_quartus() {
  # 32-bit architechture for modelsim
  sudo dpkg --add-architecture i386 # NOTE: handled in prep() function
  ain "libc6:i386" "libncurses5:i386" "libstdc++6:i386" "libxext6:i386" "libxft2:i386" # dependencies

  local URL='https://cdrdv2.intel.com/v1/dl/getContent/666220/666242?filename=Quartus-web-13.1.0.162-linux.tar'
  local DIR="$(mktemp -d)"
  wget -qO- $URL | tar x -C $DIR
  sudo $DIR/setup.sh --mode unattended --unattendedmodeui minimalWithDialogs --installdir /opt/altera/15.0

  # set up permissions for usb blaster
  echo '# For Altera USB-Blaster permissions. \SUBSYSTEM=="usb",\
  local ENV{DEVTYPE}=="usb_device",\ATTR{idVendor}=="09fb",\ATTR{idProduct}=="6001",\
  local MODE="0666",\NAME="bus/usb/$env{BUSNUM}/$env{DEVNUM}",\
  local RUN+="/bin/chmod 0666 %c"'| \
    sudo tee /etc/udev/rules.d/51-usbblaster.rules > /dev/null
}

function install_ros() {
  ppa "deb http://packages.ros.org/ros/ubuntu $(lsb_release -cs) main"
  # TODO: fix key add  -k "http://packages.ros.org/ros.key"
  ain cmake
  ain ros-*-desktop-full
  ain ros-*-plotjuggler-ros
  ain python
  ain python-rosdep
  ain python-rosinstall
  ain python-rosinstall-generator
  ain python-wstool
  ain build-essential
}

function install_waspos() {
  # TODO: need some authentication to get the latest CI builds
  # See https://wasp-os.readthedocs.io/en/latest/install.html#binary-downloads
  # See https://stackoverflow.com/questions/27254312/download-github-build-artifact-release-using-wget-curl
  local DIR=$(mktemp -d)
  wget -qO- https://github.com/wasp-os/wasp-os/releases/download/v0.4/wasp-os-0.4.1.tar.gz | tar xz -C $DIR --strip-components=1
}

#===============================================================================
# INSTALLATIONS
#===============================================================================

function packages()
{
  # basics
  ain wget curl tar unzip software-properties-common
  ain unminimize; yes | sudo unminimize
  ppa ppa:git-core/ppa; ain git
  # curl -L https://nixos.org/nix/install | sh -s -- --no-daemon; . ~/.nix-profile/etc/profile.d/nix.sh
  ain nix-bin; {
    sudo usermod -aG nix-users $USER
    sudo nix-daemon >/dev/null 2>&1 & # TODO: never works on the first run
    # export PATH=$PATH:~/.local/state/nix/profile/bin
  }
  ain guix # guix-setup-systemd # TODO: guix unfree software
  ain zsh zsh-syntax-highlighting zsh-autosuggestions; {
    sudo chsh -s /bin/zsh $(whoami)
  }
  ppa ppa:deadsnakes/ppa; ain python3 python3-pip python3-venv pipx
  ain less which
  ain systemd
  ain man-db manpages texinfo
  ain gcc make cmake bear # TODO: bazel
  # TODO: need to address that you won't be able to use this nmtui without installing over wifi
  ain dhcpcd iwd network-manager; { # network-manager includes nmtui
    echo '
      [General]
      EnableNetworkConfiguration=true
    ' | awk '{$1=$1;print}' | sudo tee /etc/iwd/main.conf
    echo '
      # Configuration file for NetworkManager.
      # See "man 5 NetworkManager.conf" for details.

      [device]
      wifi.scan-rand-mac-address=no
      wifi.backend=iwd

      [Network]
      NameResolvingService=systemd
    ' | awk '{$1=$1;print}' | sudo tee /etc/NetworkManager/NetworkManager.conf
    sudo systemctl enable dhcpcd.service
    sudo systemctl enable iwd.service
    sudo systemctl enable NetworkManager.service
  }
  ain cifs-utils # tool for mounding temp drives
  ain jq
  ain xsel xclip
  ain fzf ripgrep
  ain neovim python3-pynvim npm xsel xclip calc
  ain calc bc
  ain tmux
  ain docker.io; {
    sudo systemctl enable docker.service
    sudo groupadd -f docker
    sudo usermod -aG docker $USER
  }
  ain autojump
  ain htop
  ain openconnect; addSudoers /usr/bin/openconnect; addSudoers /usr/bin/pkill
  ain brightnessctl # brightness control
  ain redshift
  ain pipewire pipewire-audio pipewire-pulse wireplumber; {
    ain pavucontrol pulsemixer # audio controllers
    ain pipewire-libcamera # not needed but the wireplumber binary complains
    ain firmware-sof-signed # not sure if needed
    ain alsa-utils
    systemctl --user enable pipewire pipewire-pulse wireplumber # covers both .service + .socket
  }
  ain bluez bluez-tools blueman rfkill playerctl; {
    rfkill | awk '/hci0/{print $1}' | xargs rfkill unblock
    sudo systemctl enable bluetooth.service
  }

  # Desktop Environment
  ain xorg xinit x11-utils # x11-utils contains xev
  ain xdotool # for grabbing window names
  # TODO: not sure if i need libinput driver or just the binary
  ain xserver-xorg-input-libinput # allows for sane trackpad expeirence
  ain arandr autorandr # xrandr caching and gui
  ain rofi; ghb newmanls/rofi-themes-collection
  ain bspwm sxhkd polybar picom
  ain fontconfig; fcn fonts

  # silly terminal scripts to show off
  ain figlet; ghb xero/figlet-fonts # For writing asciiart text # TODO: replace ghb
  ain tty-clock # terminal digial clock
  ain neofetch
  ppa ppa:zhangsongcui3371/fastfetch; ain fastfetch
  ppa ppa:ytvwld/asciiquarium; ain asciiquarium tty-clock
  nxi macchina # fetch
  ghb stark/Color-Scripts # colorscripts  # TODO: may need to check this shows up in path
  nxi ueberzugpp

  # essential gui/advanced tui programs
  ain alacritty
  # gin nyxt
  ppa ppa:mozillateam/ppa; {
    # https://askubuntu.com/a/1404401
    echo '
      Package: *
      Pin: release o=LP-PPA-mozillateam
      Pin-Priority: 1001

      Package: firefox
      Pin: version 1:1snap*
      Pin-Priority: -1
    ' | awk '{$1=$1;print}' | sudo tee /etc/apt/preferences.d/mozilla-firefox
    ain firefox
    fcn ff_profile
    ffe darkreader ublock-origin vimium-ff youtube-recommended-videos \
      facebook-container news-feed-eradicator archlinux-wiki-search
    ain thunderbird
    fcn tb_profile
    tbe darkreader tbsync eas-4-tbsync
  }
  ain qutebrowser
  ain maim     # screenshot utility
  ain ffmpeg   # screen record utility # TODO: consider fbcat
  ain feh sxiv # image viewer
  ain mpv      # video player
  ain zathura zathura-pdf-poppler; fcn zathura_pywal
  nxi joshuto
  # pix pywal16; {
  #   ain imagemagick; pix colorthief haishoku colorz
  #   nxi go; go install github.com/thefryscorer/schemer2@latest
  # }
  ain xsecurelock xscreensaver slock physlock vlock xss-lock # lockscreens. slock seems to be an alias to the package 'suckless-tools'

  # gaming/school/work
  ppa multiverse; {
    # https://askubuntu.com/a/1017487
    echo steam steam/question select "I AGREE" | sudo debconf-set-selections
    echo steam steam/license note '' | sudo debconf-set-selections
    ain steam # NOTE: https://askubuntu.com/a/1225192
    ain steamcmd
  }
  deb https://launcher.mojang.com/download/Minecraft.deb
  # ain ubuntu-drivers-common; ppa ppa:graphics-drivers/ppa; sudo ubuntu-drivers install # ubuntu-drivers list

  deb https://zoom.us/client/latest/zoom_amd64.deb
  deb https://downloads.slack-edge.com/desktop-releases/linux/x64/4.41.105/slack-desktop-4.41.105-amd64.deb
  # fcn ros
  nxi spotify spotify-qt

  # fcn quartus
  # TODO: add arm programmer
  ain gcc-arm-none-eabi
  fcn texlive; {
    ain enscript    # converts textfile to postscript (use with ps2pdf)
    ain entr        # run arbitrary commands when files change, for live edit
    ain ghostscript # installs ps2pdf
    ppa ppa:inkscape.dev/stable; ain inkscape # for latex drawings
  }
}

function packages2()
{
  # TODO: sync dotfiles under user home directory

  # basics
  ain software-properties-common wget
  # curl -L https://nixos.org/nix/install | sh -s -- --no-daemon; . ~/.nix-profile/etc/profile.d/nix.sh
  ain nix-bin; {
    sudo usermod -aG nix-users $USER
    sudo nix-daemon >/dev/null 2>&1 & # TODO: never works on the first run
    # export PATH=$PATH:~/.local/state/nix/profile/bin
  }

  # TODO: run guix daemon
  # https://guix.gnu.org/manual/en/html_node/Invoking-guix_002ddaemon.html
  # https://hiphish.github.io/blog/2020/11/20/guix-daemon-for-runit/
  # gin nyxt
  # pix pywal16; {
  #   ain imagemagick; pix colorthief haishoku colorz
  #   nxi go; go install github.com/thefryscorer/schemer2@latest
  # }
  # ain ubuntu-drivers-common; ppa ppa:graphics-drivers/ppa; sudo ubuntu-drivers install # ubuntu-drivers list

  # fcn ros
  # fcn quartus
  # TODO: add arm programmer
}

#===============================================================================
# MAIN BOOTSTRAP FUNCTION
#===============================================================================

function bootstrap() {
  supersist
  bigprint "Prepping For Bootstrap"  ; prep
  bigprint "Copying dotfiles to home"; syncDots
  bigprint "Installing Packages"     ; packages
  bigprint "Configure OS"            ; config
  bigprint "OS Config Complete. Restart Required"
}
