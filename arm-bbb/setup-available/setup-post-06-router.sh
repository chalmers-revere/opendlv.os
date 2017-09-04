#!/bin/bash

source install-conf.sh

subnet=10.42.11.0
wan=( eth0 usb0 ppp0 )
dns="8.8.8.8"

dhcp_lease_start=10
dhcp_lease_end=30

pacman -S --noconfirm dhcp
systemctl enable iptables

base_ip=`echo $subnet | cut -d"." -f1-3`
ip="$base_ip.1"
broadcast_ip="$base_ip.255"

#echo -e "Description='Internal network'\nInterface=${lan_dev}\nConnection=ethernet\nIP=static\nIPCustom=('addr add dev ${lan_dev} $ip/24' 'route add 225.0.0.0/24 dev ${lan_dev}')\nSkipNoCarrier=yes" > /etc/netctl/${lan_dev}-static
#netctl enable ${lan_dev}-static

echo -e "# Speed up DHCP by disabling ARP probing\nnoarp\n\n# Set static IP address \ninterface $lan_dev\nstatic ip_address=$ip/24\nstatic routers=$ip\nstatic domain_name_servers=$ip 8.8.8.8\n" >> /etc/dhcpcd.conf

# systemctl enable dhcpcd@${lan_dev}.service

echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/30-ipforward.conf
echo "net.ipv4.conf.eno1.rp_filter=0" > /etc/sysctl.d/40-rpfilter.conf

iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

for (( i = 0; i < ${#wan[@]}; i++ )); do
  iptables -A FORWARD -i ${lan_dev} -o ${wan[$i]} -j ACCEPT
  iptables -t nat -A POSTROUTING -o ${wan[$i]} -j MASQUERADE
done

iptables-save > /etc/iptables/iptables.rules

echo -e "authoritative;\n\ndefault-lease-time 3600;\nmax-lease-time 7200;\n\nsubnet $subnet netmask 255.255.255.0 {\n  range $base_ip.$dhcp_lease_start $base_ip.$dhcp_lease_end;\n\n  option routers $ip;\n  option subnet-mask 255.255.255.0;\n  option broadcast-address $broadcast_ip;\n  option domain-name-servers $dns;\n}\n" > /etc/dhcpd.conf
for (( i = 0; i < ${#dhcp_clients[@]}; i++ )); do
  client_conf=${dhcp_clients[$i]}
  client_conf_arr=(${client_conf//,/ })
  client_name=${client_conf_arr[0]}
  client_mac=${client_conf_arr[1]}
  client_ip=${client_conf_arr[2]}
  echo -e "host $client_name {\n  option host-name \"$client_name\";\n  hardware ethernet $client_mac;\n  fixed-address $base_ip.$client_ip;\n}\n" >> /etc/dhcpd.conf
done

echo -e "[Unit]\nDescription=IPv4 DHCP server on %I\nRequires=hostapd.service\nAfter=multi-user.target\n\n[Service]\nRestart=always\nRestartSec=30\nType=forking\nPIDFile=/run/dhcpd4.pid\nExecStart=/usr/bin/dhcpd -4 -q -pf /run/dhcpd4.pid %I\nKillSignal=SIGINT\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/dhcpd4@.service

systemctl enable dhcpd4@${lan_dev}.service
