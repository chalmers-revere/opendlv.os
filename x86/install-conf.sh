#!/bin/bash

# Basic
vehicle=kodiac
node_index=1

timezone=Europe/Stockholm
locale=( en_US.UTF-8 )
mirror=( Sweden )
keymap=sv-latin1
font=lat2-16

# Network
dhcp_dev=( enp2s0 )

# Partitions
hdd=/dev/sda

# Users
user=( reverian )
group=( uucp,docker )

# Setup
software="git base-devel docker openssh screen wpa_supplicant dosfstools ntfs-3g bash-completion"
service=( sshd docker )

# Advanced
hostname=revere-$vehicle-x86_64-$node_index

for f in setup-root-*.sh; do
    [ -e "$f" ] && has_setup_root=1 || has_setup_root=0
    break
done

for f in setup-user-*.sh; do
    [ -e "$f" ] && has_setup_user=1 || has_setup_user=0
    break
done

has_setup=${has_setup_root:-$has_setup_user}
