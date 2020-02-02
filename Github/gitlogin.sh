#!/bin/zsh

cd "$(dirname $0)"

user=$(sed '1q;d' "Private/login.txt")
pass=$(sed '2q;d' "Private/login.txt")

git config --global credential.helper osxkeychain
git config --global user.name $user
git config --global user.email $pass
