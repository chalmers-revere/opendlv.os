#!/bin/bash

source install-conf.sh

mkdir /mnt/sdcard/docker
ln -s /mnt/sdcard/docker /var/lib/docker

pacman -S --noconfirm docker docker-compose

for u in ${user[@]}; do
  gpasswd -a ${u} docker
  usermod -aG docker ${u}
done

systemctl enable docker
