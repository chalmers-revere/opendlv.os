#!/bin/bash

git clone https://github.com/beagleboard/am335x_pru_package
cd am335x_pru_package
mkdir /usr/include/pruss
cp pru_sw/app_loader/include/prussdrv.h pru_sw/app_loader/include/pruss_intc_mapping.h /usr/include/pruss
cd pru_sw/app_loader/interface/
CROSS_COMPILE= make

cd ../lib
cp * /usr/lib
ldconfig

cd ../../utils/pasm_source
source linuxbuild
mv ../pasm /usr/bin
chmod +x /usr/bin/pasm

# Make automatic, or do it in C++ instead.
echo BB-BONE-PRU > /sys/devices/platform/bone_capemgr/slots
