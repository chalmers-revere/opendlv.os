#!/bin/bash

cd
source install-conf.sh

echo ${hostname} > /etc/hostname
ln -fs /usr/share/zoneinfo/${timezone} /etc/localtime

for i in ${locale[@]}; do
  sed -i "s/^#$i/$i/g" /etc/locale.gen
done
locale-gen
echo "LANG=${locale[0]}" > /etc/locale.conf

echo "KEYMAP=${keymap}" > /etc/vconsole.conf

pacman -Syy

pacman -S --noconfirm grub
grub-install --target=i386-pc --recheck ${hdd}
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --noconfirm ${software}

orphans=`pacman -Qtdq`
if [ ! "${orphans}" == "" ]; then
  pacman -Rns ${orphans} --noconfirm || true
fi

for (( i = 0; i < ${#dhcp_dev[@]}; i++ )); do
  echo -e "Description='A basic dhcp ethernet connection'\nInterface=${dhcp_dev[$i]}\nConnection=ethernet\nIP=dhcp" > /etc/netctl/${dhcp_dev[$i]}-dhcp
  systemctl enable netctl-ifplugd@${dhcp_dev[$i]}
done

useradd -m -g users -G wheel aur
echo "aur ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo) 

# TODO: This permission should be removed after installation!
#sudo -u aur gpg --list-keys
#echo "keyring /etc/pacman.d/gnupg/pubring.gpg" >> /home/aur/.gnupg/gpg.conf
# The above does not help, woraround is to run makepkg with --skippgpcheck (potentially unsafe)


for (( i = 0; i < ${#user[@]}; i++ )); do
  useradd -m -g users -s /bin/bash ${user[$i]}
  if [ ! "${group[$i]}" == "" ]; then
    usermod -G ${group[$i]} ${user[$i]}
  fi

  echo -e "${user_password[$i]}\n${user_password[$i]}" | (passwd ${user[$i]})
done

if [ ! "${service}" == "" ]; then
  for s in ${service[@]}; do
    systemctl enable $s
  done
fi
systemctl enable sshd

if [ ! "$group" == "" ]; then
  for i in "${group[@]}"; do
    IFS=',' read -a grs <<< "$i"
    for j in "${grs[@]}"; do
      if [ "$(grep $j /etc/group)" == "" ]; then
        groupadd $j
      fi
    done
  done
fi

if [[ $has_setup_chroot == 1 ]]; then
  for f in setup-chroot-*.sh; do
    su -c ./${f} -s /bin/bash root
    cd /root
  done
  rm setup-chroot-*.sh
fi

echo -e "[Unit]\nDescription=Automated install, post setup\nAfter=network-online.target\nRequires=network-online.target\n\n\n[Service]\nType=oneshot\nExecStart=/root/install-post.sh\nWorkingDirectory=/root\n\n[Install]\nWantedBy=multi-user.target" >> /etc/systemd/system/install-post.service

echo -e "WARNING: POST INSTALL IN PROGRESS.\n  The install-post.sh script is running. It will first wait for an active Internet connection. Then it will start running the selected setup scripts. To see the progress, run 'journalctl -u install-post -f'. The computer will be rebooted automatically when the installation is complete!" > /etc/motd

systemctl enable install-post.service

echo -e "${root_password}\n${root_password}" | (passwd)

rm install-chroot.sh && exit
