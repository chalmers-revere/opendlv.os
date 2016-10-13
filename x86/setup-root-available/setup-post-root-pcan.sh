bitrate=0x1c  # truck: 0x011c

cd peak-linux-driver-7.15.2

patch -p1 < peak-linux-driver-7.15.2-pcan.starttime.patch 

make NET=NO_NETDEV_SUPPORT
make install

echo -e "# pcan - automatic made entry, begin --------\n
# if required add options and remove comment \n
options pcan bitrate=${bitrate}\n
install pcan /sbin/modprobe --ignore-install pcan\n
# pcan - automatic made entry, end ----------" > /etc/modprobe.d/pcan.conf;

cd
rm -fr peak-linux-driver-7.15.2
