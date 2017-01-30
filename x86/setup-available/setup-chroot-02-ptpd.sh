#!/bin/bash

url=https://aur.archlinux.org/cgit/aur.git/snapshot/ptpd.tar.gz

cd
source install-conf.sh

cd /home/aur/
mkdir setup-ptpd
cd setup-ptpd

wget ${url}

tar -zxvf ptpd.tar.gz
cd ptpd

chown aur:users -R /home/aur/setup-ptpd

sudo -u aur makepkg -s --noconfirm --skippgpcheck # TODO: Find a way to fix user gpg keychain for pacman

pacman -U --noconfirm *.pkg.tar.xz

echo -e "ptpengine:interface=${lan_dev}\nptpengine:domain=0\nptpengine:preset=slaveonly\nptpengine:ip_mode=multicast\nptpengine:use_libpcap=n\nglobal:log_file=/var/log/ptpd2.log\nglobal:log_status=y\n" > /etc/ptpd2.conf

echo -e "[Unit]\nDescription=ptpd2\nAfter=network-online.target\nRequires=network-online.target\n\n[Service]\nRestart=always\nRestartSec=30\nType=forking\nExecStart=/usr/bin/ptpd2 -c /etc/ptpd2.conf\n\n[Install]\nWantedBy=multi-user.target\n" > /etc/systemd/system/ptpd2.service

systemctl enable ptpd2

cd
