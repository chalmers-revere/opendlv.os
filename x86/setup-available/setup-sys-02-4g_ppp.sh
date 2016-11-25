dev=( ttyUSB0 )
apn=( online.telia.se )

pacman -S --noconfirm usb_modeswitch

for (( i = 0; i < ${#dev[@]}; i++ )); do
  echo -e "Description='Huawei 4G USB'\nInterface=${dev[$i]}\nConnection=mobile_ppp\nAccessPointName=${apn[$i]}\nInit='ATQ0 V1 E1 S0=0'\nMode=3Gpref" > /etc/netctl/ppp-${dev[$i]}-dhcp
done
