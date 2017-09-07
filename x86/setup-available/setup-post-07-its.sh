#!/bin/bash

dev=wlp4s0
server_port=4000
client_port=4001


pacman -S --noconfirm iw python2-pip python2-setuptools python2-packaging python2-six python2-pyparsing python2-appdirs python2


mkdir -p /root/boot

echo -e '#!/bin/bash\n\nip link set ${dev} down\niw dev ${dev} set type ocb\nip link set ${dev} up\niw dev ${dev} ocb join 5890 10MHZ' > /root/boot/its-setfreq.sh
chmod 755 /root/boot/its-setfreq.sh
echo -e '[Unit]\nDescription=Set frequency of ITS V2V communication.\nAfter=multi-user.target\n\n[Service]\nExecStart=/root/boot/its-setfreq.sh\n\n[Install]\nWantedBy=multi-user.target ' > /etc/systemd/system/its-setfreq.service 

systemctl enable its-setfreq.service

cd /usr/local/bin
wget https://raw.githubusercontent.com/alexvoronov/utoepy/master/eth2udp.py 
wget https://raw.githubusercontent.com/alexvoronov/utoepy/master/udp2eth.py 
cd 

echo -e '#!/bin/bash\n\npython2 /usr/local/bin/udp2eth.py --port 4000 --interface wlp4s0 --mode cooked' > /root/boot/udp2eth.sh
chmod 755 /root/boot/udp2eth.sh
echo -e '#!/bin/bash\n\npython2 /usr/local/bin/eth2udp.py --address 127.0.0.1:4001 --interface wlp4s0 --mode cooked' > /root/boot/eth2udp.sh
chmod 755 /root/boot/eth2udp.sh

echo -e '[Unit]\nDescription=Python scripts to forward data from a UDP port to an Ethernet interface and back.\nRequires=its-setfreq.service\nAfter=its-setfreq.service\n\n[Service]\nRestart=always\nRestartSec=30\nExecStart=/root/boot/udp2eth.sh\n\n[Install]\nWantedBy=multi-user.target ' > /etc/systemd/system/udp2eth.service 
echo -e '[Unit]\nDescription=Python scripts to forward data from a UDP port to an Ethernet interface and back.\nRequires=its-setfreq.service\nAfter=its-setfreq.service\n\n[Service]\nRestart=always\nRestartSec=30\nExecStart=/root/boot/eth2udp.sh\n\n[Install]\nWantedBy=multi-user.target ' > /etc/systemd/system/eth2udp.service 

systemctl enable udp2eth.service
systemctl enable eth2udp.service


# git clone https://github.com/alexvoronov/utoepy.git

# git clone https://github.com/jandejongh/udp2eth.git

# cd udp2eth
# make
# cp udp2eth /usr/local/bin
# cd /root

# echo -e '[Unit]\nDescription=Small package converter from udp to eth frames and vice versa.\nAfter=multi-user.target its-setfreq.service\n\n[Service]\nExecStart=/usr/local/bin/udp2eth -p --device=${dev} --server=127.0.0.1:${server_port} --client=127.0.0.1:${client_port}\n\n[Install]\nWantedBy=multi-user.target ' > /etc/systemd/system/its-udp2eth.service 
# rm -rf udp2eth

# systemctl enable its-udp2eth.service
