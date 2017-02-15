#!/bin/bash

while :
do
  nc -z 8.8.8.8 53  >/dev/null 2>&1
  online=$?
  if [ $online -eq 0 ]; then
    break
  else
    echo "install-post.sh: Internet NOT found, will try again in 10 s!"
    sleep 10
  fi
done

cd /root
source install-conf.sh
mkdir -p /root/boot/

(echo d; echo n; echo p; echo ""; echo ""; echo ""; echo w) | fdisk /dev/mmcblk0
(echo y) | mkfs.ext4 /dev/mmcblk0p1
mkdir /mnt/sdcard
mount /dev/mmcblk0p1 /mnt/sdcard
echo "/dev/mmcblk0p1  /mnt/sdcard  ext4  defaults  0 2" >> /etc/fstab


if [[ $has_setup_user == 1 ]]; then
  mkdir /mnt/sdcard/users

  for (( i = 0; i < ${#user[@]}; i++ )); do
    mkdir /mnt/sdcard/users/${user[$i]}
    chown -R ${user[$i]}:users /mnt/sdcard/users/${user[$i]}
    su -c "ln -s /mnt/sdcard/users/${user[$i]} /home/${user[$i]}/sdcard" -s /bin/bash ${user[$i]}

    cp install-conf.sh setup-user-*.sh /home/${user[$i]}
    cd /home/${user[$i]}
    chmod +x *.sh
    for f in setup-user-*.sh; do
      su -c ./${f} -s /bin/bash ${user[$i]}
      cd /home/${user[$i]}
    done
    rm install-conf.sh setup-user-*.sh
    cd /root
  done
  rm setup-user-*.sh
fi

if [[ $has_setup_post == 1 ]]; then
  for f in setup-post-*.sh; do
    su -c ./${f} -s /bin/bash root
    cd /root
  done
  rm setup-post-*.sh
fi

systemctl disable install-post.service
rm /etc/systemd/system/install-post.service

echo -e "IMPORTANT: This computer is regularly and automatically wiped clean and reinstalled. Therefore, DO NOT keep any important files on this computer, and keep in mind that any settings that you make will be lost." > /etc/motd

rm install-conf.sh install-post.sh && reboot
