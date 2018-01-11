#!/bin/bash

source install-conf.sh

timedatectl set-ntp true

(echo x; echo z; echo Y; echo Y) | gdisk ${hdd}

if [ "$uefi" = true ]
then
  (echo n; echo ""; echo ""; echo +550M; echo EF00; echo w; echo Y) | gdisk ${hdd}
  hdd_esp=`lsblk ${hdd} -p -r -n | tail -n1 | cut -d ' ' -f 1`
  mkfs.fat -F32 ${hdd_esp}
fi

(echo n; echo ""; echo ""; echo ""; echo 8300; echo w; echo Y) | gdisk ${hdd}
hdd_root=`lsblk ${hdd} -p -r -n | tail -n1 | cut -d ' ' -f 1`
(echo y) | mkfs.ext4 ${hdd_root}
mount ${hdd_root} /mnt

if [ "$uefi" = true ]
then
  mkdir /mnt/boot
  mount ${hdd_esp} /mnt/boot
fi

for i in "${mirror[@]}"; do
  grep -i -A 1 --no-group-separator $i /etc/pacman.d/mirrorlist >> mirrorlist
done
mv mirrorlist /etc/pacman.d/mirrorlist

pacman -Syy

pacstrap /mnt base 

genfstab -U /mnt >> /mnt/etc/fstab

mem_size=`awk '/MemTotal/ {print $2}' /proc/meminfo`
fallocate -l ${mem_size}k /mnt/var/swapfile
chmod 600 /mnt/var/swapfile
mkswap /mnt/var/swapfile
swapon /mnt/var/swapfile
echo -e "/var/swapfile\tnone\tswap\tdefaults\t0 0" >> /mnt/etc/fstab

cp {install-conf,install-chroot,install-post}.sh /mnt/root/
if [[ $has_setup == 1 ]]; then
  cp setup-*.sh /mnt/root/
fi

arch-chroot /mnt /root/install-chroot.sh

umount -R /mnt
reboot
