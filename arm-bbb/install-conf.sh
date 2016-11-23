#!/bin/bash

download_image=1

# Basic
vehicle=rhino
node_index=1
root_password=changeMeNow

timezone=Europe/Stockholm
locale=( en_US.UTF-8 )
mirror=( Sweden )
keymap=sv-latin1

# Users
user=( reverian )
user_password=( changeMeNow )
group=( uucp,docker )

#Software configuration
software="git base-devel openssh screen dosfstools ntfs-3g bash-completion wget linux-headers ifplugd vim i2c-tools dtc-overlay"
service=( sshd )

# Advanced
hostname=revere-$vehicle-arm_bbb-$node_index

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
