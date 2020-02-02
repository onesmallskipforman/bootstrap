#!/bin/sh

user=$(sed '1q;d' "Private/login.txt")
pass=$(sed '2q;d' "Private/login.txt")

docker login -u $user -p $pass # 2> /dev/null
