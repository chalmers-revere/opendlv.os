#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

apt-get update
apt-get install -y curl git netcat

while :
do
  nc -z 1.1.1.1 53  >/dev/null 2>&1
  online=$?
  if [ $online -eq 0 ]; then
    break
  else
    echo "install-post.sh: Internet NOT found, will try again in 3 s!"
    sleep 3
  fi
done

cd /root

git clone --recurse-submodules https://github.com/bjornborg/bbb

cd bbb/rpi3
chmod +x install-post.sh
./install-post.sh


# cp ./install-post.sh /root/install-post.sh
# chmod +x /root/install-post.sh
# echo -e "[Unit]\nDescription=Automated install, post setup\nAfter=network-online.target\nRequires=network-online.target\n\n\n[Service]\nType=oneshot\nExecStart=/root/install-post.sh\nWorkingDirectory=/root\n\n[Install]\nWantedBy=multi-user.target" >> /etc/systemd/system/install-post.service
# echo -e "WARNING: POST INSTALL IN PROGRESS.\n  The install-post.sh script is running. It will first wait for an active Internet connection. Then it will start running the selected setup scripts. To see the progress, run 'journalctl -u install-post -f'. The computer will be rebooted automatically when the installation is complete!" > /etc/motd
# systemctl enable install-post.service

# reboot now
