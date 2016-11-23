#!/bin/bash

mkdir /mnt/sdcard/docker
ln -s /mnt/sdcard/docker /var/lib/docker

pacman -S --noconfirm docker docker-compose

systemctl enable docker
systemctl start docker
