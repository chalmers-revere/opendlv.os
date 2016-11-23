#!/bin/bash

cd /root
source install-conf.sh

mkdir /mnt/sdcard/users

for (( i = 0; i < ${#user[@]}; i++ )); do
  mkdir /mnt/sdcard/users/${user[$i]}
  chown -R ${user[$i]}:users /mnt/sdcard/users/${user[$i]}
  su -c "ln -s /mnt/sdcard/users/${user[$i]} /home/${user[$i]}/sdcard" -s /bin/bash ${user[$i]}
done

if [[ $has_setup_post_root == 1 ]]; then
  for f in setup-post-root-*.sh; do
    su -c ./${f} -s /bin/bash root
    cd
  done
  rm setup-post-root-*.sh
fi
  
if [[ $has_setup_post_user == 1 ]]; then
  for (( i = 0; i < ${#user[@]}; i++ )); do
    cp setup-post-user-*.sh /home/${user[$i]}
    chmod +x /home/${user[$i]}/*.sh

    cd /home/${user[$i]}
    for f in setup-post-user-*.sh; do
      su -c ./${f} -s /bin/bash ${user[$i]}
      cd
    done
    rm setup-post-user-*.sh

    cd
  done

  rm setup-post-user-*.sh
fi

systemctl disable install-post.service
rm /etc/systemd/system/install-post.service

rm install-conf.sh
rm install-post.sh && reboot
