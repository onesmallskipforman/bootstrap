#!/bin/sh

user=$(sed '1q;d' "Backup/Private/git.txt")
pass=$(sed '2q;d' "Backup/Private/git.txt")

git config --global credential.helper osxkeychain
git config --global user.name $user
git config --global user.email $pass
