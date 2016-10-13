#!/bin/bash

cd 
source install-conf.sh

if [[ $has_setup_post_root == 1 ]]; then
  for f in setup-post-root-*.sh; do
    su -c ./${f} -s /bin/bash root
  done
fi
  
if [[ $has_setup_post_user == 1 ]]; then
  for (( i = 0; i < ${#user[@]}; i++ )); do
    cd /home/${user[$i]}
    for f in setup-post-user-*.sh; do
      su -c ./${f} -s /bin/bash ${user[$i]}
    done
    rm setup-post-user-*.sh
    cd
  done
fi

systemctl disable install-post.service
rm /etc/systemd/system/install-post.service

reboot
