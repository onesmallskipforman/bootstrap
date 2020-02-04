#!/bin/zsh

user=$(sed '1q;d' ~/"Dropbox/Backup/Github/login.txt")
email=$(sed '2q;d' ~/"Dropbox/Backup/Github/login.txt")

git config --global credential.helper osxkeychain
git config --global user.name $user
git config --global user.email $email
