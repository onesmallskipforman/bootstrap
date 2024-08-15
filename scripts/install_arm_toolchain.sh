#!/bin/sh

URL='https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz?rev=e434b9ea4afc4ed7998329566b764309&hash=CA590209F5774EE1C96E6450E14A3E26'
DIR=~/.local/src/arm_none_eabi
mkdir -p $DIR
wget -qO- "$URL" | tar xvJ --strip-components=1 -C $DIR
