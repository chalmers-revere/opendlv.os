#!/bin/bash

# git clone --recurse-submodules https://github.com/bjornborg/bbb

echo "alias ll='ls -alF --color=auto'" >> /root/.bashrc
echo "alias ll='ls -alF --color=auto'" >> /home/pi/.bashrc

apt-get update
apt-get install -y netcat

while :
do
  nc -z 1.1.1.1 53  >/dev/null 2>&1
  online=$?
  if [ $online -eq 0 ]; then
    break
  else
    echo "install-post.sh: Internet NOT found, will try again in 3 s!"
    sleep 3
    dhclient usb1
  fi
done

cd /root

# Update scripts
cd /opt/scripts/
git pull
cd -
sed -i 's/\/sbin\/ifconfig usb1 192.168.6.2 netmask 255.255.255.252 || true/#\/sbin\/ifconfig usb1 192.168.6.2 netmask 255.255.255.252 || true/g' /opt/scripts/boot/autoconfigure_usb1.sh
# echo 'dhclient usb1' >> /opt/scripts/boot/autoconfigure_usb1.sh
echo 'auto usb1\niface usb1 inet dhcp' >> /etc/network/interfaces
echo 'ip route add 225.0.0.0/24 dev usb0' >> /opt/scripts/boot/autoconfigure_usb0.sh


# Create swapfile
fallocate -l 512M /var/swapfile
chmod 600 /var/swapfile
mkswap /var/swapfile
swapon /var/swapfile
echo "/var/swapfile\tnone\tswap\tdefaults\t0 0" >> /etc/fstab



# Format sdcard
(echo d; echo n; echo p; echo ""; echo ""; echo ""; echo w) | fdisk /dev/mmcblk0
(echo y) | mkfs.ext4 /dev/mmcblk0p1
mkdir -p /mnt/sdcard
mount /dev/mmcblk0p1 /mnt/sdcard
echo "/dev/mmcblk0p1  /mnt/sdcard  ext4  defaults  0 2" >> /etc/fstab

mkdir -p /mnt/sdcard/users/debian
chown -R debian:users /mnt/sdcard/users/debian
su -c "ln -s /mnt/sdcard/users/debian /home/debian/sdcard" -s /bin/bash debian


# Add unstable branch
# echo "deb http://ftp.us.debian.org/debian unstable main contrib non-free" > /etc/apt/sources.list.d/unstable.list
# echo "Package: * Pin: release a=testing Pin-Priority: 100" > /etc/apt/preferences.d/unstable
# apt-get update
# apt-get install gcc-8 g++-8 

# apt-get update
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
python-pip \
libusb-dev \
nmap \
iptables-persistent \
libncurses5-dev \
librobotcontrol \
ntp \
dnsmasq
"


echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
echo librobotcontrol librobotcontrol/q_runonboot select none | debconf-set-selections
echo librobotcontrol librobotcontrol/q_enable_dt boolean false | debconf-set-selections

apt-get dist-upgrade -y
apt-get upgrade -y
apt-get install -y ${software}
apt-get autoremove -y
apt-get autoclean

systemctl stop ntp
ntpd -gq
systemctl start ntp
systemctl enable ntp

# Installing docker
curl -sSL https://get.docker.com | sh
usermod -aG docker debian
systemctl stop docker.service
#/lib/systemd/system/docker.service
sed -i 's/\/usr\/bin\/dockerd -H fd:\/\//\/usr\/bin\/dockerd -g \/mnt\/sdcard\/docker\/ -H fd:\/\//g' /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl start docker.service
pip install docker-compose



# Networking
sed -i 's/#timeout 60;/timeout 300;/g' /etc/dhcp/dhclient.conf 
sed -i 's/#retry 60;/retry 10;/g' /etc/dhcp/dhclient.conf 
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o usb1 -j MASQUERADE
iptables -A FORWARD -i usb1 -o SoftAp0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i SoftAp0 -o usb1 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o SoftAp0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i SoftAp0 -o eth0 -j ACCEPT

iptables -t nat -A POSTROUTING -o enp17s0f3u1 -j MASQUERADE

iptables -A FORWARD -i enp17s0f3u1 -o enp10s0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -o enp17s0f3u1 -i enp10s0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -i SoftAp0 -o usb1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -o SoftAp0 -i usb1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -i SoftAp0 -o usb1 -p tcp --syn --dport 8888 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A PREROUTING -i SoftAp0 -p tcp --dport 8888 -j DNAT --to-destination 10.42.42.1

iptables -A FORWARD -i SoftAp0 -o usb1 -p tcp --syn --dport 8080 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A PREROUTING -i SoftAp0 -p tcp --dport 8080 -j DNAT --to-destination 10.42.42.1

iptables -A FORWARD -p tcp -d 10.42.42.1 --dport 8081 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A PREROUTING -p tcp -i SoftAp0 --dport 80 -j DNAT --to-destination 10.42.42.1:8081


iptables -A FORWARD -i SoftAp0 -o usb1 -p tcp --syn --dport 8081 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A PREROUTING -i SoftAp0 -p tcp --dport 8081 -j DNAT --to-destination 10.42.42.1

iptables -A FORWARD -i SoftAp0 -o usb1 -p tcp --syn --dport 8880 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A PREROUTING -i SoftAp0 -p tcp --dport 8880 -j DNAT --to-destination 10.42.42.1

iptables-save > /etc/iptables/rules.v4

echo "10.42.42.1\t kiwi.opendlv.io" >> /etc/hosts


# /usr/bin/bb-wl18xx-tether < good stuff here
# Random 1-13 channel assignment
channel=$((1 + RANDOM % 13))
sed -i 's/channel=.*/channel='"${channel}"'" >> ${wfile}/g' /usr/bin/bb-wl18xx-tether 


cd /root/
wget https://raw.githubusercontent.com/chalmers-revere/opendlv.os/kiwi/kiwi/bbblue.yml 
wget https://raw.githubusercontent.com/chalmers-revere/opendlv.os/kiwi/kiwi/.env 
docker-compose -f bbblue.yml up -d

read -p "Installation script for the beaglebone is done!"

# shutdown now

