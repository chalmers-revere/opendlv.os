#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
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

timedatectl set-timezone Europe/Stockholm

cd /root

# Creating a swap 
fallocate -l 512M /var/swapfile
chmod 600 /var/swapfile
mkswap /var/swapfile
swapon /var/swapfile
printf "/var/swapfile\tnone\tswap\tdefaults\t0 0" >> /etc/fstab

# Update scripts
cd /opt/scripts/
git pull
cd -

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
dnsmasq \
git \
i2c-tools \
iptables-persistent \
libncurses5-dev \
librobotcontrol \
libusb-dev \
nano \
netcat \
nmap \
ntp \
python-pip \
screen \
vim \
gnupg2 \
pass \
wget 
"


echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
echo librobotcontrol librobotcontrol/q_runonboot select none | debconf-set-selections
echo librobotcontrol librobotcontrol/q_enable_dt boolean false | debconf-set-selections

apt-get update
apt-get remove -y --allow-change-held-packages bone101 bonescript nodejs bb-node-red-installer c9-core-installer
apt-get dist-upgrade -y
apt-get upgrade -y
apt-get install -y ${software}
apt-get autoremove -y
apt-get autoclean

##

sed -i 's/#restrict 192.168.123.0 mask 255.255.255.0 notrust/restrict 10.42.42.0 mask 255.255.255.0 nomodify notrap/g' /etc/ntp.conf
sed -i 's/#broadcastclient/broadcastclient/g' /etc/ntp.conf
printf 'server 10.42.42.1\n' >> /etc/ntp.conf
printf 'fudge 10.42.42.0 stratum 10\n' >> /etc/ntp.conf

systemctl stop ntp
ntpd -gq
systemctl start ntp
systemctl enable ntp
/sbin/hwclock --systohc


# Installing docker
curl -sSL https://get.docker.com | sh
usermod -aG docker debian
apt-get install -y docker-compose



# Networking
#printf 'USB_NETWORK_CDC_DISABLED=yes\n' >> /etc/default/bb-boot
printf 'USB_CONFIGURATION=enable\n' > /etc/default/bb-boot
printf 'USB_NETWORK_RNDIS_DISABLED=yes\n' >> /etc/default/bb-boot
#sed -i 's/usb1/usb0/g' /opt/scripts/boot/autoconfigure_usb1.sh
#sed -i 's/usb1/usb0/g' /usr/bin/autoconfigure_usb1.sh
printf 'auto lo\niface lo inet loopback\nauto usb0\nallow-hotplug usb0\niface usb0 inet dhcp\n    post-up ip route add 225.0.0.0/24 dev usb0\n    pre-down ip route del 225.0.0.0/24 dev usb0\n' >> /etc/network/interfaces
#sed -i 's/timeout 300/timeout 10/g' /etc/dhcp/dhclient.conf
printf 'timeout 10;\n' >> /etc/dhcp/dhclient.conf

# Disabling rndis breaks dnsmasq
# prevents creating new conf file for dnsmasq
touch /etc/dnsmasq.d/.SoftAp0 
#sed -i 's/USE_GENERATED_DNSMASQ=yes/USE_GENERATED_DNSMASQ=no/g' /etc/default/bb-wl18xx
sed -i 's/USE_GENERATED_HOSTAPD=yes/USE_GENERATED_HOSTAPD=no/g' /etc/default/bb-wl18xx
# Overriding a script that autogen SoftAp0
printf '' > /usr/bin/bb_dnsmasq_config.sh 
printf 'interface=SoftAp0\n' > /etc/dnsmasq.d/SoftAp0
printf 'port=53\n' >> /etc/dnsmasq.d/SoftAp0
printf 'dhcp-authoritative\n' >> /etc/dnsmasq.d/SoftAp0
printf 'domain-needed\n' >> /etc/dnsmasq.d/SoftAp0
printf 'bogus-priv\n' >> /etc/dnsmasq.d/SoftAp0
printf 'expand-hosts\n' >> /etc/dnsmasq.d/SoftAp0
printf 'cache-size=2048\n' >> /etc/dnsmasq.d/SoftAp0
printf 'dhcp-range=SoftAp0,192.168.8.50,192.168.8.150,10m\n' >> /etc/dnsmasq.d/SoftAp0
printf 'listen-address=127.0.0.1\n' >> /etc/dnsmasq.d/SoftAp0
printf 'listen-address=192.168.8.1\n' >> /etc/dnsmasq.d/SoftAp0
printf 'dhcp-option-force=interface:SoftAp0,option:dns-server,192.168.8.1\n' >> /etc/dnsmasq.d/SoftAp0
printf 'dhcp-option-force=interface:SoftAp0,option:mtu,1500\n' >> /etc/dnsmasq.d/SoftAp0
printf 'dhcp-leasefile=/var/run/dnsmasq.leases\n' >> /etc/dnsmasq.d/SoftAp0
printf 'address=/kiwi.opendlv.org/10.42.42.1\n' >> /etc/dnsmasq.d/SoftAp0

# Need to generate at boot
#cp /tmp/hostapd-wl18xx.conf /etc/hostapd.conf

# /usr/bin/bb-wl18xx-tether < good stuff here
# Random 1,6,11 channel assignment
sed -i 's/channel=1/channel=$( shuf -n 1 -e 1 6 11 )/g' /usr/bin/bb-wl18xx-tether

#sed -i 's/#timeout 60;/timeout 300;/g' /etc/dhcp/dhclient.conf 
#sed -i 's/#retry 60;/retry 10;/g' /etc/dhcp/dhclient.conf 
printf 'net.ipv4.ip_forward=1\n' >> /etc/sysctl.conf
printf 'net.ipv6.conf.all.disable_ipv6=1\n' >> /etc/sysctl.conf

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o usb1 -j MASQUERADE
iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE
iptables -A FORWARD -i usb0 -o SoftAp0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i SoftAp0 -o usb0 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o SoftAp0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i SoftAp0 -o eth0 -j ACCEPT

iptables -A FORWARD -i SoftAp0 -o usb0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -o SoftAp0 -i usb0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -i SoftAp0 -o usb0 -p tcp --syn --dport 8888 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A PREROUTING -i SoftAp0 -p tcp --dport 8888 -j DNAT --to-destination 10.42.42.1

iptables -A FORWARD -i SoftAp0 -o usb0 -p tcp --syn --dport 8080 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A PREROUTING -i SoftAp0 -p tcp --dport 8080 -j DNAT --to-destination 10.42.42.1

iptables -A FORWARD -i SoftAp0 -o usb0 -p tcp --syn --dport 8081 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A PREROUTING -i SoftAp0 -p tcp --dport 8081 -j DNAT --to-destination 10.42.42.1

iptables -A FORWARD -i SoftAp0 -o usb0 -p tcp --syn --dport 2200 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A PREROUTING -i SoftAp0 -p tcp --dport 2200 -j DNAT --to-destination 10.42.42.1

iptables-save > /etc/iptables/rules.v4



cd /root
wget https://raw.githubusercontent.com/chalmers-revere/opendlv.os/kiwi/kiwi/bbblue.yml 
wget https://raw.githubusercontent.com/chalmers-revere/opendlv.os/kiwi/kiwi/.env 
docker-compose -f bbblue.yml up -d


clear

echo "Installation script for the beaglebone is done!"

