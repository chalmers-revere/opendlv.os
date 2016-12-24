#!/bin/bash

cd /root
source install-conf.sh

for (( i = 0; i < ${#user[@]}; i++ )); do
  useradd -m -g users -s /bin/bash ${user[$i]}
  if [ ! "${group[$i]}" == "" ]; then
    usermod -G ${group[$i]} ${user[$i]}
  fi

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
    cd /root
  fi
done

if [[ $has_setup_user == 1 ]]; then
  rm setup-user-*.sh
fi

if [[ $has_setup_sys == 1 ]]; then
  for f in setup-sys-*.sh; do
    su -c ./${f} -s /bin/bash root
    cd /root
  done
  rm setup-sys-*.sh
fi

systemctl disable install-post.service
rm /etc/systemd/system/install-post.service

rm install-conf.sh install-post.sh && reboot
