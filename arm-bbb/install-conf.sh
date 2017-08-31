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

# Software configuration
software=" \
base-devel \
bash-completion \
ccache \
cmake \
dhcpcd \
dosfstools \
dtc \
gnu-netcat \
git \
ifplugd \
i2c-tools \
linux-headers \
nano \
ntfs-3g \
openssh \
screen \
vim \
wget \
wpa_supplicant \
wpa_actiond \
"
service=( sshd )

lan_dev=wlan0
dhcp_dev=( ${lan_dev} )

# Advanced
hostname=$lab-$vehicle-arm_bbb-$node_index

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

has_setup_root=$(( $has_setup_chroot || $has_setup_post ? 1 : 0))
has_setup=$(( $has_setup_root || $has_setup_user ? 1 : 0))
