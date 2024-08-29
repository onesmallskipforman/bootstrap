#!/bin/sh

IMG=archlinux
# IMG=artixlinux/artixlinux
# IMG=artixlinux/artixlinux:base

docker run \
  --rm -it \
  -v ~/Projects/bootstrap:/root/bootstrap \
  -w /root/bootstrap  \
  $IMG /bin/bash
