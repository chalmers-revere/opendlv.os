#!/bin/bash

ROOT_URL=https://raw.githubusercontent.com/chalmers-revere/opendlv.os/master/x86

wget ${ROOT_URL}/{install,install-conf,install-chroot,install-post}.sh

mkdir setup-available
cd setup-available
wget  ${ROOT_URL}/setup-available/setup-chroot-01-rtkernel.sh ${ROOT_URL}/setup-available/setup-chroot-02-ptpd.sh ${ROOT_URL}/setup-available/setup-post-01-router.sh ${ROOT_URL}/setup-available/setup-post-02-wan_4g_ppp.sh ${ROOT_URL}/setup-available/setup-post-03-wan_wifi.sh ${ROOT_URL}/setup-available/setup-post-04-pcan.sh ${ROOT_URL}/setup-available/setup-post-05-docker.sh ${ROOT_URL}/setup-available/setup-post-06-desktop.sh ${ROOT_URL}/setup-available/setup-user-01-opendlv.sh
