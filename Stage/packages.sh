#!/usr/bin/sh

xargz brew tap          < tap.txt
xargz brew install      < brew.txt
xargz brew cask install < cask.txt
xargz mas install       < mas.txt
xargz pip3 install      < pip3.txt
xargz npm -g install    < npm.txt
