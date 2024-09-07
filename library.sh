#===============================================================================
# UTILITIES
#===============================================================================

function multiecho(){ for i in {1..67}; do echo -n "$1"; done; }
function bigprint() { multiecho '~'; echo -e "\n$1"; multiecho '~'; echo; }

function os() {
  if   [ $(uname)           = "Darwin" ]; then echo "osx"
  elif [ $(lsb_release -is) = "Ubuntu" ]; then echo "ubuntu"
  else echo "OS not found"; return 1; fi
}

function supersist() {
  # Ask for the administrator password upfront
  sudo -v

  # Keep-alive: update existing `sudo` time stamp until the script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

function tmpdir() { mktemp -u | xargs dirname; }

function changeUser() {
  # TODO: might need to change shell too with chsh
  local OLD=$1; local NEW=$2
  usermod -l $NEW -m -d /home/$NEW $OLD
  sudo groupmod -n $NEW $OLD
  sudo mv /etc/sudoers.d/$OLD /etc/sudoers.d/$NEW
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
    echo $DOTS/.config
    echo $DOTS/.local/bin
    find $DOTS/.local/share -mindepth 1 -maxdepth 1 \
      -not -path '*.git*' -not -path '*README.md'
    echo $DOTS/.zshenv
  } | sed "s;$DOTS/;;g")

  # find if targets exist and copy their contents to dotfiles
  echo $TARGETS | xargs -r -I{} cp -rT $HOME/{} $DOTS/{} 2>/dev/null
  # remove existing from home
  echo $TARGETS | xargs -I{} sudo rm -rf $HOME/{}
  # ensure directories exist
  echo $TARGETS | xargs -n1 dirname | sort -u | xargs -I{} mkdir -p $HOME/{}
  # symlink dotfiles to home
  echo $TARGETS | xargs -I{} ln -sfn $DOTS/{} $HOME/{}
}

function config() {
  local TZU=https://ipapi.co/timezone
  sudo ln -sfn /usr/share/zoneinfo/$(curl $TZU) /etc/localtime
  local HN=wb-sgonzalez
  echo $HN | sudo tee /etc/hostname >/dev/null # hostnamectl set-hostname $HN
  sudo systemctl set-default multi-user.target
}

#===============================================================================
# LITERALLY JUST ROCKET LEAGUE
#===============================================================================

function steam_install_game() {
  steamcmd +login PopTartasaurus +app_update $1 validate +quit
}

function installBakkesmodPlugin() {
  local DIR=$(mktemp -d)
  local ID=$1
  local C="$HOME/.steam/steam/steamapps/compatdata/252950/pfx/drive_c"
  wget -qO $DIR/plugin.zip "https://bakkesplugins.com/plugins/download/$ID"
  unzip $DIR/plugin.zip 'plugins/*' \
    -d $C/users/steamuser/AppData/Roaming/bakkesmod/bakkesmod
}

function installWorkshopTextures() {
  local URL=https://www.speedrun.com/static/resource/37ylq.zip
  local DIR=$(mktemp -d)
  wget -qO- $URL $DIR/txr.zip
  unzip $DIR/txr.zip \
    -d ~/.steam/steam/steamapps/common/rocketleague/TAGame/CookedPCConsole/
}

# TODO: make function mappable
# TODO: map in one line so you don't have to wrap every function
function installWorkshopMap() {
  local DIR=$(mktemp -d)
  local URL=$1
  local PLG=$(echo $URL | xargs -i basename {} .zip)
  wget -qO $DIR/plg.zip $URL
  unzip $DIR/plg.zip \
    -d ~/.steam/steam/steamapps/common/rocketleague/TAGame/CookedPCConsole/mods/$PLG
}

# TODO: make function mappable
function installWorkshopMapId() {
  local ID=$1
  local DIR=$(mktemp -d)
  local BASE="https://celab.jetfox.ovh/api/v4/projects/$ID/packages"
  local URL=$(wget -qO- $BASE \
    | jq -r '.[] | .package_type+"/"+.name+"/"+.version+"/"+.name+".zip"')
  installWorkshopMap $URL
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

#===============================================================================
# CUSTOM INSTALLATION
#===============================================================================

function install_drivers() {
  # basic version. actually readable
  local BASE=https://download.nvidia.com/XFree86/Linux-x86_64
  local VER=$(wget -qO- $BASE/latest.txt | awk '{print $2}')
  local URL=$BASE/$VER
  local BIN=$(mktemp)
  echo $URL
  wget --show-progress -qO $BIN $URL
  chmod +x $BIN; $BIN -s

  # epic version: identify latest, download latest, run latest. no subshells
  # local URL=https://download.nvidia.com/XFree86/Linux-x86_64
  # { mktemp -d; wget -qO- $URL/latest.txt | awk "{print \"$URL/\"\$2}"; }\
  #   | xargs wget -nv -P 2>&1 | cut -d\" -f2 \
  #   | xargs -o -i sudo sh # gah i guess this is a subshell at the end

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

#===============================================================================
# PACKAGE INSTALLATION
#===============================================================================

nerdfont_install() {
  local URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$1.tar.xz"
  local DIR=$( [ $(uname) = "Darwin" ] \
    && echo ~/Library/Fonts \
    || echo ~/.local/share/fonts)/$(echo $1 | echo $1 | sed 's/.*/\l&/')
  mkdir -p $DIR
  wget -qO- --show-progress $URL | xz -d | tar xvf - -C $DIR --wildcards "*.[ot]tf"
  # wget -qO- --show-progress $URL | tar Jxvf - # NOTE: this version requires gnu tar
}

install_fonts() {
  # TODO: consider https://github.com/getnf/getnf/tree/main
  ndf Hack SourceCodePro UbuntuMono
}

install_getnf() {
  curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash
}

# TODO: relying on env var can make results vary between root and user
function install_texlive() {
  local HOME=~skipper
  local DIR=$(mktemp -d)
  local URL='https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz'
  wget -qO- $URL | tar xvz -C $DIR --strip-components=1
  # TODO: need better way to resolve home paths when running as root
  sudo perl $DIR/install-tl \
    --no-gui \
    --portable \
    --no-interaction \
    --scheme=scheme-infraonly \
    --texdir /usr/local/texlive # \
    # --texmfhome   $HOME/.local/share/texmf \
    # --texmfvar    $HOME/.cache/texlive/texmf-var \
    # --texmfconfig $HOME/.config/texlive/texmf-config

  # update
  # tlmgr update --self
  # tlmgr update --all
  # tlmgr install scheme-full
  # fmtutil-user --missing # add missing fmt files

  # uninstall
  # tlmgr remove --all; sudo rm -rf /usr/local/texlive
}

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

# TODO: replace version with latest
function install_fzf() {
  local URL=https://github.com/junegunn/fzf/archive/refs/tags/v0.55.0.tar.gz
  local DIR=$(mktemp -d)
  wget -qO- $URL | tar xz -C $DIR --strip-components=1
  $DIR/install --bin
  cp $DIR/bin/fzf $HOME/.local/bin 2>/dev/null
}

function install_zathura_pywal() {
  local SHA="f5b6d4a452079d9b2cde070ac3b8c742b6952703"
  local URL="https://github.com/matthewlscarlson/zathura-pywal/archive/$SHA.tar.gz"
  local DIR=$(mktemp -d)
  wget -qO- $URL | tar xz -C $DIR --strip-components=1
  sudo make -C $DIR install
}

function install_ff_extension() {
  local URL="https://addons.mozilla.org/firefox/downloads/latest/$1"
  local DIR=$(mktemp -d)
  local XPI=$DIR/tmp.xpi
  wget -qO $XPI $URL
  local NAME=$(unzip -p $XPI | grep -a '"id": ' | sed -r 's/[\t\n\r," ]//g;s/id://g').xpi
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
  local NAME=$(unzip -p $XPI | grep -a '"id": ' | sed -r 's/[\t\n\r," ]//g;s/id://g').xpi
  local EXTDIR=$(find ~/.thunderbird -name '*.default-release*')/extensions
  mkdir -p $EXTDIR
  cp $XPI $EXTDIR/$NAME
}
# TODO: generalize install ff and tb extensions


# TODO: separate dotfiles sync and profile generation
# function sync_moz_dotfiles() {
#
# }
function ensure_moz_profile() {
  local CMD=$1
  local DIR=$2
  local CFG=$3
  (
    $CMD --headless >/dev/null 2>&1 & #; local PID=$!
    until find $DIR -name '*.default-release*' >/dev/null 2>&1; do sleep 1; done
  )
  local PRF=$(find $DIR -name '*.default-release*')
  find -L $CFG -mindepth 1 -maxdepth 1 | sed "s;$CFG/;;g" | xargs -r -I{} ln -sfn $CFG/{} $PRF/{}
}
function install_ff_profile() {
  ensure_moz_profile firefox $HOME/.mozilla/firefox $HOME/.config/firefox
}
function install_tb_profile() {
  ensure_moz_profile thunderbird $HOME/.thunderbird $HOME/.config/thunderbird
}

# TODO: rewrite so it doesn't keep appending the same line to the file
# TODO: consider using wheel group instead of manaually adding every user
function addSudoers() {
  sudo echo "$(whoami) ALL=(root) NOPASSWD: $1" | sudo tee -a /etc/sudoers.d/$(whoami)
}

function custom_install() { eval install_$1; }


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

function cln() {
  local DIR=$HOME/.local/src/$(basename $1 .git)
  [ -d "$DIR/.git" ] || git clone --depth 1 $1 $DIR
}
function map() { cat | tr ' ' '\n' | while read -r a; do eval "$@ $a"; done; }
function ndf() { echo $@ | map nerdfont_install; }
  # TODO: specify python version for pip install function
function pin() { python3 -m pip install --user --upgrade $@; }
function pix() { sudo pipx install --global $@; }
function ghb() { cln "https://github.com/$1.git" $2; }
function gin() { guix install $@; }
function fcn() { echo $@ | map custom_install; }
function pac() { sudo pacman -S --needed --noconfirm $@; }
function ffe() { echo $@ | map install_ff_extension; }
function tbe() { echo $@ | map install_tb_extension; }

# OS-specific
function tap() { brew tap --quiet; }
function brw() { yes | brew install --force --no-quarantine --overwrite $@; }
function key() { echo $@ | map echo "sudo apt-key adv --fetch-keys"; }
function ppa() { sudo add-apt-repository -yu $1 ; }
function deb() { local D=$(mktemp); wget -qO $D $1; ain $D; }
function ain() { sudo DEBIAN_FRONTEND=noninteractive apt install -qqy $@; }
function amp() { echo $@ | map aur_makepkg; }
function yyi() { yay  -S --noconfirm --needed $@; }
function pri() { paru -S --noconfirm --needed $@; }
function aur() { pri $@; }
