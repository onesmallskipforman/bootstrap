# shell functions for configuring and installing various programs

#===============================================================================
# SYSTEM PREPS
#===============================================================================

function prep(){
  bigprint "Prepping For Bootstrap"
  sudo apt -y update --fix-missing && sudo apt -y dist-upgrade
  sudo apt install -y git gcc
  echo "OS Prep Complete."
}

function dotfiles() {
  bigprint "Syncing dotfiles repo to home"

  # dotfile boostrap
  mkdir -p "Home"
  mv -n "$HOME"/{.config,.local,.zshenv} "$1/Home" &>/dev/null
  GHUB="https://github.com/onesmallskipforman"
  DIR=$(realpath $(dirname $0))
  git submodule update --init --recursive

  # symlink
  ln -sf "$DIR/Home"/{.config,.local,.zshenv} "$HOME"
}

#===============================================================================
# INSTALLATIONS
#===============================================================================
# TODO: find a way to use key and apt convenience functions in this bigger function
# TODO: figure out how to pass print info through multiple functions
# TODO: consider allowing for many of these to have pipe input
# IDEA: make everything strings and then run "eval" at the top level
function apt() {
  # while [[ $1 != '-p' ]] || [[ ! -z $1 ]]; do
  #   PKG="$PKG $1"; shift 1 || break;
  # done
  local PKG="$1"; shift
  local OPTARG PPACMD KEYCMD
  while getopts ":p:k:" o; do case "${o}" in
    p) PPACMD="sudo add-apt-repository -yu ${OPTARG}";;
    k) KEYCMD="sudo apt-key adv --fetch-keys ${OPTARG}";;
    *) printf "Invalid option: -%s\\n" "$OPTARG";;
  esac done
  local CMD="sudo apt install -y $PKG"
  [ ! -z "$PPACMD" ] && CMD="$PPACMD && $CMD"
  [ ! -z "$KEYCMD" ] && CMD="$KEYCMD && $CMD"
  echo "$CMD"
}

function nerdfont_install() {
  URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$1.zip"
  echo "wget -q --show-progress $URL && unzip -qod /usr/local/share/fonts && rm $1.zip"
}

function deb_install() {
  DEB=$(basename $1); echo "wget -qod $1 && apt ./$DEB && rm $DEB"
}

function clonepull() {
  # clone, and pull if already cloned from url $1 into dir
  DIR=$HOME/.local/src/$(basename $1 .git)
  [ ! -d "$DIR/.git" ] && echo "git clone --depth 1 '$1' $DIR" || echo "git -C $DIR pull"
}

# function map() { while read -r; do eval "$@ $REPLY"; done } # NOTE: this map only works with newline
function map() { cat | tr ' ' '\n' | while read -r; do eval "$@ $REPLY"; done }
function key() { echo $@ | map echo "sudo apt-key adv --fetch-keys" }
function ndf() { echo $@ | map nerdfont_install }
function pip() { echo "sudo python3 -m pip install -U $@"  }
function deb() { echo $@ | map deb_install }
# function git() { echo $@ | map clonepull }
function ghb() { echo $@ | xargs -n1 -I{} echo "https://github.com/{}.git" | map clonepull }
function ppa() { echo $@ | map echo "sudo add-apt-repository -yu"  }

#===============================================================================
# POST-INSTALL CONFIGS
#===============================================================================

function config() {
  bigprint "Runnung Miscellaneous Post-Package Installs and Configs"

  # default shell to zsh, set os-specific configs
  sudo chsh -s /bin/zsh $(whoami)

  # Set computer name, disable desktop environment, clean installs
  hostnamectl set-hostname SkippersMPB
  sudo systemctl set-default multi-user.target
  sudo apt -y autoremove

  # add user to dialup group from serial coms, and video group for brightness management
  usermod -aG video,dialup $(whoami)

  echo "OS Config Complete. Restart Required"
}

#===============================================================================
# UTILITIES
#===============================================================================

function multiecho(){ for i in {1..67}; do echo -n "$1"; done }
function bigprint() { multiecho '~'; echo -e "\n$1"; multiecho '~'; echo }

function filter() { awk -F '"' '/^'"$1"'/{print $2}' Packages/$OS; }
