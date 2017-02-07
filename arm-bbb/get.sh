#!/bin/bash

ROOT_URL=https://raw.githubusercontent.com/chalmers-revere/opendlv.os/master/arm-bbb

wget ${ROOT_URL}/{install,install-conf,install-chroot,install-post}.sh

mkdir setup-available
cd setup-available
wget  ${ROOT_URL}/setup-available/setup-user-{01-opendlv}.sh
wget  ${ROOT_URL}/setup-available/setup-post-{01-pru,02-docker,02-adc,02-i2c}.sh
