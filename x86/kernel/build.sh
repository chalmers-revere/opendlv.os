#!/bin/bash

url=https://aur.archlinux.org/cgit/aur.git/snapshot/linux-rt.tar.gz

mkdir pkg

wget ${url}

tar -zxvf linux-rt.tar.gz
cd linux-rt

sed -i "s/`grep _rtpatchver= PKGBUILD`/`grep _rtpatchver= PKGBUILD`-revere/g" PKGBUILD

makepkg -s --skippgpcheck --nobuild 

cd src/linux-4.9

pwd

echo "Applying x86 Brick patch."
patch -p1 -i ../../../x86-brick/linux_4.9_8250_pci_brick_core_exar_gpio.patch

echo "Applying patch to support 5G ITS communication via ath9k devices."
patch -p1 -i ../../../x86-its/ath9k-its.patch

cd ../..

pwd

makepkg -s --skippgpcheck --noextract

cp *.pkg.tar.xz ../pkg
