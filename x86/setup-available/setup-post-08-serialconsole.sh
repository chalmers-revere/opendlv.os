#!/bin/bash

mode=115200n8

sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=/s/=\"/=\"console=tty0 console=ttyS0,${mode} /" /etc/default/grub


#TODO:
# Serial console
# GRUB_TERMINAL=serial
# GRUB_SERIAL_COMMAND="serial --speed=38400 --unit=0 --word=8 --parity=no --      stop=1"

grub-mkconfig -o /boot/grub/grub.cfg
