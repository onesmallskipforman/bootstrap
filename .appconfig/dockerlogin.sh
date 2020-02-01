#!/bin/sh

user=$(sed '1q;d' "Backup/Private/docker.txt")
pass=$(sed '2q;d' "Backup/Private/docker.txt")

docker login -u $user -p $pass # 2> /dev/null
