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

# show current driver
# lspci -k | grep -A 2 -E "(VGA|3D)"

# check current driver
# cat /proc/driver/nvidia/version

# list drivers
# ubuntu-drivers list

# there's also https://us.download.nvidia.com but it's slower
# check https://download.nvidia.com/XFree86/Linux-x86_64/
# https://www.nvidia.com/en-us/drivers/unix/
# https://www.nvidia.com/Download/index.aspx
# https://github.com/aaronp24/nvidia-versions

function install_drivers_ubuntu() {
  ppa ppa:graphics-drivers/ppa
  # sudo ubuntu-drivers install
  sudo ubuntu-drivers install nvidia:550 # ubuntu-drivers list
}

function install_drivers() {
  # using ubuntu tools
  # ppa ppa:graphics-drivers/ppa
  # # sudo ubuntu-drivers install
  # sudo ubuntu-drivers install nvidia:550 # ubuntu-drivers list

  # basic version. actually readable
  # local BASE=https://download.nvidia.com/XFree86/Linux-x86_64
  # local VERSION=550.90.07 # wget -qO- $URL/latest.txt
  # local URL=$BASE/$VERSION/NVIDIA-Linux-x86_64-$VERSION.run
  # local BIN=$(mktemp)
  # wget --show-progress -qO $BIN
  # chmod +x $BIN
  # ./$BIN

  # epic version: identify latest, download latest, run latest. no subshells
  local URL=https://download.nvidia.com/XFree86/Linux-x86_64
  { mktemp -d; wget -qO- $URL/latest.txt | awk "{print \"$URL/\"\$2}"; }\
    | xargs wget -nv -P 2>&1 | cut -d\" -f2 \
    | xargs -o sudo sh # gah i guess this is a subshell at the end

  # TODO: why does "fname | xargs sh" work but not "fname | sh -" when
  # chmod +x is NOT set???

  # # slightly more epic version
  # # was worth a shot, but i havent found a way to pipe to execution without
  # # a new shell
  # local URL=https://download.nvidia.com/XFree86/Linux-x86_64
  # { mktemp -d; wget -qO- $URL/latest.txt | awk "{print \"$URL/\"\$2}"; }\
  #   | xargs wget -nv -P 2>&1 | cut -d\" -f2 \
  #   | xargs chmod -v +x | cut -d\' -f2
}


# TODO: move this to personal scripts or aliases or rc file
function launchRl() {
  # This finds all ids-name pairs
  # find ~/.steam/steam/steamapps/ -maxdepth 1 -type f -name '*.acf' -exec awk -F '"' '/"appid/{ appid=$4 } /name/{ name=$4 }; END { print appid" "name }' {} \;

  # get rocket league id
  local RLID=$(find ~/.steam/steam/steamapps/ -maxdepth 1 -type f -name '*.acf' -exec awk -F '"' '/"appid/{ appid=$4 } /name/{ name=$4 }; END { if (name == "Rocket League") print appid }' {} \;)

  # launch RL
  steam steam://rungameid/$RLID
  # steam steam://rungameid/252950

  # TODO: hmm looks like these id are static so as long as you have it saved
  # in a file you don't need to search for it

  # install RL
  steamcmd +login +quit
  steamcmd +app_update $RLID validate +quit
}

function installWorkshopMap() {
  local DIR=$(mktemp -d)
  local URL=$1
  local PLG=$(echo $URL | xargs -i basename {} .zip)
  wget -qO $DIR/plg.zip $URL
  unzip $DIR/plg.zip -d ~/.steam/steam/steamapps/common/rocketleague/TAGame/CookedPCConsole/mods/$PLG
}

function installLocalWorkshopMap()
{
  local ZIP=$1
  unzip $ZIP -d ~/.steam/steam/steamapps/common/rocketleague/TAGame/CookedPCConsole/mods/$PLG
}

function installBakkesmodPlugin() {
  local DIR=$(mktemp -d)
  local ID=$1
  wget -qO $DIR/plugin.zip "https://bakkesplugins.com/plugins/download/$ID"
  unzip $DIR/plugin.zip 'plugins/*' -d ~/.steam/steam/steamapps/compatdata/252950/pfx/drive_c/users/steamuser/AppData/Roaming/bakkesmod/bakkesmod
}

function installWorkshopTextures() {
  # TODO: find download link for workshop textures so i can wget from https://videogamemods.com/rocketleague/mods/workshop-textures/
  local TXR="$HOME/Downloads/Workshop-textures.zip"
  unzip $TXR -d ~/.steam/steam/steamapps/common/rocketleague/TAGame/CookedPCConsole/
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
  local COMPATDATA="$HOME/.steam/debian-installation/steamapps/compatdata/252950/pfx"
  local PROTON="$HOME/.steam/debian-installation/steamapps/common/Proton 7.0/dist"
  local WINEESYNC=1 WINEPREFIX="$COMPATDATA" "$PROTON"/bin/wine64 /tmp/BakkesModSetup.exe

  # bakkesmod plugins
  installBakkesmodPlugin '286' # Speedflip Trainer
  installBakkesmodPlugin '108' # AlphaConsole
  installBakkesmodPlugin '223' # Workshop Map Loader and Downloader
  installBakkesmodPlugin '196' # Custom Map Loader (Local Files)

  # workshop textures
  installWorkshopTextures

  # workshop maps
  # TODO: figure out how to check api to just need number and not the name of the plugin
  # NOTE: could also check 'https://lethamyr.com/maps'
  # TODO: map a list of URLs
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/725/packages/generic/Dribble2Overhaul/V1.0.0/Dribble2Overhaul.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/703/packages/generic/NoobDribbleBydmc/V1.0.0/NoobDribbleBydmc.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/710/packages/generic/SpeedJumpRings2Bydmc/V1.0.0/SpeedJumpRings2Bydmc.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/799/packages/generic/SpeedJumpRings2BydmcTimerUpdate/V1.0.0/SpeedJumpRings2BydmcTimerUpdate.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/711/packages/generic/SpeedJumpRings3Bydmc/V1.0.0/SpeedJumpRings3Bydmc.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/700/packages/generic/SpeedJumpRings3BydmcTimerUpdate/V1.0.0/SpeedJumpRings3BydmcTimerUpdate.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/1185/packages/generic/thepath/v1.2.2/thepath.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/700/packages/generic/SpeedJumpRings3BydmcTimerUpdate/V1.0.0/SpeedJumpRings3BydmcTimerUpdate.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/710/packages/generic/SpeedJumpRings2Bydmc/V1.0.0/SpeedJumpRings2Bydmc.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/711/packages/generic/SpeedJumpRings3Bydmc/V1.0.0/SpeedJumpRings3Bydmc.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/715/packages/generic/SpeedJumpRings1Bydmc/V1.0.0/SpeedJumpRings1Bydmc.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/725/packages/generic/Dribble2Overhaul/V1.0.0/Dribble2Overhaul.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/741/packages/generic/AirDribbleChallenge/V1.0.0/AirDribbleChallenge.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/755/packages/generic/LethamyrsTinyRingsMap/V1.0.0/LethamyrsTinyRingsMap.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/799/packages/generic/SpeedJumpRings2BydmcTimerUpdate/V1.0.0/SpeedJumpRings2BydmcTimerUpdate.zip'
  installWorkshopMap 'https://celab.jetfox.ovh/api/v4/projects/1199/packages/generic/thundasurges-rings/V1.0.0/thundasurges-rings.zip'
}

#===============================================================================
# INSTALLATIONS
#===============================================================================

function install_qutebrowser() {
  # NOTE: this should work but does not. using --pip-args prevents pipx from deducing the name of the package when installing this local directory
  # pipx install --force $DIR --pip-args "-r $DIR/misc/requirements/requirements-pyqt-6.4-txt"
  # same with this. inject's --pip-args doesn't allow multiple args
  # pipx install --force $DIR
  # pipx inject --force qutebrowser --pip-args "-r $DIR/misc/requirements/requirements-pyqt-6.4-txt"
  # and this. for some reason pytqt6-qt6's version is just wrong. it's not the version in the requirements file. you have to inject twice for some reason
  # pipx install --force $DIR && pipx inject --force qutebrowser -r $DIR/misc/requirements/requirements-pyqt-6.4-txt
  # but this works, and honestly feels the closes to a regular pip install
  # pipx install --force $DIR
  # pipx runpip qutebrowser install -r $DIR/misc/requirements/requirements-pyqt-6.4.txt
  # alternatively you could try merging all requirements
  # cat $DIR/misc/requirements/requirements-pyqt-6.4-txt >> $DIR/requirements.txt
  # pipx install --force $DIR
  # also worth noting that package name deduction doesn't work with older pip versions
  # so you need
  # ~/.local/share/pipx/shared/bin/pip install -U pip

  # TODO: move away from pipx

  sudo apt install -qy --no-install-recommends git ca-certificates python3 python3-venv \
    libgl1 libxkbcommon-x11-0 libegl1-mesa libfontconfig1 libglib2.0-0 \
    libdbus-1-3 libxcb-cursor0 libxcb-icccm4 libxcb-keysyms1 libxcb-shape0 \
    libnss3 libxcomposite1 libxdamage1 libxrender1 libxrandr2 libxtst6 libxi6 \
    libasound2

  local URL='https://github.com/qutebrowser/qutebrowser/releases/download/v3.2.1/qutebrowser-3.2.1.tar.gz'
  local DIR=$(mktemp -d)
  wget -qO- $URL | tar xvz -C $DIR --strip-components=1

  python3 -m pip install -U --user pipx
  ~/.local/share/pipx/shared/bin/pip install -U pip
  pipx install --force $DIR
  pipx runpip qutebrowser install -r $DIR/misc/requirements/requirements-pyqt-6.4.txt
  cp $DIR/misc/org.qutebrowser.qutebrowser.desktop $XDG_DATA_HOME/applications

  # to uninstall
  # pipx uninstall qutebrowser
  # rm $XDG_DATA_HOME/applications/org.qutebrowser.qutebrowser.desktop
}

function install_tmux() {
  sudo apt install -qy libevent-dev ncurses-dev build-essential bison pkg-config

  local URL='https://github.com/tmux/tmux/releases/download/3.4/tmux-3.4.tar.gz'
  local DIR=$(mktemp -d)
  wget -qO- $URL | tar xvz -C $DIR --strip-components=1
  cd $DIR

  sh autogen.sh
  ./configure
  make && sudo make install
}

function install_quartus() {
  # 32-bit architechture for modelsim
  sudo dpkg --add-architecture i386
  ain "libc6:i386" "libncurses5:i386" "libstdc++6:i386" "libxext6:i386" "libxft2:i386" # dependencies

  local URL='https://cdrdv2.intel.com/v1/dl/getContent/666220/666242?filename=Quartus-web-13.1.0.162-linux.tar'
  local DIR="$(mktemp -d)"
  wget -qO- $URL | tar xv -C $DIR
  sudo $DIR/setup.sh --mode unattended --unattendedmodeui minimalWithDialogs --installdir /opt/altera/15.0

  # set up permissions for usb blaster
  echo '# For Altera USB-Blaster permissions. \SUBSYSTEM=="usb",\
  local ENV{DEVTYPE}=="usb_device",\ATTR{idVendor}=="09fb",\ATTR{idProduct}=="6001",\
  local MODE="0666",\NAME="bus/usb/$env{BUSNUM}/$env{DEVNUM}",\
  local RUN+="/bin/chmod 0666 %c"'| \
    sudo tee /etc/udev/rules.d/51-usbblaster.rules > /dev/null
}

function install_nvim() {
  local URL='https://github.com/neovim/neovim/releases/download/v0.9.4/nvim-linux64.tar.gz'
  local DIR=$(mktemp -d)

  wget -qO- $URL | tar xvz -C $DIR
  cp $DIR/nvim-linux64/bin/nvim        ~/.local/bin/nvim
  cp $DIR/nvim-linux64/man/man1/nvim.1 ~/.local/share/man/man1/nvim.1
}

function install_alacritty() {
  # TODO: can i install directly from github link?
  ghb "alacritty/alacritty"
  local URL = 'https://github.com/alacritty/alacritty/archive/refs/tags/v0.13.2.tar.gz'
  local DIR=$(mktemp -d)
  wget -qO- $URL | tar xvz -C $DIR --strip-components=1

  ain cargo cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
  cargo build --release --manifest-path=$DIR/Cargo.toml
  # cargo build --release --no-default-features --features=x11 --manifest-path=$DIR/Cargo.toml

  # local URL='https://github.com/alacritty/alacritty-theme/archive/refs/heads/master.tar.gz'
  # wget -qO- $URL | tar xvz -C $DIR --strip-components=1
  # local URL='https://github.com/aarowill/base16-alacritty/archive/refs/heads/master.tar.gz'
  # wget -qO- $URL | tar xvz -C $DIR --strip-components=1

  # ln -sf ~/.local/src/alacritty-theme/themes ~/.config/alacritty/themes
}

function install_joshuto() {
  # TODO: add dep for rust, fzf (optional), and zoxide (optional)
  sudo apt install -y cargo xsel xclip
  cargo install --git https://github.com/kamiyaa/joshuto.git --force
}

function install_picom() {
  ain libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libpcre2-dev \
      libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev        \
      libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev   \
      libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev                 \
      libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev               \
      libxcb-xfixes0-dev libxext-dev meson ninja-build uthash-dev

  local DIR=$(mktemp -d)
  wget -qO - 'https://github.com/yshui/picom/archive/refs/tags/v11.2.tar.gz' | tar xvz -C $DIR --strip-components=1
  meson setup --buildtype=release $DIR/build $DIR
  sudo ninja -C $DIR/build install
}

function install_polybar() {
  # requirements
  ain build-essential git cmake cmake-data pkg-config python3-sphinx          \
      python3-packaging libuv1-dev libcairo2-dev libxcb1-dev libxcb-util0-dev \
      libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto        \
      libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev
  # optional for all features
  ain libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev          \
      libpulse-dev i3-wm libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev \
      libnl-genl-3-dev
  pin jinja2==3.0.3

  local DIR=$(mktemp -d)
  wget -qO - 'https://github.com/polybar/polybar/releases/download/3.7.1/polybar-3.7.1.tar.gz' | tar xvz -C $DIR --strip-components=1
  cd $DIR
  $DIR/build.sh -A --all-features
  # cmake -S ~/.local/src/polybar-3.7.1 -B ~/.local/src/polybar-3.7.1/build
  # make -C ~/.local/src/polybar-3.7.1/build -j$(nproc)
  # sudo make -C ~/.local/src/polybar-3.7.1/build install
}

function install_go() {
  local DIR=/usr/local
  local URL="https://go.dev/dl/go1.21.6.linux-amd64.tar.gz"
  sudo rm -rf $DIR/go
  wget -qO- $URL | sudo tar xvz -C $DIR
  # export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin > ~/.config/zsh/.zshrc
  # TODO: idea
  # a directory of files to source each with its own export statements
  # can easily add to this directory when you install something that needs to modify PATH
}

function install_python3() {
  ain "python3" "python3-pip" "python3-venv" && pin "pip"
  ppa "ppa:deadsnakes/ppa" && ain "python3.11" "python3.11-distutils" # TODO: make sure all (or selected) python versions' programs are on PATH
}

function install_guix() {
  local DIR=$(mktemp -d)
  wget -qP $DIR https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh
  chmod +x $DIR/guix-install.sh && $DIR/guix-install.sh
  guix pull && guix package -u

  # hint: Consider setting the necessary environment variables by running:
  #
  #      GUIX_PROFILE="/home/skipper/.config/guix/current"
  #      . "$GUIX_PROFILE/etc/profile"
  #
  # Alternately, see `guix package --search-paths -p "/home/skipper/.config/guix/current"'.
  #
  #
  # hint: After setting `PATH', run `hash guix' to make sure your shell refers to `/home/skipper/.config/guix/current/bin/guix'.
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

# TODO: use this for osx install as well
function install_node20() {
  ain npm
  sudo npm install -g n
  sudo n v20.11.0 # sudo n stable
}

function install_ff_extension() {
  local URL="https://addons.mozilla.org/firefox/downloads/latest/$1"
  local DIR=$(mktemp -d)
  local XPI=$DIR/tmp.xpi
  wget -qO $XPI $URL
  local NAME=$(unzip -p $XPI | grep -a '"id":' | sed -r 's/"|,| //g;s/id://g' 2>/dev/null).xpi
  local EXTDIR=$(find ~/.mozilla/firefox -name '*.default-release*')/extensions
  mkdir -p $EXTDIR
  cp $XPI $EXTDIR/$NAME
  # NOTE: need to install in system to use unsigned non-mozilla extensions
  # TODO: figure out if behavior is similar with thunderbird
  # sudo cp dr.xpi /usr/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/$NAME
}

function install_tb_extension() {
  local URL="https://addons.thunderbird.net/thunderbird/downloads/latest/$1"
  local DIR=$(mktemp -d)
  local XPI=$DIR/tmp.xpi
  wget -qO $XPI $URL
  local NAME=$(unzip -p $XPI | grep -a '"id":' | sed -r 's/"|,| //g;s/id://g' 2>/dev/null).xpi
  cp $XPI $(find ~/.thunderbird -wholename '*.default-release')/extensions/$NAME
}

function install_bluez() {
  # TODO: not sure if i want experimental features
  # https://www.makeuseof.com/install-bluez-latest-version-on-ubuntu/
  # NOTE: this install seams to not overwrite the 'bluetoothd' symlink which will keep the older version
  # not really an issue, but im not sure why this happens or how to safely replace it

  ain build-essential libreadline-dev libical-dev libdbus-1-dev libudev-dev libglib2.0-dev python3-docutils

  local DIR=$HOME/.local/src/bluez
  mkdir -p $DIR
  wget -qO- http://www.kernel.org/pub/linux/bluetooth/bluez-5.66.tar.gz | tar xzv -C $DIR --strip-components=1

  cd $DIR && ./configure
  # $DIR/configure --srcdir=$DIR
  make -C $DIR
  sudo make -C $DIR install

  sudo systemctl daemon-reload
  sudo systemctl unmask bluetooth.service # TODO: find out what unmask does
  sudo systemctl restart bluetooth
}

function install_itl() {
  local DIR=$(mktemp -d)
  wget -qO $DIR/d.deb https://gitea.elara.ws/Elara6331/itd/releases/download/v1.1.0/itd-1.1.0-linux-x86_64.deb
  sudo apt install -y $DIR/d.deb

  # systemctl --user start  itd # starts service right now, could also use 'restart'
  systemctl --user enable itd # sets up service hooks to start on boot
  # or just run 'itd' or 'ITD_LOGGING_LEVEL=debug itd'
}

function install_waspos() {
  # TODO: need some authentication to get the latest CI builds
  # See https://wasp-os.readthedocs.io/en/latest/install.html#binary-downloads
  # See https://stackoverflow.com/questions/27254312/download-github-build-artifact-release-using-wget-curl
  local DIR=$HOME/.local/src/wasp-os
  wget -qO- https://github.com/wasp-os/wasp-os/releases/download/v0.4/wasp-os-0.4.1.tar.gz | tar xvz -C $DIR --strip-components=1
}

function install_siglo() {
  sudo apt install libgtk-3-dev python3-pip meson python3-dbus gtk-update-icon-cache desktop-file-utils gettext appstream-util libglib2.0-dev
  # TODO: I don't really like having to change meson just for this
  # Check out pipx
  python3 -m pip install --user --upgrade gatt requests black meson=0.55.0

  git -C ~/.local/src clone https://github.com/theironrobin/siglo.git
  # mkdir ~/.local/src/siglo/build
  meson ~/.local/src/siglo/build
  sudo ninja -C ~/.local/src/siglo/build install
}

function install_spotify() {
  curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
  ppa 'deb http://repository.spotify.com stable non-free'
  ain spotify-client
}

function install_pipewire() {
  # pipewire
  sudo apt install -y pulseaudio-utils # for pactl
  sudo add-apt-repository -yu ppa:pipewire-debian/pipewire-upstream && {
    sudo apt install -y pipewire libspa-0.2-bluetooth pipewire-audio-client-libraries # libspa-0.2-jack # if jack needed but i dont think it is
    sudo apt install -y pipewire-libcamera # not really needed but running the wireplumber binary complains
  }
  systemctl --user daemon-reload
  systemctl --user --now disable pulseaudio # covers both .service and .socket
  systemctl --user --now mask    pulseaudio
  systemctl --user --now enable  pipewire pipewire-pulse

  # pipewire-media-session
  sudo apt install -y pipewire-media-session; {
    systemctl --user daemon-reload
    systemctl --user --now disable wireplumber
    systemctl --user --now enable  pipewire-media-session
  }

  # wireplumber
  # NOTE: if i recall correctly wireplumber has some weird delays. not sure if that's
  # why i opted for pipewire-media-session
  # TODO: clean this up. even if we're not using the service, wpctl is useful
  sudo add-apt-repository -yu ppa:pipewire-debian/wireplumber-upstream
  sudo apt install -y wireplumber
  # sudo add-apt-repository -yu ppa:pipewire-debian/wireplumber-upstream; {
  #   sudo apt install -y wireplumber
  #   systemctl --user daemon-reload
  #   systemctl --user --now disable pipewire-media-session
  #   systemctl --user --now enable  wireplumber
  # }

  # NOTE: if running into issues, try removing config files at /etc/pipewire

  # TODO: consider copying default configs
  # alsa
  # sudo cp /usr/share/doc/pipewire/examples/alsa.conf.d/99-pipewire-default.conf /etc/alsa/conf.d/
  # jack
  # sudo cp /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*.conf /etc/ld.so.conf.d/

  # TODO: does not seem to correctly remove pipewire-media session when enabled
  # removes currently-enabled between wireplumber and pipewire-media-session
  # systemctl --user --now disable pipewire-session-manager
}

function install_chafa() {
  ghb hpjansson/chafa
  ./autogen.sh --srcdir=~/.local/src/chafa
  make -C ~/.local/src/chafa
  sudo make -C ~/.local/src/chafa install
  #  NOTE: (from compilation messages) may need to run 'sudo ldconfig'
}

function install_gcc() {
  sudo add-apt-repository -yu ppa:ubuntu-toolchain-r/test
  sudo apt install -y gcc-$1 g++-$1
  # was previously linked to /usr/bin/g++-9
  sudo update-alternatives \
    --install /usr/bin/gcc gcc /usr/bin/gcc-$1 $1 \
      --slave /usr/bin/g++ g++ /usr/bin/g++-$1 \
      --slave /usr/bin/gcov gcov /usr/bin/gcov-$1
  # sudo update-alternatives --set gcc /usr/bin/gcc-$1
}

function install_uberzugpp() {
  sudo apt install -y libssl-dev libvips-dev libsixel-dev libchafa-dev libtbb-dev
  python3 -m pip install --user --upgrade cmake

  # INSTALL LATEST CHAFA AND NEWER GCC
  install_chafa
  install_gcc 10
  git -C ~/.local/src clone 'https://github.com/jstkdng/ueberzugpp.git'
  # cd ~/.local/src/ueberzugpp
  # mkdir build
  cmake -DCMAKE_BUILD_TYPE=Release -S ~/.local/src/ueberzugpp -B ~/.local/src/ueberzugpp/build
  cd ~/.local/src/ueberzugpp/build
  cmake --build .
}

function install_uberzugpy() {
  git clone https://github.com/ueber-devel/ueberzug.git ~/.local/src/ueberzug
  python3 -m pip install --user --upgrade ~/.local/src/ueberzug
}

function install_xsecurelock() {
  sudo apt install -y xscreensaver
  git -C ~/.local/src clone https://github.com/google/xsecurelock.git
  cd ~/.local/src/xsecurelock
  sh autogen.sh
  ./configure --with-pam-service-name=xscreensaver # alternatively 'common-auth'
  make -C ~/.local/src/xsecurelock
  sudo make -C ~/.local/src/xsecurelock install
}

function install_i3lock_color() {
  aib autoconf gcc make pkg-config libpam0g-dev libcairo2-dev                 \
      libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev       \
      libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev \
      libxcb-util-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev    \
      libjpeg-dev
  git -C ~/.local/src clone https://github.com/Raymo111/i3lock-color.git
  cd ~/.local/src/i3lock-color
  ./install-i3lock-color.sh
}

function install_i3lock() {
  git -C ~/.local/src clone https://github.com/i3/i3lock.git
  ain libxcb-xinerama0-dev libxkbcommon-x11-dev libpam-dev libpam0g-dev

  meson setup --buildtype=release ~/.local/src/i3lock/build ~/.local/src/i3lock
  sudo ninja -C ~/.local/src/i3lock/build install -Dprefix=/usr

  # these from the docs didn't seem to work. maybe needed sudo?
  # meson .. -Dprefix=/usr
  # ninja
}

function install_zathura_pywal() {
  local SHA="f5b6d4a452079d9b2cde070ac3b8c742b6952703"
  local URL="https://github.com/matthewlscarlson/zathura-pywal/archive/$SHA.tar.gz"
  local DIR=$(mktemp -d)
  wget -qO- $URL | tar xvz -C $DIR --strip-components=1
  sudo make -C $DIR install
}

function packages()
{
  # basics
  sudo apt update && sudo apt upgrade
  sudo DEBIAN_FRONTEND=noninteractive
  local DEBIAN_FRONTEND=noninteractive # https://stackoverflow.com/questions/44331836/apt-get-install-tzdata-noninteractive
  ain tzdata # TODO: check if tzdata is needed for /etc/timezone to be correct with noninteractive
  ain software-properties-common # essentials (ie apt-add-repository)
  ain zsh zsh-syntax-highlighting zsh-autosuggestions && {
    sudo chsh -s /bin/zsh $(whoami) # ghb zsh-users/zsh-autosuggestions # TODO: consider getting both of these straight from github
    ain vim-gtk xsel xclip # need a verison of vim with +clipboard enabled to properly yank
  }
  ppa ppa:git-core/ppa && ain git
  fcn python3 && pin pipx
  fcn guix
  ain less
  ain systemd
  ain xorg
  ain gcc
  ain make
  ain cmake
  ain curl
  ain network-manager # i think this has nmtui # TODO: need to address that you won't be able to use this script without wifi. maybe do some prep step
  ain cifs-utils # tool for mounding temp drives
  ain jq
  ain xsel xclip
  ain bluez bluez-tools blueman rfkill && {
    sudo service bluetooth start
    rfkill | awk '/hci0/{print $1}' | xargs rfkill unblock
    fcn bluez
    fcn itd
    fcn waspos
    fcn siglo
    bluetoothctl power on
  }

  ain slock physlock xsecurelock i3lock i3lock-fancy vlock xss-lock # lockscreens. slock seems to be an alias to the package 'suckless-tools'
  # xss-lock --transfer-sleep-lock -- i3lock --nofork
  #
  # https://github.com/google/xsecurelock?tab=readme-ov-file#automatic-locking
  # xset s 300 5
  # xss-lock -n /usr/lib/xsecurelock/dimmer -l -- xsecurelock
  #
  # Dim the screen after three minutes of inactivity, lock the screen two minutes later using i3lock:
  # xset s 180 120
  # xss-lock -n dim-screen.sh -- i3lock -n
  #
  # SECURITY CONSIDERATIONS
  #    To make sure a locked screen can not be bypassed by switching VTs or killing the X server with Ctrl+Alt+Backspace, it is recommended to disable
  #    both in xorg.conf(5) for maximum security:
  #
  #    Section "ServerFlags"
  #            Option "DontVTSwitch" "True"
  #            Option "DontZap"      "True"
  #    EndSection

  # Desktop Environment
  ain brightnessctl # brightness control
  ain xdotool # for grabbing window names (I use it to handle firefox keys)
  ain xserver-xorg-core # libinput dependency
  ain xserver-xorg-input-libinput # allows for sane trackpad expeirence
  ain pulseaudio alsa-utils pavucontrol && fcn pipewire # for audio controls
  ain arandr # for saving and loading monitor layouts
  ain autorandr # gui for managing monitor layouts
  ain rofi; ghb newmanls/rofi-themes-collection
  ppa ppa:drdeimosnn/survive-on-wm && ain bspwm sxhkd
  fcn polybar
  ain redshift
  fcn picom
  ain fontcofig; fcn fonts

  # silly terminal scripts to show off
  ain figlet; ghb xero/figlet-fonts # For writing asciiart text
  ain tty-clock # terminal digial clock
  ppa ppa:dawidd0811/neofetch && ain neofetch
  ppa ppa:ytvwld/asciiquarium && ain asciiquarium
  deb 'https://github.com/fastfetch-cli/fastfetch/releases/download/2.7.1/fastfetch-2.7.1-Linux.deb' # TODO: consider grabbing latest instead of version
  ghb stark/Color-Scripts # colorscripts  # TODO: may need to check this shows up in path
  cargo install macchina # fetch

  # essential gui/advanced tui programs
  ain main # screenshot utility
  ain ffmpeg # screen record utility
  ain firefox
  ain feh sxiv # image viewer
  ain mpv # video player
  fcn alacritty
  fcn nvim && pin pynvim && fcn node20 && ain calc # TODO: not sure if i need xsel and/or xclip here
  fcn tmux
  ghb junegunn/fzf && ~/.local/src/fzf/install --all --xdg --completion && ain ripgrep # fuzzy finder
  ain autojump
  ain htop
  ain openconnect; addSudoers /usr/bin/openconnect, /usr/bin/pkill
  fcn texlive && {
    ain enscript    # converts textfile to postscript (use with ps2pdf)
    ain entr        # run arbitrary commands when files change, for live edit
    ain ghostscript # installs ps2pdf
    ppa ppa:inkscape.dev/stable && ain inkscape # for latex drawings
  }

  gin nyxt
  ain zathura zathura-pdf-poppler && fcn zathura_pywal
  deb 'https://github.com/wez/wezterm/releases/download/20240203-110809-5046fc22/wezterm-20240203-110809-5046fc22.Ubuntu20.04.deb'
  fcn joshuto

  ghb eylles/pywal16 && {
    pin ~/.local/src/pywal16
    ain imagemagick
    pin colorthief
    pin haishoku
    pin colorz
    fcn go
    go install github.com/thefryscorer/schemer2@latest
  }



  ain firefox && {
    install_ff_extension darkreader
    install_ff_extension ublock-origin
    install_ff_extension vimium-ff
    install_ff_extension youtube-recommended-videos
  }
  ain thunderbird && {
    install_tb_extension darkreader
    install_tb_extension tbsync
    install_tb_extension eas-4-tbsync
  }
  ain thunderbird

  # gaming/school/work
  fcn steam
  deb https://launcher.mojang.com/download/Minecraft.deb
  deb https://zoom.us/client/latest/zoom_amd64.deb
  fcn ros
  fcn spotify

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
