#!/bin/sh

case "$1" in
  arch)   IMG=archlinux;;
  ubuntu) IMG=ubuntu:24.04;;
  *)      echo "Not a valid OS"; exit 1;;
esac

docker run \
  --rm -it \
  -v ~/Projects/bootstrap:/root/bootstrap \
  -w /root/bootstrap  \
  $IMG /bin/bash -c './run.sh; exec /bin/bash'
