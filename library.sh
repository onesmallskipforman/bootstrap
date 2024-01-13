#===============================================================================
# PRINT UTILITIES
#===============================================================================

function multiecho(){ for i in {1..67}; do echo -n "$1"; done }
function bigprint() { multiecho '~'; echo -e "\n$1"; multiecho '~'; echo }

#===============================================================================
# PREP
#===============================================================================

function dotfiles() {

  # dotfile boostrap
  mv -n "$HOME"/{.config,.local,.zshenv} "$1/Home" &>/dev/null
  DIR=$(realpath $(dirname $0))
  git submodule update --init --recursive # --remote

  # symlink
  ln -sf "$DIR/dotfiles"/{.config,.local,.zshenv} "$HOME"
}

#===============================================================================
# PACKAGE INSTALLATION
#===============================================================================

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
