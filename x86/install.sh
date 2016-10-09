#!/bin/bash

source install-conf.sh

(echo o; echo n; echo p; echo 1; echo ""; echo ""; echo w; echo q) | fdisk ${hdd}

mkfs.ext4 ${hdd}1

mount ${hdd}1 /mnt

for i in "${mirror[@]}"; do
  grep -i -A 1 --no-group-separator $i /etc/pacman.d/mirrorlist >> mirrorlist
done
mv mirrorlist /etc/pacman.d/mirrorlist

pacman -Syy

pacstrap /mnt base base-devel
echo -e "${hdd}1\t/\text4\trw,relatime\t0 1" >> /mnt/etc/fstab

mkdir -p /mnt/root
cp {install-conf,install-post}.sh /mnt/root/
if [ "$has_setup" ]; then
  cp setup-*.sh /mnt/root/
fi

arch-chroot /mnt /root/install-post.sh

umount -R /mnt
reboot
