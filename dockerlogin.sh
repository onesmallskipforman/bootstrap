#!/bin/zsh

user=$(sed '1q;d' ~/"Dropbox/Backup/Docker/login.txt")
pass=$(sed '2q;d' ~/"Dropbox/Backup/Docker/login.txt")

echo "$pass" | docker login -u $user --password-stdin
