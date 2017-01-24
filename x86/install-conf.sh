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

# Setup
software="git base-devel cmake ccache openssh screen wpa_supplicant wpa_actiond dosfstools ntfs-3g bash-completion wget linux-headers ifplugd vim"
service=( sshd )

# Network
dhcp_dev=( enp2s0 )

# Partitions
hdd=/dev/sda

# Advanced
hostname=$lab-$vehicle-x86_64-$node_index

for f in setup-chroot-*.sh; do
    [ -e "$f" ] && has_setup_chroot=1 || has_setup_chroot=0
    break
done

for f in setup-post-*.sh; do
    [ -e "$f" ] && has_setup_post=1 || has_setup_post=0
    break
done

for f in setup-user-*.sh; do
    [ -e "$f" ] && has_setup_user=1 || has_setup_user=0
    break
done

has_setup_root=${has_setup_chroot:-$has_setup_post}
has_setup=${has_setup_root:-$has_setup_user}
