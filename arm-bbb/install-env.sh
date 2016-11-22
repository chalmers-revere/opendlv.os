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

if [[ $has_setup_env_root == 1 ]]; then
  for f in setup-env-root-*.sh; do
    su -c ./${f} -s /bin/bash root
  done
  rm setup-env-root-*.sh
fi

for (( i = 0; i < ${#user[@]}; i++ )); do
  useradd -m -g users -s /bin/bash ${user[$i]}
  if [ ! "${group[$i]}" == "" ]; then
    usermod -G ${group[$i]} ${user[$i]}
  fi

  echo -e "${user_password[$i]}\n${user_password[$i]}" | (passwd ${user[$i]})

  if [[ $has_setup_env_user == 1 ]]; then
    cd /home/${user[$i]}
    cp /root/{install-conf,setup-env-user-*}.sh .
    chmod +x *.sh
    for f in setup-env-user-*.sh; do
      su -c ./${f} -s /bin/bash ${user[$i]}
    done
    rm setup-env-user-*.sh
    cd
    rm setup-env-user-*.sh
  fi
  
  if [[ $has_setup_post_user == 1 ]]; then
    cp setup-post-user-*.sh /home/${user[$i]}
    chmod +x /home/${user[$i]}/*.sh
  fi
done

echo -e "[Unit]\nDescription=Automated install, post setup\n\n[Service]\nType=oneshot\nExecStart=/root/install-post.sh\n\n[Install]\nWantedBy=multi-user.target" >> /etc/systemd/system/install-post.service

systemctl enable install-post.service

echo -e "${root_password}\n${root_password}" | (passwd)

rm install-env.sh
  
exit
