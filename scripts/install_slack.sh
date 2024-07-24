#!/bin/sh

URL=https://downloads.slack-edge.com/desktop-releases/linux/x64/4.38.125/slack-desktop-4.38.125-amd64.deb
DIR=$(mktemp -d)
wget $URL -qO $DIR/t.deb
sudo apt install -qy $DIR/t.deb
rm -rf $DIR
