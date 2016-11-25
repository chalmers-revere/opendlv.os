#!/bin/bash

if [ "${1}" == "" ]; then
  ${1} = "master"
fi

ROOT_URL=https://raw.githubusercontent.com/chalmers-revere/opendlv.os/${1}/x86

wget ${ROOT_URL}/{install,install-conf,install-sys,install-post}.sh

mkdir setup-available
cd setup-available
wget  ${ROOT_URL}/setup-available/setup-sys-01-router.sh ${ROOT_URL}/setup-available/setup-sys-02-4g_ppp.sh ${ROOT_URL}/setup-available/setup-sys-03-wifi.sh ${ROOT_URL}/setup-available/setup-sys-04-pcan.sh ${ROOT_URL}/setup-available/setup-sys-05-docker.sh ${ROOT_URL}/setup-available/setup-sys-06-desktop.sh ${ROOT_URL}/setup-available/setup-user-01-opendlv.sh
