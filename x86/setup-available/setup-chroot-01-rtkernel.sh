#!/bin/bash

url=https://aur.archlinux.org/cgit/aur.git/snapshot/linux-rt.tar.gz

cd
source install-conf.sh

cd /home/aur/
mkdir setup-rtkernel
cd setup-rtkernel

wget ${url}

tar -zxvf linux-rt.tar.gz
cd linux-rt

chown aur:users -R /home/aur/setup-rtkernel

sudo -u aur makepkg -s --noconfirm --skippgpcheck # TODO: Manually create ~/.gnupg/gpg.conf, see: https://bbs.archlinux.org/viewtopic.php?id=192575

pacman -U --noconfirm *.pkg.tar.xz

cd
