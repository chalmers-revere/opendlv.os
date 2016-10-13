url=https://raw.githubusercontent.com/se-research/OpenDaVINCI/master/automotive/odcantools/peak-linux-driver-7.15.2.kerneldriver

wget ${url}/peak-linux-driver-7.15.2.tar.gz

tar -xvzf peak-linux-driver-7.15.2.tar.gz
rm peak-linux-driver-7.15.2.tar.gz
cd peak-linux-driver-7.15.2

wget ${url}/peak-linux-driver-7.15.2-pcan.starttime.patch

cd
