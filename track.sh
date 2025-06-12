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
  local -r SRC=$1 # script source
  local -r CMD=$2 # package command

  # steps:
  #   cat file
  #   reformat multi-line shell commands as single-line
  #   (hack) replace 'amp' with 'aur'
  #   replace command delimeters with spaces
  #   find all occurances of $CMD
  #   remove flag arguments
  #   remove $CMD prefix from results
  #   remove trailing whitespace
  #   reduce extra spacing between packages to single spaces
  #   convert lines with multiple packages into separate lines
  echo "$SRC" \
    | sed -z 's;\\\n;;g' \
    | sed 's/\(^\|[ ;|&]\+\)amp /aur /g' \
    | sed "s/[;|&]\+$CMD / $CMD /g" \
    | grep -o "\(^\| \)$CMD [^#;&|]*" \
    | sed 's/ --[^ ]*//g' \
    | sed "s/^ *$CMD //g" \
    | sed 's/ *$//g' \
    | sed 's/ \+/ /g' \
    | tr ' ' '\n'
}

function missing() {
  local -r PKG=$1 # package type
  local -r SRC=$2 # script source
  COL=$( [ $3 = 'script' ] && echo 2 || { [ $3 = 'system' ] && echo 1; })

  # NOTE: util-linux >2.41 required so column command can handle escape sequences
  comm -${COL}3 \
    <(track "$SRC" $PKG     | sort -u) \
    <(list_installed_${PKG} | sort -u)
}

function compare() {
  local -r SRC=$1 # script source
  local -r PKG=$2 # package type
  local -r TITLE=$(describe $PKG)

  title "$TITLE: only in script"
  missing "$PKG" "$SRC" script | xargs -I{} echo -e '\033[1;37m{}\033[m'| column
  echo
  title "$TITLE: only on system"
  missing "$PKG" "$SRC" system | xargs -I{} echo -e '\033[1;37m{}\033[m'| column
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
function clean_aur         () { paru -Qdtq | xargs -r paru -Rnsu ; }

# PACMAN
function list_installed_pac() { pacman -Qqen; }
function clean_pac         () { pacman -Qdtq | xargs -r sudo pacman -Rnsu; }

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

function cleanup() { local -r PKG=$1; clean_$PKG; }

function add() {
  case $1 in
    nxi) nix profile install nixpkgs#$2 ;;
    pac) sudo pacman -Sy             $2 ;;
    aur) paru -Sy                    $2 ;;
    *) : ;;
  esac
}

function rem() {
  case $1 in
    nxi) nix profile remove $2 ;;
    pac) sudo pacman -Rsnu  $2 ;;
    aur) paru -Rsnu         $2 ;;
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

function map() { cat | tr ' ' '\n' | while read -r a; do "$@" "$a"; done; }

function syncup() { local -r PKG=$1; missing $PKG "$SH" script | map add $PKG; }
function revert() { local -r PKG=$1; missing $PKG "$SH" system | map rem $PKG; }

function compare_os() { packages_$ID | map compare "$(cat $ID.sh)"; }
function clean_os  () { packages_$ID | map cleanup                ; }
function syncup_os () { packages_$ID | map syncup                 ; }
function revert_os () { packages_$ID | map revert                 ; }


###############################################################################
# SCRIPT
###############################################################################

# TODO: consider not using globals
readonly ID=$(. /etc/os-release && echo $ID)
readonly SH="$(cat $ID.sh)"
case $1 in
  compare) compare_os $ID ;;
  clean  ) clean_os   $ID ;;
  syncup ) syncup_os  $ID ;;
  revert ) revert_os  $ID ;;
  *) echo 'track (compare|cleanup)'; exit 1 ;;
esac

# TODO: use 'read -r'
# see 'man read'
# example: echo a | read -r var

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
