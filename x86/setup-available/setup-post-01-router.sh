#!/bin/bash

source install-conf.sh

subnet=10.42.42.0
wan_forward_dev=( ${eth_dhcp_client_dev[@]} wlp0s20u1 ppp0 )
dns="8.8.8.8"

dhcp_lease_start=10
dhcp_lease_end=30

# Snowfox
dhcp_clients=(
  "axis1,AC:CC:8E:84:80:3C,12",
  "velo-hdl32e,60:76:88:20:20:01,13",
  "cisco-switch1-16p,F8:7B:20:D2:FE:40,21",
  "meinberg1,EC:46:70:00:99:EB,27",
  "meinberg2,00:13:95:1D:F4:B6,30",
  "applanix-gps,00:17:47:20:0D:58,40",
)

# Rhino
#dhcp_clients=(
#  "meinberg2,00:13:95:19:EA:A6,10",
#  "cisco-switch1-8p,EC:BD:1D:C1:93:40,11",
#  "cisco-switch2-16p,00:5D:73:67:A5:40,12",
#  "cisco-switch3-16p,6C:DD:30:B9:A2:C0,13",
#  "hp-tablet,00:24:9B:15:4A:EA,14",
#  "meinberg1,EC:46:70:00:7F:86,16",
#  "axis1,AC:CC:8E:23:6E:8D,29",
#  "velo-vlp32c,60:76:88:34:34:4D,30",
#  "oxts-gps,70:B3:D5:AF:03:73,56",
#)

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
