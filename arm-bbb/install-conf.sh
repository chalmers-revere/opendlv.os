#!/bin/bash

download_image=1

# Basic
vehicle=kodiac
node_index=1

timezone=Europe/Stockholm
locale=( en_US.UTF-8 )
mirror=( Sweden )
keymap=sv-latin1
font=lat2-16

# Users
user=( reverian )
shell=( /bin/bash )
group=( uucp,docker )

#Software configuration
software="git docker openssh screen dosfstools ntfs-3g bash-completion vim i2c-tools dtc-overlay"
service=( sshd docker )


# Advanced
hostname=revere-$vehicle-arm_bbb-$node_index
