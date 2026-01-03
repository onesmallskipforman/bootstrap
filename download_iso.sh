#!/bin/sh
set -euxo pipefail # https://stackoverflow.com/questions/2870992/automatic-exit-from-bash-shell-script-on-error

case "$ID" in
  arch)   URL=https://mirrors.mit.edu/archlinux/iso/2025.10.01/archlinux-x86_64.iso;;
  ubuntu) URL=https://mirrors.mit.edu/ubuntu-releases/24.04/ubuntu-24.04.3-live-server-amd64.iso;;
  *)      echo "Not a valid OS"; exit 1;;
esac

wget -qO- $URL | sudo dd of=/dev/sda bs=4M status=progress
sync
