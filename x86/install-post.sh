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

if [[ $has_setup_user == 1 ]]; then
  for (( i = 0; i < ${#user[@]}; i++ )); do
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

userdel -r aur

systemctl disable install-post.service
rm /etc/systemd/system/install-post.service

echo -e "IMPORTANT: This computer is regularly and automatically wiped clean and reinstalled. Therefore, DO NOT keep any important files on this computer, and keep in mind that any settings that you make will be lost." > /etc/motd

rm install-conf.sh install-post.sh && reboot
