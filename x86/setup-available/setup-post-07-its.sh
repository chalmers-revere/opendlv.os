#!/bin/bash

dev=wlp4s0


pacman -S --noconfirm iw

mkdir -p /root/boot

echo -e "#!/bin/bash\n\nip link set ${dev} down\niw dev ${dev} set type ocb\nip link set ${dev} up\niw dev ${dev} ocb join 5890 10MHZ" > /root/boot/its-setfreq.sh
chmod 755 /root/boot/its-setfreq.sh
echo -e "[Unit]\nDescription=Set frequency of ITS V2V communication.\nAfter=multi-user.target\n\n[Service]\nExecStart=/root/boot/its-setfreq.sh\n\n[Install]\nWantedBy=multi-user.target " > /etc/systemd/system/its-setfreq.service 

systemctl enable its-setfreq.service

git clone https://github.com/jandejongh/udp2eth.git

cd udp2eth
make
cp udp2eth /usr/local/bin
cd /root

echo -e "[Unit]\nDescription=Small package converter from udp to eth frames and vice versa.\nAfter=multi-user.target its-setfreq.service\n\n[Service]\nExecStart=/usr/local/bin/udp2eth -p --device=wlp4s0 --server=127.0.0.1:4000 --client=127.0.0.1:4001\n\n[Install]\nWantedBy=multi-user.target " > /etc/systemd/system/its-udp2eth.service 
rm -rf udp2eth

systemctl enable its-udp2eth.service
