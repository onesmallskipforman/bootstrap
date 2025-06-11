#!/usr/bin/bash

# script that compares packages in install scripts to packages on the system

###############################################################################
# HELPERS
###############################################################################

function title() { echo -e "\033[1;36m==> ${1}\033[0m"; }

function track() {
  local -r OS=$1
  local -r CMD=$2

  # steps:
  #   cat file
  #   reformat multi-line shell commands as single-line
  #   (hack) replace 'amp' with 'aur'
  #   replace command delimeters with spaces
  #   find all occurances of $CMD
  #   remove flag arguments
  #   remove $CMD prefix from results
  #   remove trailing whitespace
  #   convert lines with multiple packages into separate lines
  cat $OS.sh \
    | sed -z 's;\\\n;;g' \
    | sed 's/\(^\|[ ;|&]\+\)amp /aur /g' \
    | sed "s/[;|&]\+$CMD / $CMD /g" \
    | grep -o "\(^\| \)$CMD [^#;&|]*" \
    | sed 's/ --[^ ]*//g' \
    | sed "s/^ *$CMD //g" \
    | sed 's/ *$//g' \
    | tr ' ' '\n'
}

function commshortcut() {
  local -r PKG=$1
  local -r OS=$2
  local -r OMITCOLUMN=$3

  # NOTE: util-linux >2.41 required so column command can handle escape sequences
  comm -${OMITCOLUMN}3 \
    <(track $OS $PKG       | sort -u) \
    <(list_installed_${PKG} | sort -u) \
    | xargs -I{} echo -e '\033[1;37m{}\033[m' \
    | column
}

function line() {
  local -r CHAR=$1
  # https://stackoverflow.com/a/5349796
  printf %$(tput cols)s |tr " " "$CHAR"
}

function compare() {
  local -r PKG=$1
  local -r OS=$2
  local -r TITLE=$(describe $PKG)

  # line '='
  title "$TITLE: only in script"
  # line '-'
  commshortcut $PKG $OS 2
  echo
  title "$TITLE: only on system"
  # line '-'
  commshortcut $PKG $OS 1
}

function compare_multiple() {
  local -r OS=$1; shift
  local -r PKGS=$@
  echo $PKGS | tr ' ' '\n' | while read -r a; do compare "$a" $OS; done
}

###############################################################################
# PACKAGE MANAGERS
###############################################################################

# PPA
function list_installed_ppa() {
  # NOTE: add-apt-repository --list is much slower and doesn't show some lists
  cat /etc/apt/sources.list /etc/apt/sources.list.d/* \
    | grep '^[^#]' | grep -o 'http[^ ]*\|universe\|multiverse' \
    | grep 'ppa\|universe\|multiverse' | sort -u \
    | awk -F'/' '/ppa/{print "ppa:"$4"/"$5} !/ppa/{print $1}';
}

# APT
function list_installed_ain() {
  # comm -23 <(apt-mark showmanual | sort -u) \
  #          <(gzip -dc /var/log/installer/initial-status.gz
  #             | sed -n 's/^Package: //p' | sort -u)
  apt-mark showmanual | sort -u
}
function clean_ain() { sudo apt autopurge -y; }

# NIX
function list_installed_nxi() {
  nix profile list --json \
    | jq -r '.elements[].attrPath' \
    | sed 's/legacyPackages\.x86_64-linux\.//g'
}
function clean_nxi() { nix-collect-garbage; nix-collect-garbage -d; }

# AUR
# NOTE: these will not catch when groups are installed instead of packages
# groups are tricky because you can't filter for explicitly-installed groups
function list_installed_aur() { pacman -Qqem; }
function clean_aur         () { paru -Qdtq   | paru -Rnsu -; }

# PACMAN
function list_installed_pac() { pacman -Qqen; }
function clean_pac         () { pacman -Qdtq | pacman -Rnsu -; }

# utilities
function describe() {
  # local -r PKG=$(cat)
  local -r PKG=$1
  case $PKG in
    nxi) echo "Nix Packages"           ;;
    ppa) echo "PPA Repositories"       ;;
    ain) echo "Apt Packages"           ;;
    pac) echo "Native Pacman Packages" ;;
    aur) echo "Aur Packages"           ;;
  esac
}

function cleanup_multiple() {
  local -r PKGS=$@
  echo $PKGS | tr ' ' '\n' | while read -r a; do clean_"$a"; done
}

###############################################################################
# DISTROS
###############################################################################

# TODO: pass in contents of ubuntu.sh to make this more purely functional
function compare_ubuntu() { compare_multiple ubuntu ain nxi ppa; }
function cleanup_ubuntu() { cleanup_multiple        ain nxi    ; }

function compare_arch() { compare_multiple arch nxi aur pac; }
function cleanup_arch() { compare_multiple      nxi aur pac; }

###############################################################################
# SCRIPT
###############################################################################

readonly ID=$(. /etc/os-release && echo $ID)

case $1 in
  compare) compare_$ID ;;
  cleanup) cleanup_$ID   ;;
  *) echo 'track (compare|cleanup)'; exit 1 ;;
esac

# command to list reverse deps of manually-installed packages
# using apt-mark auto <package> should be sufficient to deal with any reverse dependencies
# that need to keep the package around
# compare Apt | xargs -L1 apt-cache rdepends --installed | sed 's/^[a-z]/\n&/g' > deps.txt

# sudo du -ca -BG -tG --max-depth=1 / 2>/dev/null | sort -nr


# guix package --list-installed
# guix gc
# nix profile list
# nix-collect-garbage

# sudo apt autopurge
# pacman -Qdtq | xargs pacman -Rsnu --noconfirm
# paru -Qdtq | xargs paru -Rsnu --noconfirm




# track fonts
# fc-list ':' file # TODO: not really usre what "':' file" does
# fc-list

# get font name
# fc-query -f '%{family[0]}\n' <path-to-font-file>

# helpful
# nix search nixpkgs 'nerd-fonts\.' --json | jq -r '. | keys[]' | fzf | xargs -I{} nix profile install nixpkgs#{}
