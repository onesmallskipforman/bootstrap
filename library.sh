#===============================================================================
# PRINT UTILITIES
#===============================================================================

function multiecho(){ for i in {1..67}; do echo -n "$1"; done }
function bigprint() { multiecho '~'; echo -e "\n$1"; multiecho '~'; echo }

function os() {
    if   [ $(uname)           = "Darwin" ]; then echo "osx"
    elif [ $(lsb_release -is) = "Ubuntu"     ]; then echo "ubuntu"
    else echo "OS not found"; return 1; fi
}

function supersist() {
    # Ask for the administrator password upfront
    sudo -v

    # Keep-alive: update existing `sudo` time stamp until the script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

function gate() {
    # TODO: currently works with bash and not zsh
    read -p "This may overwrite existing files in ~/. Are you sure? (y/n): " REPLY;
    if [[ $REPLY =~ ^[Yy]$ ]]; then eval "$@"; fi;
}

#===============================================================================
# PREP
#===============================================================================

function dotfiles() {
    # identify files, make directories, copy files
    DOTS="dotfiles"
    FILES=$(find $DOTS -type f -not -path '*.git*' | sed "s/^$DOTS\///g" )
    echo $FILES | xargs -n1 dirname | sort -u | xargs -n1 -I{} mkdir -p ~/{}
    echo $FILES | xargs -n1 -I{} cp dotfiles/{} ~/{}
}

#===============================================================================
# PACKAGE INSTALLATION
#===============================================================================

function brw() {
  local PKG="$1"; shift
  local OPTARG TAPCMD
  while getopts ":t:" o; do case "${o}" in
    t) TAPCMD="brew tap ${OPTARG}";;
    *) printf "Invalid option: -%s\\n" "$OPTARG";;
  esac done
  local CMD="brew instrall $PKG"
  [ ! -z "$TAPCMD" ] && CMD="$TAPCMD && $CMD"
  echo "$CMD"
}

function apt() {
  local PKG="$1"; shift; local OPTARG PPACMD KEYCMD
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

nerdfont_install() {
  URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$1.zip"
  wget -q --show-progress $URL && unzip -qod /usr/local/share/fonts && rm $1.zip
}

function clonepull() {
  # clone, and pull if already cloned from url $1 into dir
  DIR=$HOME/.local/src/$(basename $1 .git)
  [ ! -d "$DIR/.git" ] && echo "git clone --depth 1 '$1' $DIR" || echo "git -C $DIR pull"
}

function texlive_configure() {
    sudo tlmgr update --self
    sudo tmlgr install \
        latexmk \
        xelatex \
        preprint \
        titlesec \
        helvetic \
        enumitem \
        xifthen \
        relsize \
        multirow
}

function map() { cat | tr ' ' '\n' | while read -r; do eval "$@ $REPLY"; done }
function key() { echo $@ | map echo "sudo apt-key adv --fetch-keys" }
function ndf() { echo $@ | map nerdfont_install }
function pin() { python3 -m pip install --user -U $@ }
function deb() { DEB=$(basename $1); wget -qod $1 && apt ./$DEB && rm $DEB }
function ghb() { echo $@ | xargs -n1 -I{} echo "https://github.com/{}.git" | map clonepull }
function ppa() { echo $@ | map echo "sudo add-apt-repository -yu"  }
