#===============================================================================
# PRINT UTILITIES
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

function gate() {
    # NOTE: currently works with bash and not zsh
    read -p "This may overwrite existing files in ~/. Are you sure? (y/n): " REPLY;
    [[ $REPLY =~ ^[Yy]$ ]] || return 1
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
  # id all desired top-level targets
  DOTS="$(realpath dotfiles)"
  TARGETS=$(cat \
    <(find $DOTS/.config -mindepth 1 -maxdepth 1) \
    <(find $DOTS/.local  -mindepth 1 -maxdepth 1)  \
    <(find $DOTS -type f -mindepth 1 -maxdepth 1 -not -path '*.git*' -not -path '*README.md') \
    | sed "s;$DOTS/;;g")
  # find if targets exist and copy their contents to dotfiles
  echo $TARGETS | xargs -n1 -I{} find ~/{} \( -type f -o -type d \) -wholename ~/{} | sed "s;$HOME/;;g" | xargs -n1 -I{} cp -rT $HOME/{} $DOTS/{}
  # remove existing from home
  echo $TARGETS | xargs -n1 -I{} sudo rm -rf ~/{}
  # ensure directories exist
  echo $TARGETS | xargs -n1 dirname | sort -u | xargs -n1 -I{} mkdir -p ~/{}
  # symlink dotfiles to home
  echo $TARGETS | xargs -n1 -I{} ln -sf $PWD/dotfiles/{} ~/{}
}

#===============================================================================
# PACKAGE INSTALLATION
#===============================================================================

# function ain() {
#   local PKG="$1"; shift; local OPTARG PPACMD KEYCMD
#   while getopts ":p:k:" o; do case "${o}" in
#     p) PPACMD="sudo add-apt-repository -yu ${OPTARG}";;
#     k) KEYCMD="sudo apt-key adv --fetch-keys ${OPTARG}";;
#     *) printf "Invalid option: -%s\\n" "$OPTARG";;
#   esac done
#   local CMD="sudo apt install -y -f $PKG"
#   [ ! -z "$PPACMD" ] && CMD="$PPACMD && $CMD"
#   [ ! -z "$KEYCMD" ] && CMD="$KEYCMD && $CMD"
#   eval "$CMD"
# }



nerdfont_install() {
  local URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$1.tar.xz"
  mkdir -p ~/.local/share/fonts
  wget -qO- --show-progress $URL | xz -d | tar xvf - -C ~/.local/share/fonts
  # wget -qO- --show-progress $URL | tar Jxvf - -C ~/.local/share/fonts # NOTE: this version requires gnu tar
}

function texlive_configure() {
    sudo tlmgr update --self
    sudo tlmgr install \
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

function addSudoers() {
  sudo echo "$(whoami) ALL=(root) NOPASSWD: $1" | sudo tee /etc/sudoers.d/$(whoami)
}


function cln() {
  DIR=$HOME/.local/src/$(basename $1 .git)
  [ -d "$DIR/.git" ] || git clone --depth 1 $1 $DIR
}
function tap() { brew tap --quiet; }
function brw() { yes | brew install --force --no-quarantine --overwrite $@; }
function map() { cat | tr ' ' '\n' | while read -r; do eval "$@ $REPLY"; done; }
function key() { echo $@ | map echo "sudo apt-key adv --fetch-keys"; }
function ndf() { echo $@ | map nerdfont_install; }
  # TODO: specify python version for pip install function
function pin() { python3 -m pip install --user --upgrade $@; }
function deb() { T=$(mktemp -d) wget -qO $T/deb $1 && ain $T/deb && rm -r $T; }
function ghb() { cln "https://github.com/$1.git" $2; }
function ppa() { echo $@ | map "sudo add-apt-repository -yu" ; }
function ain() { sudo apt install $@; }
function gin() { guix install $@; }
function fcn() { echo install_$@; } # TODO: make this mappable
