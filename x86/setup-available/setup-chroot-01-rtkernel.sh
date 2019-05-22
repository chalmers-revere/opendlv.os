#!/bin/bash

WORKDIR=/tmp/kernel_build


mkdir -p ${WORKDIR}
cd ${WORKDIR}

wget -N https://aur.archlinux.org/cgit/aur.git/snapshot/linux-rt.tar.gz
tar -xf linux-rt.tar.gz

cd linux-rt

gpg --recv-key 38DBBDC86092693E
gpg --recv-key 05641F175712FA5B
(echo "", echo "") | MAKEFLAGS="-j$[`nproc` + 4]" makepkg -sir

sudo grub-mkconfig -o /boot/grub/grub.cfg
