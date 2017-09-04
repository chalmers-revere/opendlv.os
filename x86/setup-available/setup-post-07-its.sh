#!/bin/bash

dev=wlp4s0


pacman -S --noconfirm iw

mkdir -p /root/boot

echo -e "#!/bin/bash\n\nip link set ${dev} down\niw dev ${dev} set type ocb\nip link set ${dev} up\niw dev ${dev} ocb join 5890 10MHZ" > /root/boot/its-setfreq.sh
chmod 755 /root/boot/its-setfreq.sh
echo -e "[Unit]\nDescription=Set frequency of ITS V2V communication.\nAfter=multi-user.target\n\n[Service]\nExecStart=/root/boot/its-setfreq.sh\n\n[Install]\nWantedBy=multi-user.target " > /etc/systemd/system/its-setfreq.service 

systemctl enable its-setfreq.service

