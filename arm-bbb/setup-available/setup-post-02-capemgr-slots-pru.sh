#!/bin/bash

source install-conf.sh

echo -e "#!/bin/bash\necho -e 'BB-BONE-PRU' > /sys/bus/platform/devices/bone_capemgr/slots" > /root/boot/capemgr-slots-pru.sh
chmod 755 /root/boot/capemgr-slots-pru.sh
echo -e "[Unit]\nDescription=Enables the PRU0, for running custom PRU programs.\n\n[Service]\nExecStart=/root/boot/capemgr-slots-pru.sh\n\n[Install]\nWantedBy=multi-user.target " > /etc/systemd/system/capemgr-slots-pru.service 

systemctl enable capemgr-slots-pru.service 
