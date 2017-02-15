#!/bin/bash

source install-conf.sh

dd if=/dev/zero of=/dev/mmcblk1 bs=1M count=8

(echo o; echo n; echo p; echo 1; echo 2048; echo ""; echo w) | fdisk /dev/mmcblk1

mkfs.ext4 -O ^metadata_csum,^64bit /dev/mmcblk1p1

image=ArchLinuxARM-am33x-latest.tar.gz
if [ -f "$image" ]
then
	echo "$image was already found in the working directory."
else
  pacman -Syy --noconfirm wget
  wget http://os.archlinuxarm.org/os/${image}
fi

mount /dev/mmcblk1p1 /mnt

bsdtar -xpf ${image} -C /mnt
sync

dd if=/mnt/boot/MLO of=/dev/mmcblk1 count=1 seek=1 conv=notrunc bs=128k
dd if=/mnt/boot/u-boot.img of=/dev/mmcblk1 count=2 seek=1 conv=notrunc bs=384k
sync

mount -t proc proc /mnt/proc/
mount --rbind /sys /mnt/sys/
mount --rbind /dev /mnt/dev/
mount --rbind /run /mnt/run/

cp /etc/resolv.conf /mnt/etc/resolve.conf

fallocate -l 512M /mnt/var/swapfile
chmod 600 /mnt/var/swapfile
mkswap /mnt/var/swapfile
swapon /mnt/var/swapfile
echo -e "/var/swapfile\tnone\tswap\tdefaults\t0 0" >> /mnt/etc/fstab

cp {install-conf,install-chroot,install-post}.sh /mnt/root/
if [[ $has_setup == 1 ]]; then
  cp setup-*.sh /mnt/root/
fi

chroot /mnt /root/install-chroot.sh

umount -R /mnt
read -p "After shutdown, remember to (1) disconnect power to the device to disable SD boot, (2) remove the installation SD media, and (3) inserting the new SD card that will be used as a harddrive (WARNING: the inserted SD card WILL BE BLANKED *AUTOMATICALLY* ON THE NEXT BOOT!! Press [Enter] key to shutdown..."

shutdown now
