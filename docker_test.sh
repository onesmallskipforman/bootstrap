#!/bin/sh

# IMG=archlinux
# IMG=artixlinux/artixlinux
# IMG=artixlinux/artixlinux:base
IMG=ubuntu:24.04

docker run \
  --rm -it \
  -v ~/Projects/bootstrap:/root/bootstrap \
  -w /root/bootstrap  \
  $IMG /bin/bash
  # $IMG ./test.sh
