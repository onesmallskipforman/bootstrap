#!/bin/sh

echo "deb https://apt.internal.cloud.torc.tech/repository/apt-$(lsb_release -cs) $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/torc.list
echo "deb https://apt.internal.cloud.torc.tech/repository/apt-$(lsb_release -cs)-contrib $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/torc.list
echo "deb https://apt.internal.cloud.torc.tech/repository/apt-$(lsb_release -cs)-proxy $(lsb_release -cs) main" | sudo tee -a /etc/apt/sources.list.d/torc.list
curl https://nexus.internal.cloud.torc.tech/repository/public-keys/apt/public.gpg.key | sudo apt-key add -
sudo apt update
