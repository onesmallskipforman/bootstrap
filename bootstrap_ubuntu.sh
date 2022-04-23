# shell functions for configuring and installing various programs

#===============================================================================
# SYSTEM PREPS
#===============================================================================

# function bootstrap_ubuntu() {
#   bigprint "Prepping For Bootstrap"
#   sudo apt -y update --fix-missing && sudo apt -y dist-upgrade
#   sudo apt install -y git gcc
#   echo "OS Prep Complete."
#
#   dotfiles
#
# }

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
  git submodule add -b "$GHUB/dotfiles.git"  "$DIR/Home"
  git submodule add -b "$GHUB/userdata.git"  "$DIR/Home/.local/share"
  git submodule update

  # symlink
  ln -sf "$DIR/Home"/{.config,.local,.zshenv} "$HOME"
}



#===============================================================================
# INSTALLATIONS
#===============================================================================

function apt_ppa() {
  while getopts ":a:r:b:p:h" o; do case "${o}" in
    h) printf "Optional arguments for custom use:\\n  -r: Dotfiles repository (local file or url)\\n  -p: Dependencies and programs csv (local file or url)\\n  -a: AUR helper (must have pacman-like syntax)\\n  -h: Show this message\\n" && exit 1 ;;
    r) dotfilesrepo=${OPTARG} && git ls-remote "$dotfilesrepo" || exit 1 ;;
    b) repobranch=${OPTARG} ;;
    p) progsfile=${OPTARG} ;;
    a) aurhelper=${OPTARG} ;;
    *) printf "Invalid option: -%s\\n" "$OPTARG" && exit 1 ;;
  esac done
}

function apt_ppa() {
  while getopts ":p" o; do case "${o}" in
    p) progsfile=${OPTARG} ;;
    *) printf "Invalid option: -%s\\n" "$OPTARG" && exit 1 ;;
  esac done
}


function lambda() { while read -r; do eval "$@ $REPLY"; done }

function key() { echo $@ | lambda sudo apt-key adv --fetch-keys }
function ppa() { echo $@ | lambda sudo add-apt-repository -y    }
function ndf() { echo $@ | lambda nerdfont_install              }
function pip() { sudo python3 -m pip install -U $@              }
function deb() { echo $@ | lambda deb_install                   }
function git() { echo $@ | lambda clonepull                     }
function apt() { sudo apt install -y $@                         }

function pkg_install() {
  bigprint "Installing Packages."; source Packages/$OS; echo "Complete."
}

function nerdfont_install() {
  wget -q --show-progress \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$arg.zip \
    && unzip -qod /usr/local/share/fonts && rm $arg.zip
}

function deb_install() {
  DEB=$(basename $1); wget -qod $1 && apt ./$DEB && rm $DEB
}

function clonepull() {
  # clone, and pull if already cloned from url $1 into dir
  DIR=$HOME/.local/src/$(basename $1 .git)
  [ ! -d "$DIR/.git" ] && git clone --depth 1 "$1" "$DIR" || git -C "$DIR" pull
  # git clone --depth 1 "$1" "$DIR" >/dev/null 2>&1 || git -C "$DIR" pull
}

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
# MISCELLANEOUS
#===============================================================================


#===============================================================================
# UTILITIES
#===============================================================================

function multiecho(){ for i in {1..67}; do echo -n "$1"; done }
function bigprint() { multiecho '~'; echo -e "\n$1"; multiecho '~'; echo }

function filter() { awk -F '"' '/^'"$1"'/{print $2}' Packages/$OS; }
