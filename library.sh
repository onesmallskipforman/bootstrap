# NOTE: avoid using logical AND for commands that are truly errors if the first part fails

#===============================================================================
# UTILITIES
#===============================================================================

function multiecho(){ printf "${1}%.0s" {1..67}; }
function bigprint() { multiecho '~'; echo -e "\n$1"; multiecho '~'; echo; }

function os() {
  if   [ $(uname)           = "Darwin" ]; then echo "osx"
  elif [ $(lsb_release -is) = "Ubuntu" ]; then echo "ubuntu"
  else echo "OS not found"; return 1; fi
}

function supersist() {
  # Keep-alive: update existing sudo timestamp until the script has finished
  sudo -v; while kill -0 "$$"; do sudo -n true; sleep 60; done 2>/dev/null &
}

function tmpdir() { mktemp -u | xargs dirname; }

function changeUser() {
  # TODO: might need to change shell too with chsh
  local OLD=$1; local NEW=$2
  usermod -l $NEW -m -d /home/$NEW $OLD
  sudo groupmod -n $NEW $OLD
  sudo mv /etc/sudoers.d/$OLD /etc/sudoers.d/$NEW
}

function start_nix() {
  # start nix daemon if service is not running
  # need to suppres stderr for nix daemon because it was printing blank outputs
  # when working interactively in a docker container
  systemctl is-active --quiet nix-daemon.service >/dev/null 2>&1 \
    && sudo systemctl restart nix-daemon.service \
    || sudo nix --extra-experimental-features nix-command daemon \
      >/dev/null 2>&1 &
  export PATH=$HOME/.local/state/nix/profile/bin:$PATH
}

#===============================================================================
# MAIN SCRIPT
#===============================================================================

function menuRun() {
  # Run sections based on command line arguments
  for ARG in "$@"; do
    [ $ARG = "pre" ] || [ $ARG = "all" ] && prep
    [ $ARG = "dot" ] || [ $ARG = "all" ] && dotfiles
    [ $ARG = "pkg" ] || [ $ARG = "all" ] && packages
    [ $ARG = "cfg" ] || [ $ARG = "all" ] && config
  done
  bigprint "Completed running dots. Please resart your computer."
  echo "Some of these changes require a logout/restart to take effect.\n"
}

#===============================================================================
# PREP
#===============================================================================

function createUser() {
  # everything needed to run as user
  USER=$1
  # PASS=$2
  useradd -m $USER || echo "User $USER exists"; passwd -d $USER #$PASS
  echo "$USER ALL=(ALL) ALL" | tee /etc/sudoers.d/$USER
}

function copyDots() {
    # identify files, make directories, copy files
    DOTS="dotfiles"
    FILES=$(find $DOTS -type f -not -path '*.git*' | sed "s/^$DOTS\///g" )
    echo $FILES | xargs -n1 dirname | sort -u | xargs -n1 -I{} mkdir -p ~/{}
    echo $FILES | xargs -n1 -I{} cp dotfiles/{} ~/{}
}

function syncDots() {
  # TODO: allow running outside of bootstrap directory
  local HOME=${1:-$HOME}
  local DOTS="$(realpath dotfiles)"
  # id all desired top-level targets
  local TARGETS=$({
    echo $DOTS/.local/bin
    find \
      $DOTS/.local/share \
      $DOTS/.config \
        -mindepth 1 -maxdepth 1 -not -path '*.git*' -not -path '*README.md'
  } | sed "s;$DOTS/;;g")

  # find if targets exist and copy their contents to dotfiles
  echo "$TARGETS" | xargs -r -I{} cp -rT $HOME/{} $DOTS/{} 2>/dev/null || true
  # remove existing from home
  echo "$TARGETS" | xargs -I{} sudo rm -rf $HOME/{}
  # ensure directories exist
  echo "$TARGETS" | xargs -n1 dirname | sort -u | xargs -I{} mkdir -p $HOME/{}
  # symlink dotfiles to home
  echo "$TARGETS" | xargs -I{} ln -sfT $DOTS/{} $HOME/{}
}

function setHostname() {
  local HN=wb-sgonzalez
  echo $HN | sudo tee /etc/hostname >/dev/null # hostnamectl set-hostname $HN
}

function setTimezone() {
  local TZU=https://ipapi.co/timezone
  # sudo ln -sfT /usr/share/zoneinfo/$(curl $TZU) /etc/localtime
  sudo ln -sfT /usr/share/zoneinfo/UTC /etc/localtime
}

#===============================================================================
# LITERALLY JUST ROCKET LEAGUE
#===============================================================================

function steam_install_game() {
  steamcmd +login $(pass show steam | sed '1q;d') $(pass show steam | sed '2q;d') +app_update $1 validate +quit
}

function installBakkesmodPlugin() {
  local DIR=$(mktemp -d)
  local ID=$1
  local C="$HOME/.steam/steam/steamapps/compatdata/252950/pfx/drive_c"
  wget -qO $DIR/plugin.zip "https://bakkesplugins.com/plugins/download/$ID"
  unzip -o $DIR/plugin.zip 'plugins/*' \
    -d $C/users/steamuser/AppData/Roaming/bakkesmod/bakkesmod
}

function installWorkshopTextures() {
  local URL=https://www.speedrun.com/static/resource/37ylq.zip
  local DIR=$(mktemp -d)
  wget -qO $DIR/txr.zip $URL
  unzip -o $DIR/txr.zip \
    -d ~/.steam/steam/steamapps/common/rocketleague/TAGame/CookedPCConsole/
}

# TODO: make function mappable
# TODO: map in one line so you don't have to wrap every function
function installWorkshopMap() {
  local MODS=$HOME/.steam/steam/steamapps/common/rocketleague/TAGame/CookedPCConsole/mods
  mkdir -p $MODS
  local DIR=$(mktemp -d)
  local URL=$1
  local PLG=$(echo $URL | xargs -i basename {} .zip)
  wget -qO $DIR/plg.zip $URL
  unzip -o $DIR/plg.zip -d $MODS/$PLG
}

# TODO: make function mappable
function installWorkshopMapId() {
  local ID=$1
  local DIR=$(mktemp -d)
  local BASE="https://celab.jetfox.ovh/api/v4/projects/$ID/packages"
  local URL=$(wget -qO- $BASE \
    | jq -r '.[] | .package_type+"/"+.name+"/"+.version+"/"+.name+".zip"')
  installWorkshopMap $BASE/$URL
}

function installBakkesExtensions() {
  # bakkesmod plugins
  installBakkesmodPlugin '286' # Speedflip Trainer
  installBakkesmodPlugin '108' # AlphaConsole
  installBakkesmodPlugin '223' # Workshop Map Loader and Downloader
  installBakkesmodPlugin '196' # Custom Map Loader (Local Files)

  # workshop textures
  installWorkshopTextures

  # workshop maps
  installWorkshopMapId '725'   # Dribble2Overhaul
  installWorkshopMapId '703'   # NoobDribbleBydmc
  installWorkshopMapId '715'   # SpeedJumpRings1Bydmc
  installWorkshopMapId '710'   # SpeedJumpRings2Bydmc
  installWorkshopMapId '799'   # SpeedJumpRings2BydmcTimerUpdate
  installWorkshopMapId '711'   # SpeedJumpRings3Bydmc
  installWorkshopMapId '700'   # SpeedJumpRings3BydmcTimerUpdate
  installWorkshopMapId '1185'  # thepath
  installWorkshopMapId '725'   # Dribble2Overhaul
  installWorkshopMapId '741'   # AirDribbleChallenge
  installWorkshopMapId '755'   # LethamyrsTinyRingsMap
  installWorkshopMapId '1199'  # thundasurges-rings
}

function install_waspos() {
  # TODO: need some authentication to get the latest CI builds
  # See https://wasp-os.readthedocs.io/en/latest/install.html#binary-downloads
  # See https://stackoverflow.com/questions/27254312/download-github-build-artifact-release-using-wget-curl
  local DIR=$(mktemp -d)
  wget -qO- https://github.com/wasp-os/wasp-os/releases/download/v0.4/wasp-os-0.4.1.tar.gz | tar xz -C $DIR --strip-components=1
}

#===============================================================================
# PACKAGE INSTALLATION
#===============================================================================

function install_guix() {
  local DIR=$(mktemp -d)
  wget -qP $DIR https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh
  chmod +x $DIR/guix-install.sh && yes | sudo $DIR/guix-install.sh
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

# function install_ff_extension() {
#   local URL="https://addons.mozilla.org/firefox/downloads/latest/$1"
#   local DIR=$(mktemp -d)
#   local XPI=$DIR/tmp.xpi
#   wget -qO $XPI $URL
#   local NAME=$(unzip -p $XPI | grep -a '"id": ' | sed -r 's/[\t\n\r," ]//g;s/id://g').xpi
#   local EXTDIR=$(find ~/.mozilla/firefox -name '*.default-release*')/extensions
#   mkdir -p $EXTDIR
#   cp $XPI $EXTDIR/$NAME
#   # NOTE: need to install in system to use unsigned non-mozilla extensions
#   # TODO: figure out if behavior is similar with thunderbird
#   # sudo cp dr.xpi /usr/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/$NAME
# }
# function install_tb_extension() {
#   local URL="https://addons.thunderbird.net/thunderbird/downloads/latest/$1"
#   local DIR=$(mktemp -d)
#   local XPI=$DIR/tmp.xpi
#   wget -qO $XPI $URL
#   local NAME=$(unzip -p $XPI | grep -a '"id": ' | sed -r 's/[\t\n\r," ]//g;s/id://g').xpi
#   local EXTDIR=$(find ~/.thunderbird -name '*.default-release*')/extensions
#   mkdir -p $EXTDIR
#   cp $XPI $EXTDIR/$NAME
# }
# # TODO: generalize install ff and tb extensions
#

function install_mozilla_profile() {
  local PROGRAM=$1
  local PROFILE=$2
  local FOLDER=$3
  local CFG=$HOME/.config/$PROGRAM
  local DIR=$HOME/$FOLDER
  mkdir -p $DIR/$PROFILE
  find -L $CFG -mindepth 1 -maxdepth 1 | xargs -L1 basename \
    | xargs -r -I{} ln -sfT $CFG/{} "$DIR/$PROFILE/{}"

  echo "
  [General]
  StartWithLastProfile=1
  Version=2

  [Profile0]
  Default=1
  IsRelative=1
  Name=$PROFILE
  Path=$PROFILE
  " | awk '{$1=$1;print}' > $DIR/profiles.ini
}
function install_ff_profile() {
  install_mozilla_profile firefox profile .mozilla/firefox
}
function install_tb_profile() {
  install_mozilla_profile thunderbird profile .thunderbird
}

function addSudoers() {
  local FNAME=/etc/sudoers.d/$(whoami)_$(echo $1 | sed 's;^/;;g;s;[/\.-];_;g')
  sudo echo "$(whoami) ALL=(root) NOPASSWD: $1" | sudo tee -a $FNAME
}

function install_libinput_settings() {
  echo '
    Section "InputClass"
        Identifier "libinput"
        Driver "libinput"
        # MatchIsTouchpad "on"
        # MatchIsPointer "on"
        # Option "Tapping" "on"
        # Option "TappingButtonMap" "lrm"

        # set natural scrolling
        Option "NaturalScrolling" "on"

        # set mouse speed and acceleration
        Option "AccelProfile" "Adaptive"
        # Option "AccelSpeed" "0.5"

        # set key repeat delay (225 ms) and repeat time (30 ms -> ~33 reapeats/s)
        Option "AutoRepeat" "225 30"
    EndSection
  ' | sed 's/^    //g' | awk NF | sudo tee /etc/X11/xorg.conf.d/libinput.conf
}

# TODO: using makepkg -d might be preventing makedeps from being installed
# Consider just giving nobody some sudo nopasswd permissions
# this will require passwd -d AND adding nobody to sudoers
# ^definitely the latter
# NOTE: a limitation of using nobody for makepkg is that nobody does not have a directory
# for build tools that set up caches like cargo's CARGO_HOME
function aur_makepkg_user() {
  USER=${2:-nobody}
  pacman -S --needed --noconfirm wget tar base-devel
  local DIR=$(runuser -u $USER -- mktemp -d)
  local URL=https://aur.archlinux.org/cgit/aur.git/snapshot/$1.tar.gz
  wget -qO- $URL | runuser -u $USER -- tar xz -C $DIR --strip-components=1
  # -d required to prevent dep installs as $USER. pacman -U will cover deps
  ( cd $DIR; runuser -u $USER -- makepkg -si --noconfirm ) # -d )
  # find $DIR -name "*.zst" | xargs sudo pacman -U --noconfirm
}

function aur_makepkg() {
  sudo pacman -S --needed --noconfirm wget tar base-devel
  local DIR=$(mktemp -d)
  local URL=https://aur.archlinux.org/cgit/aur.git/snapshot/$1.tar.gz
  wget -qO- $URL | tar xz -C $DIR --strip-components=1
  ( cd $DIR; makepkg -si --noconfirm )
}

# TODO: does not work with snapshot file
# function aur_pacman_install() {
#   sudo pacman -S --needed --noconfirm wget
#   local DIR=$(mktemp -d)
#   local URL=https://aur.archlinux.org/cgit/aur.git/snapshot/$1.tar.gz
#   wget -qP $DIR $URL
#   sudo pacman -U $DIR/${1}.tar.gz
# }

function cln() {
  local DIR=$HOME/.local/src/$(basename $1 .git)
  [ -d "$DIR/.git" ] || git clone --depth 1 $1 $DIR
}
function map() { cat | tr ' ' '\n' | while read -r a; do "$@" "$a"; done; }
function coi() { cargo install --locked $@; }
  # TODO: specify python version for pip install function
function pin() { python3 -m pip install --user --upgrade $@; }
# function pxi() { sudo pipx install --global --force $@; }
function pxi() { pipx install --force $@; }
# TODO: (maybe instead of ghb use wget to overwrite dir or just add submodules to dotfiles)
function ghb() { cln "https://github.com/$1.git"; }
# TODO: guix unfree software: https://gitlab.com/nonguix/nonguix
function gxi() { guix install $@; }
function pac() { sudo pacman -S --needed --noconfirm $@; }

# OS-specific
function tap() { brew tap --quiet; }
function brw() { yes | brew install --force --no-quarantine --overwrite $@; }
function key() { echo $@ | map echo "sudo apt-key adv --fetch-keys"; }
function ppa() { sudo add-apt-repository -yu $1 ; }
function deb() { local D=$(mktemp -d)/t.deb; wget -qO $D $1; ain $D; }
function ain() { sudo DEBIAN_FRONTEND=noninteractive apt-get install -qqy $@; }
function amp() { echo $@ | map aur_makepkg; }
# function apm() { echo $@ | map aur_pacman_install; }
function yyi() { yay  -S --noconfirm --needed $@; }
function pri() { paru -S --noconfirm --needed --pgpfetch $@; }
function aur() { pri $@; }
function nxi() {
  # TODO: some of these flags should hopefully not be necessary once dotfiles are synced
  echo $@ \
    | sed 's/[^ ]* */nixpkgs#&/g' \
    | NIX_REMOTE=daemon xargs nix \
      --use-xdg-base-directories \
      --extra-experimental-features nix-command \
      --extra-experimental-features flakes profile install
}
