#!/bin/sh

# sudo apt install -y libc6
DIR=$(mktemp -d); DEB=$DIR/d.deb
# wget -qO $DEB 'https://github.com/stlink-org/stlink/releases/download/v1.8.0/stlink_1.8.0-1_amd64.deb'
wget -qO $DEB 'https://github.com/stlink-org/stlink/releases/download/v1.7.0/stlink_1.7.0-1_amd64.deb'
sudo apt install -y --allow-downgrades $DEB
rm -rf $DIR
