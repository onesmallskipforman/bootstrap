#!/bin/sh

DIR=$(mktemp -d)
wget -O $DIR/get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py
python3 $DIR/get-platformio.py
cleanup() { rm -rf $DIR; }; trap cleanup EXIT
