#!/bin/bash

# Basic
vehicle=kodiac
node_index=1
root_password=changeMeNow

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
user_password=( changeMeNow )
group=( uucp,docker )

# Setup
software="git base-devel docker openssh screen wpa_supplicant wpa_actiond dosfstools ntfs-3g bash-completion wget linux-headers ifplugd vim"
service=( sshd docker )

# Advanced
hostname=revere-$vehicle-x86_64-$node_index

for f in setup-env-root-*.sh; do
    [ -e "$f" ] && has_setup_env_root=1 || has_setup_env_root=0
    break
done

for f in setup-post-root-*.sh; do
    [ -e "$f" ] && has_setup_post_root=1 || has_setup_post_root=0
    break
done

for f in setup-env-user-*.sh; do
    [ -e "$f" ] && has_setup_env_user=1 || has_setup_env_user=0
    break
done

for f in setup-post-user-*.sh; do
    [ -e "$f" ] && has_setup_post_user=1 || has_setup_post_user=0
    break
done

has_setup_env=${has_setup_env_root:-$has_setup_env_user}
has_setup_post=${has_setup_post_root:-$has_setup_post_user}
has_setup=${has_setup_env:-$has_setup_post}
