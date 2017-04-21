#!/bin/bash

branch=`git rev-parse --abbrev-ref HEAD`
platform=( x86 arm-bbb )

echo "For branch '${branch}'"

for p in ${platform[@]}; do

  echo "  .. generating ${p}/get.sh"

  setup_list=
  cd ${p}/setup-available
  for f in setup-*.sh; do
    setup_list=${setup_list}' ${ROOT_URL}/setup-available/'${f}
  done
  cd ../..
  
  kernel_list=
  cd ${p}/kernel/pkg
  for f in linux*.tar.xz; do
    kernel_list=${kernel_list}' ${ROOT_URL}/kernel/pkg/'${f}
  done
  cd ../../..

  echo '#!/bin/bash

ROOT_URL=https://raw.githubusercontent.com/chalmers-revere/opendlv.os/'${branch}'/'${p}'

wget ${ROOT_URL}/{install,install-conf,install-chroot,install-post}.sh

mkdir setup-available
cd setup-available
wget '${setup_list}'

mkdir -p kernel/pkg
cd kernel/pkg
wget '${kernel_list} > ${p}/get.sh

done

echo "Done."
