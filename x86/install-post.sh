#!/bin/bash

source /root/install-conf.sh

echo ${hostname} > /etc/hostname
ln -fs /usr/share/zoneinfo/${timezone} /etc/localtime

for i in ${locale[@]}; do
  sed -i "s/^#$i/$i/g" /etc/locale.gen
done
locale-gen
echo "LANG=${locale[0]}" > /etc/locale.conf

echo "KEYMAP=${keymap}" > /etc/vconsole.conf
echo "FONT=${font}" >> /etc/vconsole.conf

pacman -Sy
pacman -S --noconfirm grub
grub-install --target=i386-pc --recheck ${hdd}
grub-mkconfig -o /boot/grub/grub.cfg

for (( i = 0; i < ${#dhcp_dev[@]}; i++ )); do
  if [ ! "${dhcp_dev[$i]}" == "" ]; then
    echo -e "Description='A basic dhcp ethernet connection'\nInterface=${dhcp_dev[$i]}\nConnection=ethernet\nIP=dhcp" > /etc/netctl/${dhcp_dev[$i]}-dhcp
  fi
done

pacman -S --noconfirm ${software}

orphans=`pacman -Qtdq`
if [ ! "${orphans}" == "" ]; then
  pacman -Rns ${orphans} --noconfirm || true
fi

if [ ! "${service}" == "" ]; then
  for s in ${service[@]}; do
    systemctl enable $s
  done
fi

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


if [[ $has_setup_root == 1 ]]; then
  su -c setup-root-* -s /bin/bash root
  rm setup-root-*.sh
fi

for (( i = 0; i < ${#user[@]}; i++ )); do
  useradd -m -g users -s /bin/bash ${user[$i]}
  if [ ! "${group[$i]}" == "" ]; then
    usermod -G ${group[$i]} ${user[$i]}
  fi

  if [[ $has_setup_user == 1 ]]; then
    cd /home/${user[$i]}
    cp /root/{install-conf,setup-user-*}.sh .
    chmod +x *.sh
#    mv .bash_profile .bash_profilecopy 2>/dev/null
    su -c setup-user-* -s /bin/bash ${user[$i]}
#    mv .bash_profilecopy .bash_profile 2>/dev/null
    rm {install-conf,setup-user-*}.sh
    cd
  fi
done

passwd
for i in ${user[@]}; do
  passwd $i
done

rm {install-conf,install-post}.sh

exit
