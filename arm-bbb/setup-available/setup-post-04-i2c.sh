#!/bin/bash

source install-conf.sh

echo -e "#!/bin/bash\nchmod 666 /dev/i2c-2" > /root/boot/i2c.sh
chmod 755 /root/boot/i2c.sh
echo -e "[Unit]\nDescription=Enables reading and writing to i2c-2 bus to all users. The bus can be diagnosed using i2c-tools.\n\n[Service]\nExecStart=/root/boot/i2c.sh\n\n[Install]\nWantedBy=multi-user.target " > /etc/systemd/system/i2c.service 

systemctl enable i2c.service 
