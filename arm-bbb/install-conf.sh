#!/bin/bash

# Basic
lab=revere
vehicle=rhino
node_index=1
root_password=changeMeNow

timezone=Europe/Stockholm
locale=( en_US.UTF-8 )
mirror=( Sweden )
keymap=sv-latin1

# Users
user=( revere )
user_password=( changeMeNow )
group=( uucp )

#Software configuration
software="git base-devel openssh screen dosfstools ntfs-3g bash-completion wget linux-headers ifplugd vim i2c-tools dtc-overlay"
service=( sshd )

# Advanced
hostname=$lab-$vehicle-arm_bbb-$node_index

for f in setup-sys-*.sh; do
    [ -e "$f" ] && has_setup_sys=1 || has_setup_sys=0
    break
done

for f in setup-user-*.sh; do
    [ -e "$f" ] && has_setup_user=1 || has_setup_user=0
    break
done

has_setup=${has_setup_sys:-$has_setup_user}
