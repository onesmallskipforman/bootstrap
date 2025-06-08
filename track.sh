#!/usr/bin/zsh

# script that compares packages listed in install scripts to packages installed
# on the system

function track() {
  OS=$1
  CMD=$2
  cat $OS.sh \
    | grep -o "$CMD [^#;]*" \
    | sed "s/^$CMD //g" \
    | sed 's/ *$//g' \
    | tr ' ' '\n'
}

function compare() {
  PKG=$1; OS=$2
  comm -13 \
      <(track ubuntu $PKG | sort -u) \
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
  nix profile list --json | jq -r '.elements | keys[]'
}
function listInstalledAur() { pacman -Qm; }
function listInstalledPac() { pacman -Qn; }

echo "Comparing Nix Packages:"
compare nxi
echo
echo "Compare PPA Repositories:"
compare ppa
echo
echo "Compare Apt Packages:"
compare ain
echo
echo "Compare Aur Packages:"
compare aur
echo
echo "Compare Native Pacman Packages:"
compare pac

# local OS=$(. /etc/os-release && echo $ID)



# command to list reverse deps of manually-installed packages
# using apt-mark auto <package> should be sufficient to deal with any reverse dependencies
# that need to keep the package around
# compare Apt | xargs -L1 apt-cache rdepends --installed | sed 's/^[a-z]/\n&/g' > deps.txt

# sudo du -ca -BG -tG --max-depth=1 / 2>/dev/null | sort -nr


# guix package --list-installed
# guix gc
# nix profile list
# nix-collect-garbage
