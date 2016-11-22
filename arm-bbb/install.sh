#!/bin/bash

source install-conf.sh

# Basic install

dd if=/dev/zero of=/dev/mmcblk1 bs=1M count=8

(echo o; echo n; echo p; echo 1; echo 2048; echo ""; echo w) | fdisk /dev/mmcblk1

mkfs.ext4 -O ^metadata_csum,^64bit /dev/mmcblk1p1

pacman -Syy

if [ ! "$download_image" == "1" ]; then
  pacman -S --noconfirm wget
  rm ArchLinuxARM-am33x-latest.tar.gz
  wget http://os.archlinuxarm.org/os/ArchLinuxARM-am33x-latest.tar.gz
fi

rm -r mnt
mkdir mnt
mount /dev/mmcblk1p1 mnt

bsdtar -xpf ArchLinuxARM-am33x-latest.tar.gz -C mnt
sync

dd if=mnt/boot/MLO of=/dev/mmcblk1 count=1 seek=1 conv=notrunc bs=128k
dd if=mnt/boot/u-boot.img of=/dev/mmcblk1 count=2 seek=1 conv=notrunc bs=384k
sync

mount -t proc proc mnt/proc/
mount --rbind /sys mnt/sys/
mount --rbind /dev mnt/dev/
mount --rbind /run mnt/run/

cp /etc/resolv.conf mnt/etc/resolve.conf
cp install-{conf,post}.sh mnt/root/
cp setup-*.sh mnt/root/

chroot mnt /root/install-post.sh
