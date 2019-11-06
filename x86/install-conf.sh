#!/bin/bash

hostname=revere-rhino-x86_64-1

root_password=changeMeNow

timezone=Europe/Stockholm
locale=( en_US.UTF-8 )
mirror=( Sweden )
keymap=sv-latin1

user=( revere )
user_password=( changeMeNow )
group=( uucp )

software="base-devel gnu-netcat vim ifplugd wget openssh bash-completion screen"
service=( sshd )

lan_dev=enp2s0
eth_dhcp_client_dev=( ${lan_dev} )  # On a router setup, this is typically all ethernet WAN devices

hdd=/dev/sda

disable_uefi=false
uefi_bad_impl=false

kernel_options=quiet

arch_mirror="http://mirror.rackspace.com"
