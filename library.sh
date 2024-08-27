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

tmpdir() { mktemp -u | xargs dirname; }


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
  local HOME=${1:-$HOME}
  # id all desired top-level targets
  local DOTS="$(realpath dotfiles)"
  local TARGETS=$(cat \
    <(find $DOTS/.config      -mindepth 1 -maxdepth 1) \
    <(find $DOTS/.local/bin   -mindepth 1 -maxdepth 1)  \
    <(find $DOTS/.local/share -mindepth 1 -maxdepth 1)  \
    <(find $DOTS -maxdepth 1 -type f -not -path '*.git*' -not -path '*README.md') \
    | sed "s;$DOTS/;;g")
  # find if targets exist and copy their contents to dotfiles
  printf '%s\n' $TARGETS | xargs -I{} find $HOME \( -type f -o -type d \) -wholename $HOME/{} | sed "s;$HOME/;;g" | xargs -I{} cp -rT $HOME/{} $DOTS/{}
  # remove existing from home
  printf '%s\n' $TARGETS | xargs -I{} sudo rm -rf $HOME/{}
  # ensure directories exist
  printf '%s\n' $TARGETS | xargs -n1 dirname | sort -u | xargs -I{} mkdir -p $HOME/{}
  # symlink dotfiles to home
  printf '%s\n' $TARGETS | xargs -I{} ln -sf $PWD/dotfiles/{} $HOME/{}
}

#===============================================================================
# PACKAGE INSTALLATION
#===============================================================================

nerdfont_install() {
  local URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$1.tar.xz"
  local DIR=$( [ $(uname) = "Darwin" ] && echo ~/Library/Fonts || echo ~/.local/share/fonts)/$(echo $1 | echo $1 | sed 's/.*/\l&/')
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
function install_fzf() {
  local URL=https://github.com/junegunn/fzf/archive/refs/tags/v0.54.3.tar.gz
  local DIR=$(mktemp -d)
  wget -qO- $URL | tar xz -C $DIR --strip-components=1
  $DIR/install --all --xdg --completion
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

function addSudoers() {
  sudo echo "$(whoami) ALL=(root) NOPASSWD: $1" | sudo tee -a /etc/sudoers.d/$(whoami)
}

function custom_install() { eval install_$1; }

function cln() {
  local DIR=$HOME/.local/src/$(basename $1 .git)
  [ -d "$DIR/.git" ] || git clone --depth 1 $1 $DIR
}
function tap() { brew tap --quiet; }
function brw() { yes | brew install --force --no-quarantine --overwrite $@; }
function map() { cat | tr ' ' '\n' | while read -r a; do eval "$@ $a"; done; }
function key() { echo $@ | map echo "sudo apt-key adv --fetch-keys"; }
function ndf() { echo $@ | map nerdfont_install; }
  # TODO: specify python version for pip install function
function pin() { python3 -m pip install --user --upgrade $@; }
function pix() { pipx install --global $@; }
function deb() { local D=$(mktemp); wget -qO $D $1; ain $D; }
function ghb() { cln "https://github.com/$1.git" $2; }
function ppa() { sudo add-apt-repository -yu $1 ; }
function ain() { sudo DEBIAN_FRONTEND=noninteractive apt install -qqy $@; }
function gin() { guix install $@; }
function fcn() { echo $@ | map custom_install; }
function pac() { sudo pacman -S --noconfirm $@; }
function ffe() { echo $@ | map install_ff_extension; }
function tbe() { echo $@ | map install_tb_extension; }
