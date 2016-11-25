#!/bin/bash

source install-conf.sh

pacman -S --noconfirm docker docker-compose

for u in ${user[@]}; do
  gpasswd -a ${u} docker
done

systemctl enable docker
