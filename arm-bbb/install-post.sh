#!/bin/bash

cd /root
source install-conf.sh


(echo d; echo n; echo p; echo ""; echo ""; echo ""; echo w) | fdisk /dev/mmcblk0
mkfs.ext4 /dev/mmcblk0p1
mkdir /mnt/sdcard
mount /dev/mmcblk0p1 /mnt/sdcard
echo "/dev/mmcblk0p1  /mnt/sdcard  ext4  defaults  0 2" >> /etc/fstab



if [[ $has_setup_sys == 1 ]]; then
  for f in setup-sys-*.sh; do
    su -c ./${f} -s /bin/bash root
    cd
  done
  rm setup-sys-*.sh
fi

mkdir /mnt/sdcard/users

for (( i = 0; i < ${#user[@]}; i++ )); do
  useradd -m -g users -s /bin/bash ${user[$i]}
  if [ ! "${group[$i]}" == "" ]; then
    usermod -G ${group[$i]} ${user[$i]}
  fi

  mkdir /mnt/sdcard/users/${user[$i]}
  chown -R ${user[$i]}:users /mnt/sdcard/users/${user[$i]}
  su -c "ln -s /mnt/sdcard/users/${user[$i]} /home/${user[$i]}/sdcard" -s /bin/bash ${user[$i]}

  echo -e "${user_password[$i]}\n${user_password[$i]}" | (passwd ${user[$i]})

  if [[ $has_setup_user == 1 ]]; then
    cp install-conf.sh setup-user-*.sh /home/${user[$i]}
    cd /home/${user[$i]}
    chmod +x *.sh
    for f in setup-user-*.sh; do
      su -c ./${f} -s /bin/bash ${user[$i]}
      cd /home/${user[$i]}
    done
    rm install-conf.sh setup-user-*.sh
    cd
  fi
done

if [[ $has_setup_user == 1 ]]; then
  rm setup-user-*.sh
fi
    
systemctl disable install-post.service
rm /etc/systemd/system/install-post.service

rm install-conf.sh install-post.sh

shutdown now
