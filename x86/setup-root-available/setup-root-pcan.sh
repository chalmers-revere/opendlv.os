bitrate=0x1c  # truck: 0x011c
url=https://raw.githubusercontent.com/se-research/OpenDaVINCI/master/automotive/odcantools/peak-linux-driver-7.15.2.kerneldriver

wget ${url}/peak-linux-driver-7.15.2.tar.gz

tar -xvzf peak-linux-driver-7.15.2.tar.gz
rm peak-linux-driver-7.15.2.tar.gz
cd peak-linux-driver-7.15.2

wget ${url}/peak-linux-driver-7.15.2-pcan.starttime.patch
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
