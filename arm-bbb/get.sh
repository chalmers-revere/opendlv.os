#!/bin/bash

ROOT_URL=https://raw.githubusercontent.com/chalmers-revere/opendlv.os/refactoring.major/arm-bbb

wget ${ROOT_URL}/{install,install-conf,install-chroot,install-post}.sh

mkdir setup-available
cd setup-available
wget  ${ROOT_URL}/setup-available/setup-sys-01-pru.sh ${ROOT_URL}/setup-available/setup-sys-02-docker.sh ${ROOT_URL}/setup-available/setup-user-01-opendlv.sh
