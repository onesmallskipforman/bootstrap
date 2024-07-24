#!/bin/sh

sudo dpkg --add-architecture i386
KEY="https://dl.winehq.org/wine-builds/winehq.key"
SRC="https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources"
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key $KEY
sudo wget -NP /etc/apt/sources.list.d/ $SRC
sudo apt update -y
sudo apt install -qy --install-recommends winehq-stable


DIR=$(mktemp -d)
MONO="https://dl.winehq.org/wine/wine-mono/9.0.0/wine-mono-9.0.0-x86.msi"
wget -qO $DIR/mono.msi $URL
sudo sysctl dev.i915.perf_stream_paranoid=0
WINEDEBUG="fixme-all" WINEARCH=win64 WINEPREFIX=~/.config/wine wine msiexec /i $DIR/mono.msi
# URL="https://dl.winehq.org/wine/wine-mono/9.0.0/wine-mono-9.0.0-x86.tar.xz"
# wget -qO- $URL | tar Jxvf - -C $DIR --strip-components=1
