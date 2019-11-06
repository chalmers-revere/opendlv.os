#!/bin/bash

ROOT_URL=https://raw.github.com/chalmers-revere/opendlv.os/master/x86

wget ${ROOT_URL}/{install,install-conf}.sh

mkdir setup-available
cd setup-available
wget  ${ROOT_URL}/setup-available/setup-chroot-01-rtkernel.sh ${ROOT_URL}/setup-available/setup-chroot-02-ptpd.sh ${ROOT_URL}/setup-available/setup-post-01-router.sh ${ROOT_URL}/setup-available/setup-post-02-wan_4g_ppp.sh ${ROOT_URL}/setup-available/setup-post-03-wan_wifi.sh ${ROOT_URL}/setup-available/setup-post-04-pcan.sh ${ROOT_URL}/setup-available/setup-post-05-docker.sh ${ROOT_URL}/setup-available/setup-post-06-desktop.sh ${ROOT_URL}/setup-available/setup-post-07-its.sh ${ROOT_URL}/setup-available/setup-post-08-serialconsole.sh ${ROOT_URL}/setup-available/setup-post-09-socketcan.sh ${ROOT_URL}/setup-available/setup-user-01-opendlv.sh
