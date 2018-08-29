#!/bin/bash

bitrate=0x1c

url=http://www.peak-system.com/fileadmin/media/linux/files
name=peak-linux-driver-8.6.0

wget ${url}/${name}.tar.gz

tar -xvzf ${name}.tar.gz
rm ${name}.tar.gz
cd ${name}

make NET=NO_NETDEV_SUPPORT
make install

echo -e "# pcan - automatic made entry, begin --------\n
# if required add options and remove comment \n
options pcan bitrate=${bitrate}\n
install pcan /sbin/modprobe --ignore-install pcan\n
# pcan - automatic made entry, end ----------" > /etc/modprobe.d/pcan.conf;

cd
rm -fr ${name}
