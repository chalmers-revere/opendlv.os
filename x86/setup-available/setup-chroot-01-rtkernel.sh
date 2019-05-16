#!/bin/bash

WORKDIR=/tmp/kernel_build


mkdir -p ${WORKDIR}
cd ${WORKDIR}

wget -N https://aur.archlinux.org/cgit/aur.git/snapshot/linux-rt.tar.gz
tar -xf linux-rt.tar.gz

cd linux-rt
NJOBS=$[`nproc` + 2 ]

sed -e "s/make/make -j${NJOBS}/g" PKGBUILD

makepkg -sir

grub-mkconfig -o /boot/grub/grub.cfg
