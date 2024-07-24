#!/bin/sh

URL='https://github.com/Jelmerro/Vieb/releases/download/12.0.0/vieb_12.0.0_amd64.deb'
DEB=$(mktemp -d)/vieb.deb
wget -qO $DEB $URL
sudo apt install $DEB
