#!/bin/zsh

cd "$(dirname $0)"

user=$(sed '1q;d' "Private/login.txt")
pass=$(sed '2q;d' "Private/login.txt")

docker login -u $user --password-stdin < $pass
