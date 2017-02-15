#!/bin/bash

base_url=https://raw.githubusercontent.com/chalmers-revere/opendlv.os/master/x86/kernel/pkg
version=4.9.9_rt6-revere

cd
source install-conf.sh

mkdir setup-rtkernel
cd setup-rtkernel

wget ${base_url}/linux-rt-${version}-1-x86_64.pkg.tar.xz
wget ${base_url}/linux-rt-docs-${version}-1-x86_64.pkg.tar.xz
wget ${base_url}/linux-rt-headers-${version}-1-x86_64.pkg.tar.xz

pacman -U --noconfirm *.pkg.tar.xz

grub-mkconfig -o /boot/grub/grub.cfg

cd
