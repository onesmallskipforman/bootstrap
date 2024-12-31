#!/bin/sh

wget -qO- https://cdimage.ubuntu.com/ubuntu-mini-iso/noble/daily-live/current/noble-mini-iso-amd64.iso | sudo dd of=/dev/sda bs=4M status=progress
sync
