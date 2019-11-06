#!/bin/bash
set -e

source install-conf.sh

uefi=false
if [ -d "/sys/firmware/efi/efivars" ] && [ "$disable_uefi" = false ]; then
  uefi=true
fi

for f in setup-chroot-*.sh; do
    [ -e "$f" ] && has_setup_chroot=1 || has_setup_chroot=0
    break
done

for f in setup-post-*.sh; do
    [ -e "$f" ] && has_setup_post=1 || has_setup_post=0
    break
done

for f in setup-user-*.sh; do
    [ -e "$f" ] && has_setup_user=1 || has_setup_user=0
    break
done

has_setup_root=$(( $has_setup_chroot || $has_setup_post ? 1 : 0))
has_setup=$(( $has_setup_root || $has_setup_user ? 1 : 0))

mkdir /tmp/ramdisk
mount -t tmpfs -o size=1g tmpfs /tmp/ramdisk
cp *.sh /tmp/ramdisk

arch_bootstrap_file=`wget -q ${arch_mirror}/archlinux/iso/latest -O - | grep 'tar.gz"' | cut -d '"' -f2`
cd /tmp/ramdisk && wget "${arch_mirror}/archlinux/iso/latest/${arch_bootstrap_file}" && tar -zxf ${arch_bootstrap_file} && mv root.x86_64/* . && rm -r ${arch_bootstrap_file} root.x86_64

#cp /etc/pacman.d/mirrorlist /tmp/ramdisk/etc/pacman.d/mirrorlist
# Set mirror.
cat <<EOF >> /tmp/ramdisk/etc/pacman.d/mirrorlist
Server = https://ftp.acc.umu.se/mirror/archlinux/\$repo/os/\$arch
EOF
cp /etc/resolv.conf /tmp/ramdisk/etc



cat <<EOF > /tmp/ramdisk/arch-bootstrap-chroot.sh
#!/bin/bash

source install-conf.sh

pacman-key --init
pacman-key --populate archlinux
pacman -ySu --noconfirm
pacman -Sy --noconfirm gdisk wget grep

# There is no systemd.
#timedatectl set-ntp true

(echo x; echo z; echo Y; echo Y) | gdisk ${hdd}

if [ "$uefi" = true ]
then
  (echo n; echo ""; echo ""; echo +550M; echo EF00; echo w; echo Y) | gdisk ${hdd}
  hdd_esp=\`lsblk ${hdd} -p -r -n | tail -n1 | cut -d ' ' -f 1\`
  mkfs.fat -F32 \${hdd_esp}
else
  (echo n; echo ""; echo ""; echo +1M; echo EF02; echo w; echo Y) | gdisk ${hdd}
fi

(echo n; echo ""; echo ""; echo ""; echo 8300; echo w; echo Y) | gdisk ${hdd}
hdd_root=\`lsblk ${hdd} -p -r -n | tail -n1 | cut -d ' ' -f 1\`

# Allow kernel to propage the latest changes.
sync
sleep 5
sync

(echo y) | mkfs.ext4 \${hdd_root}
mount \${hdd_root} /mnt

if [ "$uefi" = true ]
then
  mkdir /mnt/boot
  mount \${hdd_esp} /mnt/boot
fi

#for i in "\${mirror[@]}"; do
#  grep -i -A 1 --no-group-separator \$i /etc/pacman.d/mirrorlist >> mirrorlist
#done
#mv mirrorlist /etc/pacman.d/mirrorlist

cp -a /etc/pacman.d/gnupg "/mnt/etc/pacman.d/"
cp -a /etc/pacman.d/mirrorlist "/mnt/etc/pacman.d/"

pacman -Syy

# pacstrap is not working; do it manually.
#pacstrap /mnt base linux linux-firmware netctl dhcpcd

# Preparing necessary system mounts.
mkdir -m 0755 -p "/mnt"/var/{cache/pacman/pkg,lib/pacman,log} "/mnt"/{dev,run,etc}
mkdir -m 1777 -p "/mnt"/tmp
mkdir -m 0555 -p "/mnt"/{sys,proc}
mount --bind "/mnt" "/mnt"
mount -t proc /proc "/mnt/proc"
mount --rbind /sys "/mnt/sys"
mount --rbind /run "/mnt/run"
mount --rbind /dev "/mnt/dev"

# Install software.
pacman -r "/mnt" --cachedir="/mnt/var/cache/pacman/pkg" -Sy --noconfirm base linux linux-firmware netctl dhcpcd


genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab | grep \${hdd_root} > /mnt/etc/fstab.new && mv /mnt/etc/fstab.new /mnt/etc/fstab

mem_size=\`awk '/MemTotal/ {print \$2}' /proc/meminfo\`
fallocate -l \${mem_size}k /mnt/var/swapfile
chmod 600 /mnt/var/swapfile
mkswap /mnt/var/swapfile
swapon /mnt/var/swapfile
echo -e "/var/swapfile\tnone\tswap\tdefaults\t0 0" >> /mnt/etc/fstab

if [[ $has_setup == 1 ]]; then
  cp setup-*.sh /mnt/root/
fi

cp install-conf.sh /mnt/root/



cat <<"CHROOT" > /mnt/root/install-chroot.sh
#!/bin/bash
set -e

cd

source install-conf.sh

pacman-key --init
pacman-key --populate archlinux
pacman -ySu --noconfirm

echo ${hostname} > /etc/hostname
ln -fs /usr/share/zoneinfo/${timezone} /etc/localtime

for i in \${locale[@]}; do
  sed -i "s/^#\$i/\$i/g" /etc/locale.gen
done
locale-gen
echo "LANG=\${locale[0]}" > /etc/locale.conf

echo "KEYMAP=${keymap}" > /etc/vconsole.conf

pacman -Syy

use_intel_ucode=false
if [ -n "\`lscpu | grep Vendor | grep Intel\`" ]
then
  pacman -S --noconfirm intel-ucode
  use_intel_ucode=true
fi

if [ "$uefi" = true ]
then
  hdd_root=\`mount | grep ' / ' | cut -d ' ' -f 1\`
  pacman -S --noconfirm efibootmgr
  efibootmgr | grep '^Boot0' | cut -c 5-8 | while read n; do efibootmgr -b "\$n" -B; done
  if [ "$uefi_bad_impl" = false ]
  then
    if [ "\$use_intel_ucode" = true ]
    then
      initrd_options="initrd=/intel-ucode.img initrd=/initramfs-linux.img"
    else
      initrd_options="initrd=/initramfs-linux.img"
    fi
    efibootmgr --disk ${hdd} --part 1 --create --gpt --label "Arch Linux" --loader /vmlinuz-linux --unicode "root=\`blkid \${hdd_root} -o export | grep '^PARTUUID'\` rw ${kernel_options}"
  else
    if [ "\$use_intel_ucode" = true ]
    then
      initrd_options="initrd  /intel-ucode.img\ninitrd  /initramfs-linux.img\n"
    else
      initrd_options="initrd  /initramfs-linux.img\n"
    fi
    bootctl --path=/boot install
    echo -e "default  arch" > /boot/loader/loader.conf
    echo -e "title   Arch Linux\nlinux   /vmlinuz-linux\n\${initrd_options}options root=\`blkid \${hdd_root} -o export | grep '^PARTUUID'\` rw" > /boot/loader/entries/arch.conf
  fi
else
  pacman -S --noconfirm grub
  grub-install --target=i386-pc --recheck ${hdd}
  grub-mkconfig -o /boot/grub/grub.cfg
fi

pacman -S --noconfirm ${software}

orphans=\`pacman -Qtdq\`
if [ ! "\${orphans}" == "" ]; then
  pacman -Rns \${orphans} --noconfirm || true
fi

echo "alias ll='ls -l'" >> /etc/bash.bashrc

for (( i = 0; i < \${#eth_dhcp_client_dev[@]}; i++ )); do
  echo -e "Description='A basic dhcp ethernet connection'\nInterface=\${eth_dhcp_client_dev[\$i]}\nConnection=ethernet\nIP=dhcp\nForceConnect=yes" > /etc/netctl/\${eth_dhcp_client_dev[\$i]}-dhcp
  systemctl enable netctl-ifplugd@\${eth_dhcp_client_dev[\$i]}
done

useradd -m -g users -G wheel aur
echo "aur ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo) 
# TODO: This permission should be removed after installation!

for (( i = 0; i < \${#user[@]}; i++ )); do
  useradd -m -g users -s /bin/bash \${user[\$i]}
  if [ ! "\${group[\$i]}" == "" ]; then
    usermod -G \${group[\$i]} \${user[\$i]}
  fi

  echo -e "\${user_password[\$i]}\n\${user_password[\$i]}" | (passwd \${user[\$i]})
done

if [ ! "\${service}" == "" ]; then
  for s in \${service[@]}; do
    systemctl enable \$s
  done
fi

if [ ! "\$group" == "" ]; then
  for i in "\${group[@]}"; do
    IFS=',' read -a grs <<< "\$i"
    for j in "\${grs[@]}"; do
      if [ "\$(grep \$j /etc/group)" == "" ]; then
        groupadd \$j
      fi
    done
  done
fi

if [[ $has_setup_chroot == 1 ]]; then
  for f in setup-chroot-*.sh; do
    su -c ./\${f} -s /bin/bash root
    cd /root
  done
  rm setup-chroot-*.sh
fi



cat <<POST >> /root/install-post.sh
while :
do
  nc -z 8.8.8.8 53  >/dev/null 2>&1
  online=\$?
  if [ \$online -eq 0 ]; then
    break
  else
    echo "install-post.sh: Internet NOT found, will try again in 10 s!"
    sleep 10
  fi
done

cd /root
source install-conf.sh

if [[ $has_setup_user == 1 ]]; then
  for (( i = 0; i < \${#user[@]}; i++ )); do
    cp install-conf.sh setup-user-*.sh /home/\${user[\$i]}
    cd /home/\${user[\$i]}
    chmod +x *.sh
    for f in setup-user-*.sh; do
      su -c ./\${f} -s /bin/bash \${user[\$i]}
      cd /home/\${user[\$i]}
    done
    rm install-conf.sh setup-user-*.sh
    cd /root
  done
  rm setup-user-*.sh
fi

if [[ $has_setup_post == 1 ]]; then
  for f in setup-post-*.sh; do
    su -c ./\${f} -s /bin/bash root
    cd /root
  done
  rm setup-post-*.sh
fi

userdel -r aur

systemctl disable install-post.service
rm /etc/systemd/system/install-post.service

echo -e "IMPORTANT: This computer is regularly and automatically wiped clean and reinstalled. Therefore, DO NOT keep any important files on this computer, and keep in mind that any settings that you make will be lost." > /etc/motd

rm install-conf.sh install-post.sh && reboot

POST
chmod 700 /root/install-post.sh


echo -e "[Unit]\nDescription=Automated install, post setup\nAfter=network-online.target\nRequires=network-online.target\n\n\n[Service]\nType=oneshot\nExecStart=/root/install-post.sh\nWorkingDirectory=/root\n\n[Install]\nWantedBy=multi-user.target" >> /etc/systemd/system/install-post.service

echo -e "WARNING: POST INSTALL IN PROGRESS.\n  The install-post.sh script is running. It will first wait for an active Internet connection. Then it will start running the selected setup scripts. To see the progress, run 'journalctl -u install-post -f'. The computer will be rebooted automatically when the installation is complete!" > /etc/motd

systemctl enable install-post.service

echo -e "\${root_password}\n\${root_password}" | (passwd)

rm install-chroot.sh && exit
CHROOT
chmod 700 /mnt/root/install-chroot.sh



#arch-chroot /mnt /root/install-chroot.sh
cp /etc/resolv.conf /mnt/etc
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/
chroot /mnt /root/install-chroot.sh
EOF

#/tmp/ramdisk/bin/arch-chroot /tmp/ramdisk /tmp/ramdisk/arch-bootstrap-chroot.sh
cd /tmp/ramdisk
mount -t proc /proc proc
mount --make-rslave --rbind /sys sys
mount --make-rslave --rbind /dev dev
mount --make-rslave --rbind /run run
chmod 755 /tmp/ramdisk/arch-bootstrap-chroot.sh
chroot /tmp/ramdisk ./arch-bootstrap-chroot.sh



umount -R /mnt
reboot
