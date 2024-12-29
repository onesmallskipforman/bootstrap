#!/bin/sh

case "$1" in
  arch)   IMG=archlinux;;
  ubuntu) IMG=ubuntu:24.04;;
  artix)  IMG=artixlinux/artixlinux;; # IMG=artixlinux/artixlinux:base
  *)      echo "Not a valid OS"; exit 1;;
esac

docker run \
  --rm -it \
  -v ~/Projects/bootstrap:/root/bootstrap \
  -w /root/bootstrap  \
  $IMG /bin/bash
  # $IMG ./run.sh
