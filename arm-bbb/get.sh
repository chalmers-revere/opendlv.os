#!/bin/bash

ROOT_URL=https://raw.githubusercontent.com/chalmers-revere/opendlv.os/master/arm-bbb

wget ${ROOT_URL}/{install,install-conf,install-chroot,install-post}.sh

mkdir setup-available
cd setup-available
wget  ${ROOT_URL}/setup-available/setup-post-01-pru.sh ${ROOT_URL}/setup-available/setup-post-02-docker.sh ${ROOT_URL}/setup-available/setup-post-03-adc.sh ${ROOT_URL}/setup-available/setup-post-04-i2c.sh ${ROOT_URL}/setup-available/setup-post-05-pwm.sh ${ROOT_URL}/setup-available/setup-user-01-opendlv.sh

mkdir -p kernel/pkg
cd kernel/pkg
wget  ${ROOT_URL}/kernel/pkg/linux-am33x-4.9.10-1-armv7h.pkg.tar.xz ${ROOT_URL}/kernel/pkg/linux-am33x-headers-4.9.10-1-armv7h.pkg.tar.xz
