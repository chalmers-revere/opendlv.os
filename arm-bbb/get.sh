#!/bin/bash

ROOT_URL=https://raw.githubusercontent.com/chalmers-revere/opendlv.os/master/arm-bbb

wget ${ROOT_URL}/{install,install-conf,install-chroot,install-post}.sh

mkdir setup-available
cd setup-available
wget  ${ROOT_URL}/setup-available/setup-post-01-pru.sh ${ROOT_URL}/setup-available/setup-post-02-capemgr-slots-adc.sh ${ROOT_URL}/setup-available/setup-post-02-capemgr-slots-pru.sh ${ROOT_URL}/setup-available/setup-post-02-docker.sh ${ROOT_URL}/setup-available/setup-post-02-i2c.sh ${ROOT_URL}/setup-available/setup-user-01-opendlv.sh
