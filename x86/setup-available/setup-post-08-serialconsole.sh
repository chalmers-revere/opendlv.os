#!/bin/bash

mode=115200n8

sed -i "/GRUB_CMDLINE_LINUX_DEFAULT=/s/=\"/=\"console=tty0 console=ttyS0,${mode} /" /etc/default/grub
