#!/bin/bash

source install-conf.sh

subnet=10.42.42.0
wan_forward_dev=( ${eth_dhcp_client_dev[@]} )
dns="8.8.8.8"

dhcp_lease_start=10
dhcp_lease_end=30

# MAC filter according to: "x86-v2v,00:0d:b9:3e:bb:84,61", ..

dhcp_clients=( )



pacman -S --noconfirm dhcp
systemctl enable iptables

base_ip=`echo $subnet | cut -d"." -f1-3`
ip="$base_ip.1"
broadcast_ip="$base_ip.255"

echo -e "Description='Internal network'\nInterface=${lan_dev}\nConnection=ethernet\nIP=static\nIPCustom=('addr add dev ${lan_dev} $ip/24' 'route add 225.0.0.0/24 dev ${lan_dev}')\nSkipNoCarrier=yes" > /etc/netctl/${lan_dev}-static
netctl enable ${lan_dev}-static

echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/30-ipforward.conf
echo "net.ipv4.conf.eno1.rp_filter=0" > /etc/sysctl.d/40-rpfilter.conf

iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

for (( i = 0; i < ${#wan_forward_dev[@]}; i++ )); do
  iptables -A FORWARD -i ${lan_dev} -o ${wan_forward_dev[$i]} -j ACCEPT
  iptables -t nat -A POSTROUTING -o ${wan_forward_dev[$i]} -j MASQUERADE
done

iptables-save > /etc/iptables/iptables.rules

echo -e "authoritative;\n\ndefault-lease-time 3600;\nmax-lease-time 7200;\n\nsubnet $subnet netmask 255.255.255.0 {\n  range $base_ip.$dhcp_lease_start $base_ip.$dhcp_lease_end;\n\n  option routers $ip;\n  option subnet-mask 255.255.255.0;\n  option broadcast-address $broadcast_ip;\noption domain-name-servers $dns;\n}\n" > /etc/dhcpd.conf
for (( i = 0; i < ${#dhcp_clients[@]}; i++ )); do
  client_conf=${dhcp_clients[$i]}
  client_conf_arr=(${client_conf//,/ })
  client_name=${client_conf_arr[0]}
  client_mac=${client_conf_arr[1]}
  client_ip=${client_conf_arr[2]}
  echo -e "host $client_name {\n  option host-name \"$client_name\";\n  hardware ethernet $client_mac;\n  fixed-address $base_ip.$client_ip;\n}\n" >> /etc/dhcpd.conf
done

echo -e "[Unit]\nDescription=IPv4 DHCP server on %I\nAfter=network.target\n\n[Service]\nType=forking\nPIDFile=/run/dhcpd4.pid\nExecStart=/usr/bin/dhcpd -4 -q -pf /run/dhcpd4.pid %I\nKillSignal=SIGINT\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/dhcpd4@.service

systemctl enable dhcpd4@${lan_dev}.service
