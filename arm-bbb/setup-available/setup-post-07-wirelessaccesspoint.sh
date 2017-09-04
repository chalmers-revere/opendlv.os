#!/bin/bash

source install-conf.sh

pacman -S --noconfirm hostapd

ssid=hotspot-$hostname
ssid_pwd=changeMeNow

echo -e "ssid=$ssid\nwpa_passphrase=$ssid_pwd\ninterface=$lan_dev\nauth_algs=3\nchannel=7\ndriver=nl80211\nhw_mode=g\nlogger_stdout=-1\nlogger_stdout_level=2\nmax_num_sta=5\nrsn_pairwise=CCMP\nwpa=2\nwpa_key_mgmt=WPA-PSK\nwpa_pairwise=TKIP CCMP\n" > /etc/hostapd/hostapd.conf

systemctl enable hostapd.service
