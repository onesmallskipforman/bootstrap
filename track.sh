#!/usr/bin/bash

# script that compares packages listed in install scripts to packages installed
# on the system

function title() {
  echo -e "\033[1;32m==> ${1}\033[0m"
}

function track() {
  local OS=$1
  local CMD=$2

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

# NOTE: util-linux >2.41 required as the column command can handle color escape sequences

function compare() {
  local PKG=$1
  local OS=$2
  local OMITCOLUMN=$3

  comm -3 \
    <(track $OS $PKG | sort -u) \
    <(listInstalled$(echo $PKG | sed 's/^./\u&/g') 2>/dev/null | sort -u)

}

function listInstalledPpa() {
  # TODO: does not cover multiverse and universe
  cat /etc/apt/sources.list /etc/apt/sources.list.d/* \
    | grep '^[^#]' \
    | grep ppa \
    | grep -o 'https[^ ]*' \
    | awk -F'/' '{print "ppa:"$4"/"$5}'
}

function listInstalledAin() {
  # TODO: does not cover multiverse and universe
  comm -23 \
    <(apt-mark showmanual | sort -u) \
    <(
        gzip -dc /var/log/installer/initial-status.gz \
          | sed -n 's/^Package: //p' \
          | sort -u
    )
}

function listInstalledNxi() {
  nix profile list --json \
    | jq -r '.elements[].attrPath' \
    | sed 's/legacyPackages\.x86_64-linux\.//g'
}

# NOTE: these will not catch when groups are installed instead of packages
# groups are tricky because you can't filter for explicitly-installed groups
function listInstalledAur() { pacman -Qqem; }
function listInstalledPac() { pacman -Qqen; }

OS=$(. /etc/os-release && echo $ID)
echo "==> Comparing Nix Packages:"
compare nxi $OS
echo
echo "==> Compare PPA Repositories:"
compare ppa $OS
echo
echo "==> Compare Apt Packages:"
compare ain $OS
echo
echo "==> Compare Aur Packages:"
compare aur $OS
echo
echo "==> Compare Native Pacman Packages:"
compare pac $OS




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
