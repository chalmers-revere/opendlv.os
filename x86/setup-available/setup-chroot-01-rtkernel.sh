#!/bin/bash

WORKDIR=/tmp/kernel_build


mkdir -p ${WORKDIR}
cd ${WORKDIR}

wget -N https://aur.archlinux.org/cgit/aur.git/snapshot/linux-rt.tar.gz
tar -xf linux-rt.tar.gz

cd linux-rt


#  'ABAF11C65A2970B130ABE3C479BE3E4300411886'  # Linus Torvalds
gpg --recv-key 647F28654894E3BD457199BE38DBBDC86092693E  # Greg Kroah-Hartman
#  '8218F88849AAC522E94CF470A5E9288C4FA415FA'  # Jan Alexander Steffens (heftig)
#  '64254695FFF0AA4466CC19E67B96E8162A8CF5D1'  # Sebastian Andrzej Siewior
#  '5ED9A48FC54C0A22D1D0804CEBC26CDB5A56DE73'  # Steven Rostedt
gpg --recv-key E644E2F1D45FA0B2EAA02F33109F098506FF0B14  # Thomas Gleixner

(echo "", echo "") | MAKEFLAGS="-j$[`nproc` + 4]" makepkg -sir

sudo grub-mkconfig -o /boot/grub/grub.cfg
