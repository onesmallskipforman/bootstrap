#!/usr/bin/bash

# script that compares packages in install scripts to packages on the system

###############################################################################
# HELPERS
###############################################################################

function title() { echo -e "\033[1;36m==> ${1}\033[0m"; }

function line() {
  local -r CHAR=$1
  # https://stackoverflow.com/a/5349796
  printf %$(tput cols)s |tr " " "$CHAR"
}

function track() {
  local -r CMD=$1 # package command

  # cat file
  # convert multi-line commands into single-line
  # remove strings, comments, and flags
  # replace statement separators with newlines
  # (hack) replace 'amp' with 'aur'
  # filter for all instances of using CMD
  # convert lines with multiple packages into separate lines
  # remove empty lines
  cat $ID.sh \
    | sed -z 's;\\\n; ;g' \
    | sed -e 's/"[^"]*"//g' -e "s/'[^']*'//g" -e 's/#.*//g' -e 's/ -[^ ]*//g' \
    | sed -E 's/(&&|\|\||;)/\n/g' \
    | sed -E 's/(^| )amp / aur /g' \
    | grep -oE "(^| )$CMD [^|&;]*" \
    | sed "s/^ *$CMD //g" \
    | tr ' ' '\n' | awk NF
}

function missing() {
  local -r PKG=$1 # package type
  local -r COL=$( [ $2 = 'script' ] && echo 2 || { [ $2 = 'system' ] && echo 1; })

  # NOTE: util-linux >2.41 required so column command can handle escape sequences
  comm -${COL}3 \
    <(track          $PKG | sort -u) \
    <(list_installed_$PKG | sort -u)
}

function compare() {
  local -r PKG=$1 # package type
  local -r TITLE=$(describe $PKG)

  title "$TITLE: only in script"
  missing "$PKG" script | xargs -I{} echo -e '\033[1;37m{}\033[m'| column
  echo
  title "$TITLE: only on system"
  missing "$PKG" system | xargs -I{} echo -e '\033[1;37m{}\033[m'| column
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
function clean_ppa() { true; }

# APT
function list_installed_ain() {
  comm -23 <(apt-mark showmanual | sort -u) \
           <(gzip -dc /var/log/installer/initial-status.gz \
              | sed -n 's/^Package: //p' | sort -u)
  # apt-mark showmanual | sort -u
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
function clean_aur         () { paru -Qdtq | xargs -r paru -Rnsu --noconfirm ; }

# PACMAN
function list_installed_pac() { pacman -Qqen; }
function clean_pac         () { pacman -Qdtq | xargs -r sudo pacman -Rnsu --noconfirm; }

# utilities
function describe() {
  local -r PKG=$1
  case $PKG in
    nxi) echo "Nix Packages"           ;;
    ppa) echo "PPA Repositories"       ;;
    ain) echo "Apt Packages"           ;;
    pac) echo "Native Pacman Packages" ;;
    aur) echo "Aur Packages"           ;;
  esac
}

function cleanup() { local -r PKG=$1; clean_$PKG; }

function add() {
  case $1 in
    nxi) nix profile install               nixpkgs#$2 ;;
    pac) sudo pacman -Syu --noconfirm --asexplicit $2 ;;
    aur) paru        -Syu --noconfirm --asexplicit $2 ;;
    *) : ;;
  esac
}

function rem() {
  # TODO: add apt-mark command to mark package as a dep
  case $1 in
    nxi) nix profile remove           $2 ;;
    pac) sudo pacman -Rsn --noconfirm $2 || sudo pacman -D --asdeps $2 ;;
    aur) paru        -Rsn --noconfirm $2 || sudo paru   -D --asdeps $2 ;;
    *) : ;;
  esac
}

function update() {
  case $1 in
    nxi) nix profile upgrade --all    ;;
    pac) sudo pacman -Syu --noconfirm ;;
    aur) paru        -Syu --noconfirm ;;
    *) : ;;
  esac
}

###############################################################################
# distros
###############################################################################

function packages_ubuntu() { echo ain nxi ppa; }
function packages_arch  () { echo nxi aur pac; }

###############################################################################
# higher-order functions
###############################################################################

function map() { tr ' ' '\n' | while read -r a; do "$@" "$a"; done; }

function syncup() { local -r PKG=$1; missing $PKG script | map add $PKG; }
function revert() { local -r PKG=$1; missing $PKG system | map rem $PKG; }

function compare_os() { packages_$ID | map compare; }
function cleanup_os() { packages_$ID | map cleanup; }
function syncup_os () { packages_$ID | map syncup ; }
function revert_os () { packages_$ID | map revert ; }

# guix package --list-installed
# guix gc

# track fonts
# fc-list ':' file # TODO: not really usre what "':' file" does
# fc-list

# get font name
# fc-query -f '%{family[0]}\n' <path-to-font-file>

# helpful
# nix search nixpkgs 'nerd-fonts\.' --json | jq -r '. | keys[]' | fzf | xargs -I{} nix profile install nixpkgs#{}


# NOTE: pacman package database needs to be synced as well with pacman -Fy

###############################################################################
# SCRIPT
###############################################################################


# TODO: consider not using globals
readonly ID=$(. /etc/os-release && echo $ID)
case $1 in
  compare) compare_os $ID ;;
  cleanup) cleanup_os $ID ;;
  syncup ) syncup_os  $ID ;;
  revert ) revert_os  $ID ;;
  *) echo 'track (compare|cleanup)'; exit 1 ;;
esac
