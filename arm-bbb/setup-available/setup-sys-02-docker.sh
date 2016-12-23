#!/bin/bash

source install-conf.sh

pacman -S --noconfirm docker docker-compose

for u in ${user[@]}; do
  gpasswd -a ${u} docker
done

mkdir -p /mnt/sdcard/docker/
mkdir -p /etc/systemd/system/docker.service.d/
echo "[Service]\nExecStart=\nExecStart=/usr/bin/dockerd -g /mnt/sdcard/docker -H fd://" > /etc/systemd/system/docker.service.d/imagelocation.conf
systemctl daemon-reload
systemctl enable docker
