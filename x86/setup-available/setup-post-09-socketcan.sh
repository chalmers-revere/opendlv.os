#!/bin/bash

dev=( can0 can1 )
bitrate=( 500000 1000000 )

echo -e "#!/bin/bash\n\n" > /root/boot/socketcan-setup.sh
for (( i = 0; i < ${#dev[@]}; i++ )); do
  echo -e "ip link set ${dev[$i]} up type can bitrate ${bitrate[$i]}\n" >> /root/boot/socketcan-setup.sh
done

chmod 755 /root/boot/socketcan-setup.sh
echo -e "[Unit]\nDescription=Setup socket can.\nAfter=default.target\n\n[Service]\nExecStart=/root/boot/socketcan-setup.sh\n\n[Install]\nWantedBy=default.target " > /etc/systemd/system/socketcan-setup.service 

systemctl enable socketcan-setup.service
