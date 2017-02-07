#!/bin/bash

source install-conf.sh

echo -e "#!/bin/bash\necho -e 'BB-ADC' > /sys/bus/platform/devices/bone_capemgr/slots" > /root/boot/capemgr-slots-adc.sh
chmod 755 /root/boot/capemgr-slots-adc.sh
echo -e "[Unit]\nDescription=Enables reading values from analogue DC from pins. Values can be read by 'cat /sys/bus/iio/devices/iio\:device0/in_voltage*'.\n\n[Service]\nExecStart=/root/boot/capemgr-slots-adc.sh\n\n[Install]\nWantedBy=multi-user.target " > /etc/systemd/system/capemgr-slots-adc.service 

systemctl enable capemgr-slots-adc.service 
