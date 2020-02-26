#!/bin/bash

printf "alias ll='ls -alF --color=auto'" >> /root/.bashrc
printf "alias ll='ls -alF --color=auto'" >> /home/pi/.bashrc

timedatectl set-timezone Europe/Stockholm

printf 'sv_SE.UTF-8 UTF-8' >> /etc/locale.gen
printf 'en_US.UTF-8 UTF-8' >> /etc/locale.gen


locale-gen

systemctl enable ssh
systemctl start ssh

while :
do
  ping -q -c 1 -W 1 1.1.1.1 >/dev/null 2>&1
  online=$?
  if [ $online -eq 0 ]; then
    echo "Internet connection found..."
    break
  else
    echo "install.sh: Internet NOT found, will try again in 3 s!"
    sleep 3
  fi
done

software=" \
bash-completion \
ccache \
cmake \
netcat \
git \
i2c-tools \
nano \
screen \
vim \
wget \
gcc-6 \
g++-6 \
python-pip \
docker-io \
docker-compose \
libusb-dev \
isc-dhcp-server \
iptables-persistent \
nmap \
libncurses5-dev \
rpi-update \
ntp
"
# npm \

echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections


apt-get update
apt-get install -y ${software}
apt-get dist-upgrade -y
apt-get upgrade -y
apt-get autoremove -y
apt-get autoclean

printf 'broadcast 10.42.42.255\nserver 127.127.1.0\nfudge 127.127.1.0 stratum 10\n' >> /etc/ntp.conf

systemctl stop ntp
ntpd -gq
systemctl start ntp
systemctl enable ntp

rpi-update

# enable pi cam
raspi-config nonint do_camera 0


#enable wireless
printf 'country=SE\n' >> /etc/wpa_supplicant/wpa_supplicant.conf
printf 'network={\n    ssid="kiwi"\n    psk="opendlv-kiwi"\n    priority=1\n}\n' >> /etc/wpa_supplicant/wpa_supplicant.conf
printf 'network={\n    ssid="IVRL"\n    psk="opendlv-ivrl"\n    priority=2\n}\n' >> /etc/wpa_supplicant/wpa_supplicant.conf


wpa_cli -i wlan0 reconfigure

#dhcp server
printf 'authoritative;\nsubnet 10.42.42.0 netmask 255.255.255.0 {\n    range 10.42.42.10 10.42.42.50;\n    option broadcast-address 10.42.42.255;\n    option routers 10.42.42.1;\n    default-lease-time 600;\n    max-lease-time 7200;\n    option domain-name "kiwi.opendlv.io";\n    option domain-name-servers 1.1.1.1, 1.0.0.1;\n}\n' >> /etc/dhcp/dhcpd.conf
sed -i  's/option domain-name "example.org";/#option domain-name "example.org";/g' /etc/dhcp/dhcpd.conf
sed -i  's/option domain-name-servers ns1.example.org, ns2.example.org;/#option domain-name-servers ns1.example.org, ns2.example.org;/g' /etc/dhcp/dhcpd.conf
# mutlicast && hotplug eth1
printf 'if [ "${interface}" = "eth1" ] && [ $if_up ]; then\n' > /lib/dhcpcd/dhcpcd-hooks/99-eth1-beaglebone.conf
printf '  ip route add 225.0.0.0/24 dev eth1\n' >> /lib/dhcpcd/dhcpcd-hooks/99-eth1-beaglebone.conf
printf '  systemctl try-restart isc-dhcp-server.service || true\n' >> /lib/dhcpcd/dhcpcd-hooks/99-eth1-beaglebone.conf
printf 'fi\n' >> /lib/dhcpcd/dhcpcd-hooks/99-eth1-beaglebone.conf

# static ip
printf 'noipv6\ninterface eth1\nstatic ip_address=10.42.42.1/24\nstatic routers=10.42.42.1\nstatic domain_name-servers=1.1.1.1 1.0.0.1' >> /etc/dhcpcd.conf
printf 'auto lo\niface lo inet loopback\nallow-hotplug eth0\nallow-hotplug eth1\n' >> /etc/network/interfaces
sed -i 's/INTERFACESv4=""/INTERFACESv4="eth1"/g' /etc/default/isc-dhcp-server


cp /run/systemd/generator.late/isc-dhcp-server.service /etc/systemd/system
sed -i 's/Restart=no/Restart=on-failure\nRestartSec=5/g' /etc/systemd/system/isc-dhcp-server.service
printf '\n[Install]\nWantedBy=multi-user.target\n' >> /etc/systemd/system/isc-dhcp-server.service

# custom ssh port
printf "Port 2200\n" >> /etc/ssh/sshd_config

# iptables
printf "net.ipv4.ip_forward=1\n" >> /etc/sysctl.conf
printf 1 > /proc/sys/net/ipv4/ip_forward

iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
iptables -A FORWARD -i wlan0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -o wlan0 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables-save > /etc/iptables/rules.v4

iptables -t nat -A POSTROUTING -o enp17s0f3u1 -j MASQUERADE
iptables -A FORWARD -i enp17s0f3u1 -o wlp8s0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlp8s0 -o enp17s0f3u1 -j ACCEPT

sed -i '$imodprobe bcm2835-v4l2' /etc/rc.local
systemctl daemon-reload
systemctl enable dhcpcd
systemctl restart dhcpcd
systemctl enable isc-dhcp-server
systemctl restart isc-dhcp-server


# Installing docker
# curl -sSL https://get.docker.com | sh
usermod -aG docker pi
cd /root
wget -SL https://raw.githubusercontent.com/chalmers-revere/opendlv.os/kiwi/kiwi/rpi3.yml 
docker-compose -f rpi3.yml up -d
cd /root

clear
echo "Installation script for raspberry pi 3 is done."
