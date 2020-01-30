#!/bin/sh

git config --global credential.helper osxkeychain
git config --global user.name $1
git config --global user.email $2
