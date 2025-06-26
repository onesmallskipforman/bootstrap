#!/bin/sh
set -euxo pipefail # https://stackoverflow.com/questions/2870992/automatic-exit-from-bash-shell-script-on-error

case "$1" in
  arch)   IMG=archlinux:base;;
  ubuntu) IMG=ubuntu:24.04;;
  *)      echo "Not a valid OS"; exit 1;;
esac

docker build --build-arg BASE=$IMG --build-arg OS=$1 -t dfile -f dockerfile .
docker run --rm -it dfile

# docker run \
#   --rm -it \
#   -v ~/Projects/bootstrap:/root/bootstrap \
#   -w /root/bootstrap  \
#   $IMG /bin/bash -c './run.sh; exec /bin/bash'
