#!/usr/bin/zsh
# function pac() { echo $@ > pac.txt; }
# function aur() { echo $@ > aur.txt; }
# function pxi() { echo $@ > pxi.txt; }


function track() {
  OS=$1
  CMD=$2
  cat $OS.sh \
    | grep -o "$CMD [^#;]*" \
    | sed "s/^$CMD //g" \
    | sed 's/ *$//g' \
    | tr ' ' '\n'
}

function trackPacman() {
  track arch pac
}

function trackAur() {
  track arch aur
  track arch amp
}


function trackPpa() {
  # track ubuntu ain
  track ubuntu ppa
}

function trackApt() {
  track ubuntu ain
}


function listInstalledPpa() {
  # TODO: does not cover multiverse and universe
  cat /etc/apt/sources.list /etc/apt/sources.list.d/* \
    | grep '^[^#]' \
    | grep ppa \
    | grep -o 'https[^ ]*' \
    | awk -F'/' '{print "ppa:"$4"/"$5}'
}

function listInstalledApt() {
  # TODO: does not cover multiverse and universe
  comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)
}


function compareApt() {
  comm -13 <(trackApt | sort -u) <(listInstalledApt)
}

# trackApt | sort -u
# echo
# listInstalledPpa
# echo
# comm -13 <(trackPpa | sort -u) <(listInstalledPpa)
# echo
compareApt

# {
#   trackApt
# } | sort -u

# command to list reverse deps of manually-installed packages
# using apt-mark auto <package> should be sufficient to deal with any reverse dependencies
# that need to keep the package around
# ./track.sh | xargs -L1 apt-cache rdepends --installed | sed 's/^[a-z]/\n&/g' > deps.txt
