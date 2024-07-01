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

nerdfont_install() {
  local URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$1.tar.xz"
  local DIR=~/.local/share/fonts/$(echo $1 | sed 's/.*/\L&/')
  mkdir -p $DIR
  wget -qO- --show-progress $URL | xz -d | tar xvf - -C $DIR --wildcards "*.[ot]tf"
  # wget -qO- --show-progress $URL | tar Jxvf - # NOTE: this version requires gnu tar
}

install_fonts() {
  # TODO: reduce fonts
  # TODO: consider https://github.com/getnf/getnf/tree/main
  ndf Hack DejaVuSansMono FiraCode RobotoMono SourceCodePro UbuntuMono
}

install_getnf() {
  curl -fsSL https://raw.githubusercontent.com/getnf/getnf/main/install.sh | bash
}

function install_texlive() {
  local DIR=$(mktemp -d)
  local URL='https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz'
  wget -qO- $URL | tar xvz -C $DIR --strip-components=1
  perl $DIR/install-tl \
    --no-gui \
    --no-interaction \
    --scheme=scheme-minimal \
    --texdir      ~/.local/texlive \
    --texmfhome   ${XDG_DATA_HOME:-~/.local/share}/texm \
    --texmfvar    ${XDG_CACHE_HOME:-~/.cache}/texlive/texmf-var \
    --texmfconfig ${XDG_CONFIG_HOME:-~/.config}/texlive/texmf-config

  tlmgr update --self
  tlmgr update --all
  tlmgr install \
    latexmk xetex preprint titlesec helvetic enumitem xifthen relsize multirow

  # uninstall
  # tlmgr remove --all; rm -rf  ~/.local/texlive
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
function deb() { T=$(mktemp -d) wget -qO $T/t.deb $1 && ain $T/t.deb && rm -r $T; }
function ghb() { cln "https://github.com/$1.git" $2; }
function ppa() { sudo add-apt-repository -yu $1 ; }
function ain() { sudo apt install -y $@; }
function gin() { guix install $@; }
function fcn() { eval install_$@; } # TODO: make this mappable
