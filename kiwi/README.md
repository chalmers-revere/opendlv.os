# Reinstalling Debian OS on the kiwi

This guide will provide you the steps to install Debian on the beaglebone blue and raspberry pi 3 computers on the kiwi platform. They are pre-installed on the platform already, so use this guide as a last resort for resetting the platform or installation reference.

In this guide, we will assume that you have internet connection on your host pc and have curl package installed in the fresh debian os.


## Table of Contents
* [Raspberry pi 3](#raspberry-pi-3)
* [Beaglebone blue](#beaglebone-blue)
* [Devantech flashing](#devantech-flashing)
* [Steering calibration](#steering-calibration)

---

### Raspberry pi 3

1. Download the following debian image that is custom build for raspberry pi 3: https://www.raspberrypi.org/downloads/raspbian/ 
I recommend using the lite version without any graphical interface for optimum performance.

2. Use a program to flash sdcard with the newly downloaded debian image. I'd recommend etcher (https://etcher.io/). Use a spare sdcard if possible, this step will wipe it clean for the debian image.

3. Before unmounting the sdcard after the flashing, create a file named ssh on the boot filesystem partition. This will enable ssh functionality at boot on default. Unmount and insert the sdcard to the raspberry pi 3. BEFORE BOOTING UP raspberry pi 3, make sure that the beaglebone blue is powered up first and connected to the rasperry pi 3 via the USB. This is to ensure the configuration is done properly.

4. To power up the Raspberry Pi, you need to plug in the battery and you start the ESC. This will start the Raspberry Pi(it does not have a power up button).

5. Connect to the raspberry pi 3 via ethernet (share your network/internet by acting as a dhcp server alternatively connect your pc and raspberry pi 3 to a router).

6. Find the ip address of the raspberry pi 3. On linux system use nmap, e.g.

* Finding the ip: nmap 10.42.0.1/24 

if your ip address 10.42.0.1

7. Connect the raspberry pi 3 via ssh

* Connecting: `ssh pi@10.42.0.33`
  * Password: raspberry
  
(replace 10.42.0.33 with the found ip adress from previous step.)

8. Get root privileges

`sudo -i`

9. Use our installation script

* Script: `curl -sSL https://raw.githubusercontent.com/chalmers-revere/opendlv.os/kiwi/kiwi/rpi3/install.sh | sh`

10. Once the script is done, reboot and you are done.

11. Now the port has changed so you need to ssh to the device with

* `ssh -p 2200 pi@ipaddr`


### Beaglebone blue

1. Download the following debian image that is custom build for beaglebone blue: http://strawsondesign.com/docs/images/BBBL-blank-debian-9.5-iot-armhf-2018-10-07-4gb.img.xz

2. Use a program to flash sdcard with the newly downloaded debian image. I'd recommend etcher (https://etcher.io/). Use a spare sdcard if possible, this step will wipe it clean for the debian image.

3. Put the sdcard into the beaglebone blue sdcard slot and reboot it. It will now flash the eMMC on the chip. You will see the LEDs flash in a orderly manner back and fourth. Once it's done, the LEDs should be turned off and static. Remove the sdcard and put an empty sdcard on. Then reboot (Press the RST button once (upper left corner) and then the POW button (next to it)).

4. Connect the beaglebone to your host machine via usb or connect to its wifi hotspot (password: `BeagleBone`). Ssh into the board using the predefined target IP addresses `192.168.7.2` if you connected via usb or `192.168.8.1` if you connected to the board's wifi.

* Connecting: `ssh debian@192.168.7.2` or `ssh debian@192.168.8.1`
  * Password: temppwd

5. Once inside, with `ifconfig` or `ip a` you will see two active usb network interfaces. One interface will have a static IP of 192.168.6.2 and the other at 192.168.7.2. I would recommend to start sharing your host internet connection: once done, get root privileges and connect the beaglebone to it: so if you shared it via the usb1 interface can run `dhclient usb1`.

* Get root privileges: `su`
  * Password: root

6. Use the installation script: https://raw.githubusercontent.com/chalmers-revere/opendlv.os/kiwi/kiwi/arm-bbblue/install.sh

* `curl -sSL https://raw.githubusercontent.com/chalmers-revere/opendlv.os/kiwi/kiwi/arm-bbblue/install.sh | sh`

7. When the script is done, reboot and you are done!

### Devantech flashing
1. After flashing the beaglebone with our installation script, there is a devantech folder at /root/bbb/devatech inside of the beaglebone (ssh into it). Navigate to it as root(do the following).

* root: `su`
  * Password: root
* change directory: `cd /root`

2. Download and build the binary

* `mkdir -p devantech_tools && cd devantech_tools && wget -q https://raw.githubusercontent.com/chalmers-revere/opendlv-device-ultrasonic-srf08/master/tools/devantech_change_addr.cpp && wget -q https://raw.githubusercontent.com/chalmers-revere/opendlv-device-ultrasonic-srf08/master/tools/Makefile && make`

3. Navigate to the directory /root, which is the one outside. <!-- the directory /root/bbb does not exist any longer -->

* `cd /root`

4. Bring the service down with the following command

* `docker-compose -f bbb.yml down' (NOTE: Wait until you see an output for the services with the message "done")`

5. Navigate to the directory where you runned make

* `cd devantech_tools`

6. Unplug the front sensor and run following command

* `./devantech_change_addr 1 0x70 0x71`

to change the back sensor on the i2c-1 bus from addr 0x70 to 0x71. When the command its executed, the led flash on the sensor should be lit up upon success. Unplug and plug the sensor again, when booting up, you should see the sensor flashing the led twice. Now plug in the front sensor again. You will also see that it flashes once. 

7. Now you need to bring the service up again. So you need to navigate to the outside directory again

* `cd .. (It would take you to the directory /bbb)`
* `docker-compose -f bbb.yml up -d`


### Steering calibration

1. After the installation of our software, the steering might be slightly off centered causing kiwi to drift either left or right when tryint to propell it forward. This can be fixed by adding a small offset value to the steering as a part of the calibration. Get root privileges inside of the beaglebone (ssh into it and su)

`ssh debian@192.168.8.1`
Password: temppwd

`su`
Password: root

2. Goto bbb folder
`cd /root`

3. Open a web browser (preferrably chrome or firefox) and goto http://192.182.8.1:8081 . This will show you the overview of the robot platform with sensor data and other debug tools. We will navigate to joystick page, so goto joystick page at http://192.182.8.1:8081/joystick . This page will give you actuation control of the robot. Before trying to actuate the robot, make sure that the robot is in a safe place to do so (e.g. not on a table to drive off to the ground). Make sure that you can actuate the robot by click-and-hold on the bottom half of the webpage. Sliding up will accelerate, down deccelerate. Sliding horizontally will make the robot steer. 
4. Put the car on the ground and activate the joystick mode by switch it to "ON". To configure the steering calibration, open the "Parameters" option. In the list of parameters, there is a tickbox "Calibration". This slider will offset the steering to your configuration.
5. Slide the steering calibration to your satisfaction and try the new calibration settings with your joystick control.
6. In order to make the new calibration settings persistent (across reboots), you will now go back to the terminal where you previously logged in as root.
7. Save the settings by running
`docker-compose -f bbb.yml down`
then
`docker-compose -f bbb.yml up -d`

Redo step 4 to 7 if it still needs to reconfiguered.
